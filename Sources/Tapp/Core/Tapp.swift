import AdjustSdk
import Foundation

@objc
public class Tapp: NSObject {

    static let single: Tapp = .init()
    let dependencies: Dependencies = .live

    // MARK: - Configuration
    // AppDelegate: Called upon didFinishLaunching

    @objc
    public static func start(config: TappConfiguration) {
        if let storedConfig = KeychainHelper.shared.config, storedConfig != config {
            KeychainHelper.shared.save(config: config)
        }

        single.fetchSecretsAndInitializeReferralEngineIfNeeded(completion: nil)
        
    }
    // MARK: - Process Referral Engine

    //AppDelegate called when receiving a url
    public static func appWillOpen(_ url: URL, completion: VoidCompletion?) {
        guard let config = KeychainHelper.shared.config else {
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
        guard let storedConfig = KeychainHelper.shared.config else { return }
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

    func fetchSecretsAndInitializeReferralEngineIfNeeded(completion: VoidCompletion?) {
        guard let config = KeychainHelper.shared.config else {
            completion?(Result.failure(TappError.missingConfiguration))
            return
        }

        secrets(config: config) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.initializeAffiliateService(completion: completion)
            case .failure(let error):
                let err = TappError.affiliateServiceError(affiliate: config.affiliate, underlyingError: error)
                Logger.logError(err)
                completion?(Result.failure(err))
            }
        }
    }

    private func secrets(config: TappConfiguration, completion: VoidCompletion?) {
        guard let storedConfig = KeychainHelper.shared.config else {
            completion?(Result.failure(TappError.missingConfiguration))
            return
        }

        guard storedConfig.appToken == nil else {
            completion?(Result.success(()))
            return
        }

        dependencies.services.tappService.secrets(affiliate: config.affiliate) { [unowned config] result in
            switch result {
            case .success(let response):
                storedConfig.set(appToken: response.secret)
                KeychainHelper.shared.save(config: storedConfig)
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
                if let storedConfig = KeychainHelper.shared.config {
                    storedConfig.set(originURL: url)
                    KeychainHelper.shared.save(config: storedConfig)
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
        guard let storedConfig = KeychainHelper.shared.config else { return }
        storedConfig.set(hasProcessedReferralEngine: true)
        KeychainHelper.shared.save(config: storedConfig)
    }

    private func hasProcessedReferralEngine() -> Bool {
        return KeychainHelper.shared.config?.hasProcessedReferralEngine ?? false
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
