import AdjustSdk
import Foundation

public typealias ReferralEngineCompletion = (_ result: Result<Void, ReferralEngineError>) -> Void

public class ReferralEngineSDK {
    private static let single: ReferralEngineSDK = .init()

    private var affiliateService: AffiliateService?
    private var adjustSpecificService: AdjustSpecificService?
    private let tappAffiliateService = TappAffiliateService()

    private init() {}

    internal var adjustService: AdjustSpecificService? {
        return adjustSpecificService
    }

    // MARK: - Configuration
    // AppDelegate: Called upon didFinishLaunching
    public static func start(config: ReferralEngineInitConfig) {
        KeychainHelper.shared.save(config: config)
    }

    private func secrets(config: ReferralEngineInitConfig, completion: ReferralEngineCompletion?) {
        guard let bundleID = config.bundleID else {
            completion?(.failure(.missingParameters(details: "Missing required bundle identifier")))

            return
        }

        tappAffiliateService.getSecrets(authToken: config.authToken,
                               tappToken: config.tappToken,
                               bundleID: bundleID,
                               mmp: config.affiliate) { result in
            guard let storedConfig = KeychainHelper.shared.config else {
                completion?(Result.failure(ReferralEngineError.missingConfiguration))
                return
            }
            switch result {
            case .success(let secret):
                storedConfig.set(appToken: secret)
                KeychainHelper.shared.save(config: storedConfig)
                switch config.affiliate {
                case .adjust:
                    let adjustService = AdjustAffiliateService(appToken: secret)
                    self.affiliateService = adjustService
                    self.adjustSpecificService = adjustService
                case .tapp:
                    self.affiliateService = TappAffiliateService()
                case .appsflyer:
                    self.affiliateService = AppsflyerAffiliateService()
                }
                completion?(.success(()))
            case .failure(let error):
                // Handle error
                Logger.logError(error)
                completion?(.failure(error))
            }
        }
    }

    // MARK: - Process Referral Engine

    //AppDelegate called when receiving a url
    public static func appWillOpen(_ url: URL) {
        single.appWillOpen(url)
    }

    private func appWillOpen(_ url: URL) { //Add completion for developer
        guard let config = KeychainHelper.shared.config else { return }
        secrets(config: config) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.processReferralEngine(url: url) { processResult in
                    switch processResult {
                    case .success:
                        break
                    case .failure(let error):
                        break
                    }
                }
            case .failure(let error):
                break
            }
        }
    }

    private func processReferralEngine(
        url: URL,
        completion: ReferralEngineCompletion? = nil) {
        guard let service = affiliateService else {
            completion?(
                .failure(
                    .missingParameters(
                        details: "Affiliate service not configured")))
            return
        }

        guard let storedConfig = KeychainHelper.shared.config else {
            completion?(
                .failure(
                    .missingParameters(
                        details:
                            "Missing required credentials or bundle identifier"
                    )
                )
            )
            return
        }

        // Always initialize the affiliate service
        service.initialize(environment: storedConfig.env) { [weak self] result in
            switch result {
            case .success:
                // Only handle the referral callback if not already processed
                if self?.hasProcessedReferralEngine() == true {
                    Logger.logError(ReferralEngineError.alreadyProcessed)
                    completion?(.failure(.alreadyProcessed))
                } else {
                    self?.handleReferralCallback(
                        url: url,
                        authToken: storedConfig.authToken,
                        service: service,
                        completion: completion
                    )
                }
            case .failure(let error):
                completion?(
                    .failure(
                        .initializationFailed(
                            affiliate: storedConfig.affiliate, underlyingError: error)
                    ))
            }
        }
    }

    private func handleReferralCallback(url: URL?,
                                        authToken: String,
                                        service: AffiliateService,
                                        completion: ReferralEngineCompletion? = nil) {
        guard let url, !url.absoluteString.isEmpty else {
            Logger.logError(ReferralEngineError.invalidURL)
            completion?(.failure(.invalidURL))
            return
        }

        service.handleCallback(with: url.absoluteString)

        guard let storedConfig = KeychainHelper.shared.config, let bundleID = storedConfig.bundleID else {
            Logger.logError(
                ReferralEngineError.missingParameters(
                    details: "Missing required credentials."))
            return
        }

        tappAffiliateService.handleImpression(
            url: url.absoluteString,
            authToken: authToken,
            tappToken: storedConfig.tappToken,
            bundleID: bundleID
        ) {
            [weak self] result in
            switch result {
            case .success:
                Logger.logInfo(
                    "Referral engine impression handled successfully.")
                self?.setProcessedReferralEngine()
                completion?(.success(()))
            case .failure(let error):
                Logger.logError(error)
                completion?(Result.failure(.affiliateServiceError(affiliate: .tapp, underlyingError: error)))
            }
        }
    }

    // MARK: - Handle Event
    //For MMP Specific events
    public func handleEvent(config: EventConfig) {
        guard let storedConfig = KeychainHelper.shared.config else { return }
        affiliateService?.handleEvent(
            eventId: config.eventToken, authToken: storedConfig.authToken
        )
    }

    //For Tapp Events
    public func handleTappEvent(config: TappEventConfig) {
        guard let storedConfig = KeychainHelper.shared.config, let bundleID = storedConfig.bundleID else {
            Logger.logError(
                ReferralEngineError.missingParameters(
                    details: "Missing required credentials."))
            return
        }

        if config.eventAction.isCustom && config.eventCustomAction == nil
        {
            Logger.logError(ReferralEngineError.eventActionMissing)
            return
        }

        tappAffiliateService.handleTappEvent(
            authToken: storedConfig.authToken,
            tappToken: storedConfig.tappToken,
            bundleID: bundleID,
            eventName: config.eventName,
            eventAction: config.eventAction.rawValue,
            eventCustomAction: config.eventAction.rawValue == -1 ? config.eventCustomAction : "false"
        )
    }

    // MARK: - Generate Affiliate URL
    //Called when the UI needs to generate a new url
    public func generateAffiliateUrl(config: AffiliateUrlConfig,
                                     completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void) {
        let service: AffiliateService = TappAffiliateService()

        guard let storedConfig = KeychainHelper.shared.config, let bundleID = storedConfig.bundleID else {
            completion(
                .failure(
                    .missingParameters(
                        details:
                            "Missing required credentials")
                ))
            return
        }

        // Use 'service' to call affiliateUrl
        service.affiliateUrl(
            tappToken: storedConfig.tappToken,
            bundleID: bundleID,
            mmp: config.mmp.intValue,
            adgroup: config.adgroup,
            creative: config.creative,
            influencer: config.influencer,
            authToken: storedConfig.authToken,
            jsonObject: config.jsonObject,
            completion: completion
        )
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
