import AdjustSdk
import Foundation

public class Tapp {
    static let single: Tapp = .init()
    let dependencies: Dependencies = .live

    private init() {}


    // MARK: - Configuration
    // AppDelegate: Called upon didFinishLaunching
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
            completion?(Result.failure(TappError.missingConfiguration))
            return
        }

        single.appWillOpen(url, authToken: config.authToken, completion: completion)
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

    // MARK: - Handle Event
    //For MMP Specific events
    public static func handleEvent(config: EventConfig) {
        guard let storedConfig = KeychainHelper.shared.config else { return }
        single.affiliateService?.handleEvent(eventId: config.eventToken,
                                             authToken: storedConfig.authToken)
    }

    //For Tapp Events
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
                completion?(self.affiliateErrorResult(error: error, affiliate: .tapp))
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
                completion?(self.affiliateErrorResult(error: error, affiliate: config.affiliate))
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
                completion?(self.affiliateErrorResult(error: error, affiliate: config.affiliate))
            }
        }
    }


    private func appWillOpen(_ url: URL, authToken: String, completion: VoidCompletion?) {
        fetchSecretsAndInitializeReferralEngineIfNeeded { [weak self] result in
            switch result {
            case .success:
                self?.handleReferralCallback(url: url, authToken: authToken, completion: completion)
            case .failure(let error):
                completion?(Result.failure(error))
            }
        }
    }

    private func initializeAffiliateService(completion: VoidCompletion?) {
        guard let service = affiliateService else {
            completion?(Result.failure(TappError.missingParameters(details: "Affiliate service not configured")))
            return
        }

        guard let storedConfig = KeychainHelper.shared.config else {
            completion?(Result.failure(TappError.missingParameters(details:
                            "Missing required credentials or bundle identifier")))
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

    private func affiliateErrorResult(error: any Error, affiliate: Affiliate) -> Result<Void, Error> {
        return Result.failure(TappError.affiliateServiceError(affiliate: affiliate, underlyingError: error))
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
