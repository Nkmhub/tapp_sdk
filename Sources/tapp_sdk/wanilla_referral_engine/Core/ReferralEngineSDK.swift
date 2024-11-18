import AdjustSdk
import Foundation

public class ReferralEngineSDK {
    private var affiliateService: AffiliateService?
    internal var adjustSpecificService: AdjustSpecificService?
    internal var tappSpecificService: TappSpecificService?

    public init() {}

    // MARK: - Configuration
    public func configureAffiliateService(config: ReferralEngineInitConfig,
                                          completion: @escaping (Result<Void, ReferralEngineError>) -> Void) {
        let tappService = TappAffiliateService()



        guard let bundleID = config.bundleID else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Missing required bundle identifier")))
            return
        }

        KeychainHelper.shared.save(config: config)

        self.tappSpecificService = tappService

        tappService.getSecrets(authToken: config.authToken,
                               tappToken: config.tappToken,
                               bundleID: bundleID,
                               mmp: config.affiliate) { result in
            guard let storedConfig = KeychainHelper.shared.config else {
                completion(Result.failure(ReferralEngineError.missingConfiguration))
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
                completion(.success(()))
            case .failure(let error):
                // Handle error
                Logger.logError(error)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Process Referral Engine
    public func processReferralEngine(
        config: ReferralEngineConfig,
        completion: @escaping (Result<Void, ReferralEngineError>) -> Void
    ) {
        guard let service = affiliateService else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Affiliate service not configured")))
            return
        }

        guard let storedConfig = KeychainHelper.shared.config else {
            completion(
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
                    completion(.failure(.alreadyProcessed))
                } else {
                    self?.handleReferralCallback(
                        url: config.url,
                        authToken: storedConfig.authToken,
                        service: service,
                        completion: completion
                    )
                }
            case .failure(let error):
                completion(
                    .failure(
                        .initializationFailed(
                            affiliate: storedConfig.affiliate, underlyingError: error)
                    ))
            }
        }
    }

    private func handleReferralCallback(url: String?,
                                        authToken: String,
                                        service: AffiliateService,
                                        completion: @escaping (Result<Void, ReferralEngineError>) -> Void) {
        guard let urlString = url, !urlString.isEmpty else {
            Logger.logError(ReferralEngineError.invalidURL)
            completion(.failure(.invalidURL))
            return
        }

        service.handleCallback(with: urlString)

        guard let storedConfig = KeychainHelper.shared.config, let bundleID = storedConfig.bundleID else {
            Logger.logError(
                ReferralEngineError.missingParameters(
                    details: "Missing required credentials."))
            return
        }

        tappSpecificService?.handleImpression(
            url: urlString,
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
                completion(.success(()))
            case .failure(let error):
                Logger.logError(error)
                completion(
                    .failure(
                        .affiliateServiceError(
                            affiliate: .tapp, underlyingError: error)))
            }
        }
    }

    // MARK: - Handle Event
    public func handleEvent(config: EventConfig) {
        guard let storedConfig = KeychainHelper.shared.config else { return }
        affiliateService?.handleEvent(
            eventId: config.eventToken, authToken: storedConfig.authToken
        )
    }

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

        tappSpecificService?.handleTappEvent(
            authToken: storedConfig.authToken,
            tappToken: storedConfig.tappToken,
            bundleID: bundleID,
            eventName: config.eventName,
            eventAction: config.eventAction.rawValue,
            eventCustomAction: config.eventAction.rawValue == -1 ? config.eventCustomAction : "false"
        )
    }

    // MARK: - Generate Affiliate URL
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
    }

    private func hasProcessedReferralEngine() -> Bool {
        return KeychainHelper.shared.config?.hasProcessedReferralEngine ?? false
    }
}
