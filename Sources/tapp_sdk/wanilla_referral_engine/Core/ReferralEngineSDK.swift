import AdjustSdk
import Foundation

public class ReferralEngineSDK {
    private var affiliateService: AffiliateService?
    private var adjustSpecificService: AdjustSpecificService?

    public init() {}

    // MARK: - Configuration
    public func configureAffiliateService(
        affiliate: Affiliate, appToken: String
    ) {
        switch affiliate {
        case .adjust:
            let adjustService = AdjustAffiliateService(appToken: appToken)
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
        KeychainCredentials.appToken = config.appToken
        KeychainCredentials.authToken = config.authToken
        KeychainCredentials.environment = config.env.rawValue
        KeychainCredentials.tappToken = config.tappToken

        if hasProcessedReferralEngine() {
            Logger.logError(ReferralEngineError.alreadyProcessed)
            completion(.failure(.alreadyProcessed))
            return
        }

        guard let service = affiliateService else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Affiliate service not configured")))
            return
        }

        service.initialize(environment: config.env) { [weak self] result in
            switch result {
            case .success:
                self?.handleReferralCallback(
                    url: config.url,
                    authToken: config.authToken,
                    service: service,
                    completion: completion
                )
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
        guard let service = affiliateService else {
            Logger.logError(
                ReferralEngineError.missingParameters(
                    details: "Affiliate service not configured"))
            return
        }

        service.handleEvent(
            eventId: config.eventToken, authToken: KeychainCredentials.authToken
        )
    }

    // MARK: - Generate Affiliate URL
    public func generateAffiliateUrl(
        config: AffiliateUrlConfig,
        completion: @escaping (Result<[String: Any], ReferralEngineError>) ->
            Void
    ) {
        guard let service = affiliateService else {
            completion(
                .failure(
                    .missingParameters(
                        details: "Affiliate service not configured")))
            return
        }

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

    // MARK: - Adjust Specific Features
    public func getAdjustAttribution(
        completion: @escaping (ADJAttribution?) -> Void
    ) {
        adjustSpecificService?.getAttribution(completion: completion)
    }

    public func adjustGdprForgetMe() {
        adjustSpecificService?.gdprForgetMe()
    }

    public func adjustTrackThirdPartySharing(isEnabled: Bool) {
        adjustSpecificService?.trackThirdPartySharing(isEnabled: isEnabled)
    }

    public func adjustTrackAdRevenue(
        source: String, revenue: Double, currency: String
    ) {
        adjustSpecificService?.trackAdRevenue(
            source: source, revenue: revenue, currency: currency)
    }

    public func adjustVerifyAppStorePurchase(
        transactionId: String,
        productId: String,
        completion: @escaping (ADJPurchaseVerificationResult) -> Void
    ) {
        adjustSpecificService?.verifyAppStorePurchase(
            transactionId: transactionId, productId: productId,
            completion: completion)
    }

    public func adjustSetPushToken(token: String) {
        adjustSpecificService?.setPushToken(token)
    }

    public func adjustGetAdid(completion: @escaping (String?) -> Void) {
        adjustSpecificService?.getAdid(completion: completion)
    }

    public func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        adjustSpecificService?.getIdfa(completion: completion)
    }

    // MARK: - Referral Engine State Management
    private func setProcessedReferralEngine() {
        KeychainCredentials.hasProcessedReferralEngine = true
    }

    private func hasProcessedReferralEngine() -> Bool {
        return KeychainCredentials.hasProcessedReferralEngine
    }
}
