//
//  AdjustAffiliateService.swift
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//
import Foundation
import AdjustSdk


public class AdjustAffiliateService: AdjustServiceProtocol {

    private var isInitialized = false
    private let keychainHelper: KeychainHelperProtocol
    private let networkClient: NetworkClientProtocol

    // Initialize with appToken
    init(keychainHelper: KeychainHelperProtocol,
         networkClient: NetworkClientProtocol) {
        self.keychainHelper = keychainHelper
        self.networkClient = networkClient
    }

    public func initialize(
        environment: Environment,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        guard !isInitialized else {
            Logger.logInfo("Adjust is already initialized.")
            completion(.success(()))
            return
        }

        guard let token = keychainHelper.config?.appToken else {
            completion(Result.failure(AffiliateServiceError.missingToken))
            return
        }

        let adjustConfig = ADJConfig(appToken: token,
                                     environment: environment.adjustEnvironment)
        Adjust.initSdk(adjustConfig)

        isInitialized = true
        Logger.logInfo("Adjust initialized successfully.")
        completion(.success(()))
    }

    public func handleCallback(with url: String) {
        guard let incomingURL = URL(string: url) else {
            Logger.logError(TappError.invalidURL)
            return
        }

        Adjust.processDeeplink(ADJDeeplink(deeplink: incomingURL)!)
        Logger.logInfo("Adjust notified of the incoming URL: \(incomingURL)")
    }

    public func handleEvent(eventId: String, authToken: String?) {
        guard !eventId.isEmpty else {
            Logger.logError(
                TappError.missingParameters(
                    details: "Event ID is empty."))
            return
        }

        if let event = ADJEvent(eventToken: eventId) {
            Adjust.trackEvent(event)
            Logger.logInfo("Tracked event on Adjust: \(event.description)")
        } else {
            Logger.logError(
                TappError.apiError(
                    message:
                        "Could not create ADJEvent with eventId \(eventId).",
                    endpoint: ""))
        }
    }

    // MARK: - Attribution
    public func getAttribution(completion: @escaping (ADJAttribution?) -> Void)
    {
        Adjust.attribution { attribution in
            if let attribution = attribution {
                Logger.logInfo("Attribution: \(attribution)")
            } else {
                Logger.logError(
                    TappError.unknownError(
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
                TappError.unknownError(
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
                TappError.unknownError(
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
                TappError.unknownError(
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
                    TappError.unknownError(
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
                    TappError.unknownError(
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

private extension Environment {
    var adjustEnvironment: String {
        switch self {
        case .sandbox:
            return ADJEnvironmentProduction
        case .production:
            return ADJEnvironmentSandbox
        }
    }
}
