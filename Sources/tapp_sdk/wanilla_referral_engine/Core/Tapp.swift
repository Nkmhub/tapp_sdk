import AdjustSdk
import Foundation

public class Tapp {
    static let single: Tapp = .init()
    let dependencies: Dependencies = .live

    private init() {}


    // MARK: - Configuration
    // AppDelegate: Called upon didFinishLaunching
    public static func start(config: ReferralEngineInitConfig) {
        KeychainHelper.shared.save(config: config)
    }
    // MARK: - Process Referral Engine

    //AppDelegate called when receiving a url
    public static func appWillOpen(_ url: URL, completion: VoidCompletion?) {
        single.appWillOpen(url, completion: completion)
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

    //Called when the UI needs to generate a new url
    public static func url(config: AffiliateURLConfiguration,
                    completion: GenerateURLCompletion?) {
        let request = GenerateURLRequest(influencer: config.influencer, adGroup: config.adgroup, creative: config.creative, data: config.data)

        single.dependencies.services.tappService.url(request: request, completion: completion)
    }
}

//MARK: - AppWillOpen + Processing
private extension Tapp {
    private func handleReferralCallback(url: URL?,
                                        authToken: String,
                                        completion: VoidCompletion? = nil) {
        guard let url, !url.absoluteString.isEmpty else {
            Logger.logError(TappError.invalidURL)
            completion?(Result.failure(TappError.invalidURL))
            return
        }

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
    
    private func secrets(config: ReferralEngineInitConfig, completion: VoidCompletion?) {
        dependencies.services.tappService.secrets(affiliate: config.affiliate) { result in
            guard let storedConfig = KeychainHelper.shared.config else {
                completion?(Result.failure(TappError.missingConfiguration))
                return
            }

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


    private func appWillOpen(_ url: URL, completion: VoidCompletion?) { //Add completion for developer
        guard let config = KeychainHelper.shared.config else { return }
        secrets(config: config) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.processReferralEngine(url: url) { processResult in
                    switch processResult {
                    case .success:
                        completion?(Result.success(()))
                    case .failure(let error):
                        completion?(self.affiliateErrorResult(error: error, affiliate: config.affiliate))
                    }
                }
            case .failure(let error):
                completion?(self.affiliateErrorResult(error: error, affiliate: config.affiliate))
            }
        }
    }

    private func processReferralEngine(
        url: URL,
        completion: VoidCompletion? = nil) {
        guard let service = affiliateService else {
            completion?(Result.failure(TappError.missingParameters(details: "Affiliate service not configured")))
            return
        }

        guard let storedConfig = KeychainHelper.shared.config else {
            completion?(Result.failure(TappError.missingParameters(details:
                            "Missing required credentials or bundle identifier")))
            return
        }

        // Always initialize the affiliate service
        service.initialize(environment: storedConfig.env) { [weak self] result in
            switch result {
            case .success:
                // Only handle the referral callback if not already processed
                if self?.hasProcessedReferralEngine() == true {
                    Logger.logError(TappError.alreadyProcessed)
                    completion?(.failure(TappError.alreadyProcessed))
                } else {
                    self?.handleReferralCallback(
                        url: url,
                        authToken: storedConfig.authToken,
                        completion: completion
                    )
                }
            case .failure(let error):
                completion?(
                    .failure(
                        TappError.initializationFailed(
                            affiliate: storedConfig.affiliate, underlyingError: error)
                    ))
            }
        }
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
