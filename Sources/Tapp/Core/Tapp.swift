import AdjustSdk
import Foundation

@objc
public class Tapp: NSObject {

    static let single: Tapp = .init()
    let dependencies: Dependencies = .live

    private var initializationCompletions: [InitializeTappCompletion] = []
    private var secretsDataTask: URLSessionDataTaskProtocol?
    // MARK: - Configuration
    // AppDelegate: Called upon didFinishLaunching

    @objc
    public static func start(config: TappConfiguration) {
        if let storedConfig = single.dependencies.keychainHelper.config, storedConfig != config {
            single.dependencies.keychainHelper.save(config: config)
        }

        single.fetchSecretsAndInitializeReferralEngineIfNeeded(completion: nil)
        
    }
    // MARK: - Process Referral Engine

    //AppDelegate called when receiving a url
    public static func appWillOpen(_ url: URL, completion: VoidCompletion?) {
        guard let config = single.dependencies.keychainHelper.config else {
            let error = TappError.missingConfiguration
            Logger.logError(error)
            completion?(Result.failure(error))
            return
        }

        single.appWillOpen(url, authToken: config.authToken, completion: completion)
    }

    @objc
    public static func appWillOpen(_ url: URL, completion: ((_ error: Error?) -> Void)?) {
        appWillOpen(url) { result in
            switch result {
            case .success:
                completion?(nil)
            case .failure(let error):
                completion?(error)
            }
        }
    }

    public static func url(config: AffiliateURLConfiguration,
                    completion: GenerateURLCompletion?) {
        single.fetchSecretsAndInitializeReferralEngineIfNeeded { result in
            switch result {
            case .success:
                let request = GenerateURLRequest(influencer: config.influencer, adGroup: config.adgroup, creative: config.creative, data: config.data)

                single.dependencies.services.tappService.url(request: request, completion: completion)
            case .failure(let error):
                completion?(Result.failure(error))
            }
        }
    }

    @objc
    public static func url(config: AffiliateURLConfiguration, completion: ((_ response: GeneratedURLResponse?, _ error: Error?) -> Void)?) {
        url(config: config) { result in
            switch result {
            case .success(let response):
                completion?(response, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }

    // MARK: - Handle Event
    //For MMP Specific events
    @objc
    public static func handleEvent(config: EventConfig) {
        guard let storedConfig = single.dependencies.keychainHelper.config else { return }
        single.affiliateService?.handleEvent(eventId: config.eventToken,
                                             authToken: storedConfig.authToken)
    }

    //For Tapp Events
    @objc
    public static func handleTappEvent(event: TappEvent) {
        guard event.eventAction.isValid else {
            Logger.logError(TappError.eventActionMissing)
            return
        }

        single.dependencies.services.tappService.sendTappEvent(event: event, completion: nil)
    }
}

//MARK: - AppWillOpen + Processing
private extension Tapp {
    private func handleReferralCallback(url: URL,
                                        authToken: String,
                                        completion: VoidCompletion? = nil) {

        dependencies.services.tappService.handleImpression(url: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.affiliateService?.handleCallback(with: url.absoluteString)
                self.setProcessedReferralEngine()
            case .failure(let error):
                let err = TappError.affiliateServiceError(affiliate: .tapp, underlyingError: error)
                Logger.logError(err)
                completion?(Result.failure(err))
            }
        }
    }

    private func fetchSecretsAndInitializeReferralEngineIfNeeded(completion: VoidCompletion?) {
        guard let config = dependencies.keychainHelper.config else {
            completion?(Result.failure(TappError.missingConfiguration))
            return
        }

        if let completion {
            initializationCompletions.append(completion)
        }

        if secretsDataTask != nil {
            return
        }

        self.secretsDataTask = secrets(config: config) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.initializeAffiliateService(completion: nil)
                self.completeInitializationsWithSuccess()
            case .failure(let error):
                let err = TappError.affiliateServiceError(affiliate: config.affiliate, underlyingError: error)
                Logger.logError(err)
                self.completeInitializations(with: err)
            }
            self.secretsDataTask = nil
        }
    }

    private func completeInitializationsWithSuccess() {
        initializationCompletions.forEach({ $0(.success(()))})
        initializationCompletions.removeAll()
    }

    private func completeInitializations(with error: Error) {
        initializationCompletions.forEach({ $0(.failure(error)) })
        initializationCompletions.removeAll()
    }

    private func secrets(config: TappConfiguration, completion: VoidCompletion?) -> URLSessionDataTaskProtocol? {
        guard let storedConfig = dependencies.keychainHelper.config else {
            completion?(Result.failure(TappError.missingConfiguration))
            return nil
        }

        guard storedConfig.appToken == nil else {
            completion?(Result.success(()))
            return nil
        }

        return dependencies.services.tappService.secrets(affiliate: config.affiliate) { [unowned config, weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                storedConfig.set(appToken: response.secret)
                self.dependencies.keychainHelper.save(config: storedConfig)
                completion?(.success(()))
            case .failure(let error):
                let err = TappError.affiliateServiceError(affiliate: config.affiliate, underlyingError: error)
                Logger.logError(err)
                completion?(Result.failure(err))
            }
        }
    }


    private func appWillOpen(_ url: URL, authToken: String, completion: VoidCompletion?) {
        fetchSecretsAndInitializeReferralEngineIfNeeded { [weak self] result in
            switch result {
            case .success:
                if let storedConfig = self?.dependencies.keychainHelper.config {
                    storedConfig.set(originURL: url)
                    self?.dependencies.keychainHelper.save(config: storedConfig)
                }
                self?.handleReferralCallback(url: url, authToken: authToken, completion: completion)
            case .failure(let error):
                Logger.logError(error)
                completion?(Result.failure(error))
            }
        }
    }

    private func initializeAffiliateService(completion: VoidCompletion?) {
        guard let service = affiliateService else {
            let error = TappError.missingParameters(details: "Affiliate service not configured")
            Logger.logError(error)
            completion?(Result.failure(error))
            return
        }

        guard let storedConfig = KeychainHelper.shared.config else {
            let error = TappError.missingParameters(details:
                                                        "Missing required credentials or bundle identifier")
            Logger.logError(error)
            completion?(Result.failure(error))
            return
        }


        service.initialize(environment: storedConfig.env, completion: completion)
    }

    // MARK: - Referral Engine State Management
    private func setProcessedReferralEngine() {
        guard let storedConfig = dependencies.keychainHelper.config else { return }
        storedConfig.set(hasProcessedReferralEngine: true)
        dependencies.keychainHelper.save(config: storedConfig)
    }

    private func hasProcessedReferralEngine() -> Bool {
        return dependencies.keychainHelper.config?.hasProcessedReferralEngine ?? false
    }
}

private extension Tapp {
    var affiliateService: AffiliateServiceProtocol? {
        guard let config = dependencies.keychainHelper.config else { return nil }

        switch config.affiliate {
        case .tapp:
            return dependencies.services.tappService
        case .adjust:
            return dependencies.services.adjustService
        case .appsflyer:
            return dependencies.services.appsFlyerService
        }
    }
}

private typealias InitializeTappCompletion = (_ result: Result<Void, Error>) -> Void
