import Foundation
import AdjustSdk

protocol AdjustInterfaceProtocol {
    func initialize(appToken: String, environment: Environment)
    func processDeepLink(url: URL, completion: ResolvedURLCompletion?)
    func trackEvent(eventID: String) -> Bool

    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void)
    func gdprForgetMe()
    func trackThirdPartySharing(isEnabled: Bool)
    func trackAdRevenue(source: String,
                        revenue: Double,
                        currency: String)
    func verifyAppStorePurchase(transactionId: String,
                                productId: String,
                                completion: @escaping (AdjustPurchaseVerificationResult) -> Void)
    func setPushToken(_ token: String)
    func getAdid(completion: @escaping (String?) -> Void)
    func getIdfa(completion: @escaping (String?) -> Void)
}

final class AdjustInterface: AdjustInterfaceProtocol {
    func initialize(appToken: String,
                    environment: Environment) {
        let adjustConfig = ADJConfig(appToken: appToken,
                                     environment: environment.adjustEnvironment)
        Adjust.initSdk(adjustConfig)
    }

    func processDeepLink(url: URL, completion: ResolvedURLCompletion?) {
        ADJLinkResolution.resolveLink(with: url, resolveUrlSuffixArray: ["adj.st"]) { resolvedURL in
            guard let resolvedURL else {
                completion?(Result.failure(ResolvedURLError.cannotResolveURL))
                return
            }
            guard let deepLink = ADJDeeplink(deeplink: resolvedURL) else {
                completion?(Result.failure(ResolvedURLError.cannotResolveDeepLink))
                return
            }
            Adjust.processDeeplink(deepLink)
            Logger.logInfo("Adjust notified of the incoming URL: \(url)")
            completion?(Result.success(resolvedURL))
        }
    }

    func trackEvent(eventID: String) -> Bool {
        if let event = ADJEvent(eventToken: eventID) {
            Adjust.trackEvent(event)
            return true
        }
        return false
    }

    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void)
    {
        Adjust.attribution { attribution in
            if let attribution = attribution {
                Logger.logInfo("Attribution: \(attribution)")
            } else {
                let error =
                TappError.unknownError(details: "No attribution available.")
                Logger.logError(error)
            }
            completion(AdjustAttribution(adjAttribution: attribution))
        }
    }

    func gdprForgetMe() {
        Adjust.gdprForgetMe()
    }

    func trackThirdPartySharing(isEnabled: Bool) {
        guard
            let thirdPartySharing = ADJThirdPartySharing(
                isEnabled: NSNumber(value: isEnabled))
        else {
            let error = TappError.unknownError(details: "Failed to create ADJThirdPartySharing object.")
            Logger.logError(error)
            return
        }
        Adjust.trackThirdPartySharing(thirdPartySharing)
        Logger.logInfo("Third-party sharing set to: \(isEnabled).")
    }

    func trackAdRevenue(source: String,
                        revenue: Double,
                        currency: String) {
        if let adRevenue = ADJAdRevenue(source: source) {
            adRevenue.setRevenue(revenue, currency: currency)
            Adjust.trackAdRevenue(adRevenue)
            Logger.logInfo("Tracked ad revenue for \(source).")
        } else {
            let error = TappError.unknownError(details:
                    "Failed to create ADJAdRevenue object for source: \(source)."
            )
            Logger.logError(error)
        }
    }

    func verifyAppStorePurchase(transactionId: String,
                                productId: String,
                                completion: @escaping (AdjustPurchaseVerificationResult) -> Void) {
        if let purchase = ADJAppStorePurchase(
            transactionId: transactionId, productId: productId)
        {
            Adjust.verifyAppStorePurchase(purchase) { result in
                Logger.logInfo("Purchase verification result: \(result)")
                completion(AdjustPurchaseVerificationResult(adjResult: result))
            }
        } else {
            let error = TappError.unknownError(details: "Failed to create ADJAppStorePurchase object.")
            Logger.logError(error)
            completion(AdjustPurchaseVerificationResult(adjResult: ADJPurchaseVerificationResult()))  // Pass an empty result
        }
    }

    func setPushToken(_ token: String) {
        Adjust.setPushTokenAs(token)
        Logger.logInfo("Push token set: \(token)")
    }

    func getAdid(completion: @escaping (String?) -> Void) {
        Adjust.adid { adid in
            if let adid = adid {
                Logger.logInfo("ADID: \(adid)")
            } else {
                let error = TappError.unknownError(details: "No ADID available.")
                Logger.logError(error)
            }
            completion(adid)
        }
    }

    func getIdfa(completion: @escaping (String?) -> Void) {
        Adjust.idfa { idfa in
            if let idfa = idfa {
                Logger.logInfo("IDFA: \(idfa)")
            } else {
                let error = TappError.unknownError(details: "No IDFA available.")
                Logger.logError(error)
            }
            completion(idfa)
        }
    }
}

private extension Environment {
    var adjustEnvironment: String {
        switch self {
        case .sandbox:
            return ADJEnvironmentSandbox
        case .production:
            return ADJEnvironmentProduction
        }
    }
}
