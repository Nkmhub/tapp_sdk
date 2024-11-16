import AdjustSdk
import Foundation

public class ReferralEngineSDK {
    private var affiliateService: AffiliateService?
    internal var adjustSpecificService: AdjustSpecificService?
    private var tappSpecificService: TappSpecificService?

    public init() {}

    // MARK: - Configuration
    public func configureAffiliateService(
        affiliate: Affiliate, appToken: String
    ) {
        switch affiliate {
        case .adjust:
            let adjustService = AdjustAffiliateService(appToken: appToken)
            KeychainCredentials.appToken = appToken
            self.affiliateService = adjustService
            self.adjustSpecificService = adjustService
        case .tapp:
            self.affiliateService = TappAffiliateService()
        case .appsflyer:
            self.affiliateService = AppsflyerAffiliateService()
        }
    }

    // MARK: - Process Referral Engine
    public func processReferralEngine(
        config: ReferralEngineConfig,
        completion: @escaping (Result<Void, ReferralEngineError>) -> Void
    ) {
        // Save parameters to KeychainCredentials
        KeychainCredentials.authToken = config.authToken
        KeychainCredentials.environment = config.env.rawValue
        KeychainCredentials.tappToken = config.tappToken

        guard let service = affiliateService else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Affiliate service not configured")))
            return
        }

        // Always initialize the affiliate service
        service.initialize(environment: config.env) { [weak self] result in
            switch result {
            case .success:
                // Only handle the referral callback if not already processed
                if self?.hasProcessedReferralEngine() == true {
                    Logger.logError(ReferralEngineError.alreadyProcessed)
                    completion(.failure(.alreadyProcessed))
                } else {
                    self?.handleReferralCallback(
                        url: config.url,
                        authToken: config.authToken,
                        service: service,
                        completion: completion
                    )
                }
            case .failure(let error):
                completion(
                    .failure(
                        .initializationFailed(
                            affiliate: config.affiliate, underlyingError: error)
                    ))
            }
        }
    }

    private func handleReferralCallback(
        url: String?,
        authToken: String,
        service: AffiliateService,
        completion: @escaping (Result<Void, ReferralEngineError>) -> Void
    ) {
        guard let urlString = url, !urlString.isEmpty else {
            Logger.logError(ReferralEngineError.invalidURL)
            completion(.failure(.invalidURL))
            return
        }

        service.handleCallback(with: urlString)

        service.handleImpression(url: urlString, authToken: authToken) {
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
        let service: AffiliateService

        // Initialize the service based on the affiliate
        switch config.affiliate {
        case .adjust:
            service = AdjustAffiliateService(
                appToken: KeychainCredentials.appToken ?? "")
        case .tapp:
            service = TappAffiliateService()
        case .appsflyer:
            service = AppsflyerAffiliateService()
        }

        service.handleEvent(
            eventId: config.eventToken, authToken: KeychainCredentials.authToken
        )
    }
    
    public func handleTappEvent(
        config: TappEventConfig,
        completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void
    ) {
        guard let authToken = KeychainCredentials.authToken,
              let tappToken = KeychainCredentials.tappToken,
              let bundleIdentifier = Bundle.main.bundleIdentifier else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Missing required credentials or bundle identifier"
                    )
                )
            )
            return
        }

        // **Add the required check here**
        if config.event_action.rawValue == -1 && config.event_custom_action == nil {
            completion(
                .failure(
                    .missingParameters(
                        details: "event_custom_action is required when event_action is -1"
                    )
                )
            )
            return
        }
        
        tappSpecificService?.handleTappEvent(
            auth_token: authToken,
            tapp_token: tappToken,
            bundle_id: bundleIdentifier,
            event_name: config.event_name,
            event_action: config.event_action,
            event_custom_action: config.event_action.rawValue == -1 ? config.event_custom_action : "false",
            completion: completion
        )
    }


    // MARK: - Generate Affiliate URL
    public func generateAffiliateUrl(
        config: AffiliateUrlConfig,
        completion: @escaping (Result<[String: Any], ReferralEngineError>) ->
            Void
    ) {
        let service: AffiliateService = TappAffiliateService()

        // Proceed with generating the affiliate URL
        guard let authToken = KeychainCredentials.authToken,
            let tappToken = KeychainCredentials.tappToken,
            let bundleIdentifier = Bundle.main.bundleIdentifier
        else {
            completion(
                .failure(
                    .missingParameters(
                        details:
                            "Missing required credentials or bundle identifier")
                ))
            return
        }

        // Use 'service' to call affiliateUrl
        service.affiliateUrl(
            tapp_token: tappToken,
            bundle_id: bundleIdentifier,
            mmp: config.mmp.intValue,
            adgroup: config.adgroup,
            creative: config.creative,
            influencer: config.influencer,
            authToken: authToken,
            jsonObject: config.jsonObject,
            completion: completion
        )
    }
    
    // MARK: - Referral Engine State Management
    private func setProcessedReferralEngine() {
        KeychainCredentials.hasProcessedReferralEngine = true
    }

    private func hasProcessedReferralEngine() -> Bool {
        return KeychainCredentials.hasProcessedReferralEngine
    }
}
