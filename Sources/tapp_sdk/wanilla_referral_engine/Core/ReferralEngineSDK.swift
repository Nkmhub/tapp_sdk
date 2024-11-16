import AdjustSdk
import Foundation

public class ReferralEngineSDK {
    private var affiliateService: AffiliateService?
    internal var adjustSpecificService: AdjustSpecificService?
    internal var tappSpecificService: TappSpecificService?

    public init() {}

    // MARK: - Configuration
    public func configureAffiliateService(
        config: ReferralEngineInitConfig,
        completion: @escaping (Result<Void, ReferralEngineError>) -> Void
    ) {
        let tappService = TappAffiliateService()

        // Save parameters to KeychainCredentials
        KeychainCredentials.authToken = config.authToken
        KeychainCredentials.environment = config.env.rawValue
        KeychainCredentials.tappToken = config.tappToken
        KeychainCredentials.environment = config.env.rawValue
        KeychainCredentials.mmp = String(config.affiliate.intValue)

        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Missing required bundle identifier")))
            return
        }

        KeychainCredentials.bundleId = bundleIdentifier

        self.tappSpecificService = tappService
        
        tappService.getSecrets(
            auth_token: config.authToken,
            tapp_token: config.tappToken,
            bundle_id: bundleIdentifier,
            mmp: config.affiliate
        ) { result in
            switch result {
            case .success(let secret):
                KeychainCredentials.appToken = secret
                print("secret: \(secret)")
                print("affiliate service: \(config.affiliate)")
                switch config.affiliate {
                case .adjust:
                    let adjustService = AdjustAffiliateService(appToken: secret)
                    self.affiliateService = adjustService
                    self.adjustSpecificService = adjustService
                    print("Adjust service initialized: \(config.affiliate)")
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
        print("Processing referral engine...")
        guard let service = affiliateService else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Affiliate service not configured")))
            return
        }

        guard let authToken = KeychainCredentials.authToken,
            let env = KeychainCredentials.environment,
            let mmp = KeychainCredentials.mmp
        else {
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
        service.initialize(environment: env) { [weak self] result in
            switch result {
            case .success:
                // Only handle the referral callback if not already processed
                if self?.hasProcessedReferralEngine() == true {
                    Logger.logError(ReferralEngineError.alreadyProcessed)
                    completion(.failure(.alreadyProcessed))
                } else {
                    self?.handleReferralCallback(
                        url: config.url,
                        authToken: authToken,
                        service: service,
                        completion: completion
                    )
                }
            case .failure(let error):
                completion(
                    .failure(
                        .initializationFailed(
                            affiliate: mmp, underlyingError: error)
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
        //TODO:: replace the service with the tapp service
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

    public func handleTappEvent(config: TappEventConfig) {
        guard let authToken = KeychainCredentials.authToken,
            let tappToken = KeychainCredentials.tappToken,
            let bundleIdentifier = KeychainCredentials.bundleId
        else {
            Logger.logError(ReferralEngineError.missingParameters(details: "Missing required credentials or bundle identifier"))
            return
        }

        if config.event_action.rawValue == -1
            && config.event_custom_action == nil
        {
            Logger.logError(ReferralEngineError.eventActionMissing)
            return
        }

        tappSpecificService?.handleTappEvent(
            auth_token: authToken,
            tapp_token: tappToken,
            bundle_id: bundleIdentifier,
            event_name: config.event_name,
            event_action: config.event_action,
            event_custom_action: config.event_action.rawValue == -1
                ? config.event_custom_action : "false"
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
            let bundleIdentifier = KeychainCredentials.bundleId
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
