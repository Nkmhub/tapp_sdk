import AdjustSdk  // Adjust SDK import
//
//  AdjustAffiliateService.swift
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//
import Foundation

public class AdjustAffiliateService: AffiliateService, AdjustSpecificService {

    private var isInitialized = false
    private let appToken: String  // Store the appToken

    // Initialize with appToken
    public init(appToken: String) {
        self.appToken = appToken
    }

    public func initialize(
        environment: String,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        guard !isInitialized else {
            Logger.logInfo("Adjust is already initialized.")
            completion(.success(()))
            return
        }

        let adjustEnvironment =
            environment == "production"
            ? ADJEnvironmentProduction : ADJEnvironmentSandbox
        let adjustConfig = ADJConfig(
            appToken: appToken, environment: adjustEnvironment)
        Adjust.initSdk(adjustConfig)

        isInitialized = true
        Logger.logInfo("Adjust initialized successfully.")
        completion(.success(()))
    }

    public func handleCallback(with url: String) {
        guard let incomingURL = URL(string: url) else {
            Logger.logError(ReferralEngineError.invalidURL)
            return
        }

        Adjust.processDeeplink(ADJDeeplink(deeplink: incomingURL)!)
        Logger.logInfo("Adjust notified of the incoming URL: \(incomingURL)")
    }

    public func handleEvent(eventId: String, authToken: String?) {
        guard !eventId.isEmpty else {
            Logger.logError(
                ReferralEngineError.missingParameters(
                    details: "Event ID is empty."))
            return
        }

        if let event = ADJEvent(eventToken: eventId) {
            Adjust.trackEvent(event)
            Logger.logInfo("Tracked event on Adjust: \(event.description)")
        } else {
            Logger.logError(
                ReferralEngineError.apiError(
                    message:
                        "Could not create ADJEvent with eventId \(eventId).",
                    endpoint: ""))
        }
    }

    public func affiliateUrl(
        tapp_token: String,
        bundle_id: String,
        mmp: Int,
        adgroup: String,
        creative: String,
        influencer: String,
        authToken: String,
        jsonObject: [String: Any],
        completion: @escaping (Result<[String: Any], ReferralEngineError>) ->
            Void
    ) {
        Logger.logInfo(
            "Handling Adjust callback for custom URL... Not implemented yet.")
        completion(
            .failure(
                .unknownError(
                    details: "Affiliate URL method not implemented for Adjust.")
            ))
    }

    public func handleImpression(
        url: String,
        authToken: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        Logger.logInfo(
            "Handle impression is not implemented. Use Tapp's method.")
        completion(
            .failure(
                ReferralEngineError.unknownError(
                    details:
                        "Impression handling not supported in AdjustAffiliateService."
                )))
    }

    // MARK: - Attribution
    public func getAttribution(completion: @escaping (ADJAttribution?) -> Void)
    {
        Adjust.attribution { attribution in
            if let attribution = attribution {
                Logger.logInfo("Attribution: \(attribution)")
            } else {
                Logger.logError(
                    ReferralEngineError.unknownError(
                        details: "No attribution available."))
            }
            completion(attribution)
        }
    }

    // MARK: - Privacy Compliance
    public func gdprForgetMe() {
        Adjust.gdprForgetMe()
        Logger.logInfo("GDPR Forget Me request sent.")
    }

    public func trackThirdPartySharing(isEnabled: Bool) {
        guard
            let thirdPartySharing = ADJThirdPartySharing(
                isEnabled: NSNumber(value: isEnabled))
        else {
            Logger.logError(
                ReferralEngineError.unknownError(
                    details: "Failed to create ADJThirdPartySharing object."))
            return
        }
        Adjust.trackThirdPartySharing(thirdPartySharing)
        Logger.logInfo("Third-party sharing set to: \(isEnabled).")
    }

    // MARK: - Monetization
    public func trackAdRevenue(
        source: String, revenue: Double, currency: String
    ) {
        if let adRevenue = ADJAdRevenue(source: source) {
            adRevenue.setRevenue(revenue, currency: currency)
            Adjust.trackAdRevenue(adRevenue)
            Logger.logInfo("Tracked ad revenue for \(source).")
        } else {
            Logger.logError(
                ReferralEngineError.unknownError(
                    details:
                        "Failed to create ADJAdRevenue object for source: \(source)."
                ))
        }
    }

    public func verifyAppStorePurchase(
        transactionId: String,
        productId: String,
        completion: @escaping (ADJPurchaseVerificationResult) -> Void
    ) {
        if let purchase = ADJAppStorePurchase(
            transactionId: transactionId, productId: productId)
        {
            Adjust.verifyAppStorePurchase(purchase) { result in
                Logger.logInfo("Purchase verification result: \(result)")
                completion(result)
            }
        } else {
            Logger.logError(
                ReferralEngineError.unknownError(
                    details: "Failed to create ADJAppStorePurchase object."))
            completion(ADJPurchaseVerificationResult())  // Pass an empty result
        }
    }

    // MARK: - Push Token
    public func setPushToken(_ token: String) {
        Adjust.setPushTokenAs(token)
        Logger.logInfo("Push token set: \(token)")
    }

    // MARK: - Device IDs
    public func getAdid(completion: @escaping (String?) -> Void) {
        Adjust.adid { adid in
            if let adid = adid {
                Logger.logInfo("ADID: \(adid)")
            } else {
                Logger.logError(
                    ReferralEngineError.unknownError(
                        details: "No ADID available."))
            }
            completion(adid)
        }
    }

    public func getIdfa(completion: @escaping (String?) -> Void) {
        Adjust.idfa { idfa in
            if let idfa = idfa {
                Logger.logInfo("IDFA: \(idfa)")
            } else {
                Logger.logError(
                    ReferralEngineError.unknownError(
                        details: "No IDFA available."))
            }
            completion(idfa)
        }
    }

    public func test(
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        Logger.logInfo("Unique method on Adjust service executed.")
        completion(.success(["status": "Test method executed"]))
    }
}
