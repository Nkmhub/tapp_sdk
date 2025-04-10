import Foundation
import AdjustSdk

protocol DeferredLinkDelegate: AnyObject {
    func didReceiveDeferredLink(_ url: URL)
}

protocol AdjustInterfaceProtocol: AnyObject {
    var deferredLinkDelegate: DeferredLinkDelegate? { get }
    func set(deferredLinkDelegate: DeferredLinkDelegate)
    
    func initialize(appToken: String, environment: Environment)
    func processDeepLink(url: URL, completion: ResolvedURLCompletion?)
    func trackEvent(eventID: String) -> Bool 

    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void) 
    func gdprForgetMe() 
    func trackThirdPartySharing(isEnabled: Bool) 
    func trackAdRevenue(source: String,
                        revenue: Double,
                        currency: String)

    func setPushToken(_ token: String) 
    func getAdid(completion: @escaping (String?) -> Void) 
    func getIdfa(completion: @escaping (String?) -> Void) 
    func getIdfv(completion: @escaping (String?) -> Void) 

    func enable() 
    func disable() 
    func isEnabled(completion: @escaping (Bool?) -> Void) 
    func switchToOfflineMode() 
    func switchBackToOnlineMode() 
    func sdkVersion(completion: @escaping (String?) -> Void) 
    func convert(universalLink: URL, with scheme: String) -> URL? 
    func addGlobalCallbackParameter(_ parameter: String, key: String) 
    func removeGlobalCallbackParameter(for key: String) 
    func removeGlobalCallbackParameters() 
    func addGlobalPartnerParameter(_ parameter: String, key: String) 
    func removeGlobalPartnerParameter(for key: String) 
    func removeGlobalPartnerParameters() 
    func trackThirdPartySharing(_ thirdPartySharing: AdjustThirdPartySharing) 
    func trackMeasurementConsent(_ consent: Bool) 
    func trackAdRevenue(_ revenue: AdjustAdRevenue) 
    func trackAppStoreSubscription(_ subscription: AdjustAppStoreSubscription) 
    func requestAppTrackingAuthorization(completionHandler: @escaping (UInt?) -> Void) 
    func appTrackingAuthorizationStatus() -> Int32 
    func updateSkanConversionValue(_ value: Int, coarseValue: String?, lockWindow: NSNumber?, completion: @escaping (Error?) -> Void) 

    func verifyAppStorePurchase(transactionId: String,
                                productId: String,
                                completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) 
    func verifyAndTrackAppStorePurchase(with event: AdjustEvent, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) 

}

final class AdjustInterface: NSObject, AdjustInterfaceProtocol {
    weak var deferredLinkDelegate: DeferredLinkDelegate?

    func initialize(appToken: String,
                    environment: Environment) {
        let adjustConfig = ADJConfig(appToken: appToken,
                                     environment: environment.adjustEnvironment)

        adjustConfig?.logLevel = .verbose
        adjustConfig?.delegate = self

        Adjust.initSdk(adjustConfig)
    }

    func set(deferredLinkDelegate: DeferredLinkDelegate) {
        self.deferredLinkDelegate = deferredLinkDelegate
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

    func getIdfv(completion: @escaping (String?) -> Void) {
        Adjust.idfv { idfv in
            if let idfv = idfv {
                Logger.logInfo("IDFV: \(idfv)")
            } else {
                let error = TappError.unknownError(details: "No IDFV available.")
                Logger.logError(error)
            }
            completion(idfv)
        }
    }

    func enable() {
        Adjust.enable()
    }

    func disable() {
        Adjust.disable()
    }

    func isEnabled(completion: @escaping (Bool?) -> Void) {
        Adjust.isEnabled(completionHandler: completion)
    }

    func switchToOfflineMode() {
        Adjust.switchToOfflineMode()
    }

    func switchBackToOnlineMode() {
        Adjust.switchBackToOnlineMode()
    }

    func sdkVersion(completion: @escaping (String?) -> Void) {
        Adjust.sdkVersion(completionHandler: completion)
    }

    func convert(universalLink: URL, with scheme: String) -> URL? {
        return Adjust.convertUniversalLink(universalLink, withScheme: scheme)
    }

    func addGlobalCallbackParameter(_ parameter: String, key: String) {
        Adjust.addGlobalCallbackParameter(parameter, forKey: key)
    }

    func removeGlobalCallbackParameter(for key: String) {
        Adjust.removeGlobalCallbackParameter(forKey: key)
    }

    func removeGlobalCallbackParameters() {
        Adjust.removeGlobalCallbackParameters()
    }

    func addGlobalPartnerParameter(_ parameter: String, key: String) {
        Adjust.addGlobalPartnerParameter(parameter, forKey: key)
    }

    func removeGlobalPartnerParameter(for key: String) {
        Adjust.removeGlobalPartnerParameter(forKey: key)
    }

    func removeGlobalPartnerParameters() {
        Adjust.removeGlobalPartnerParameters()
    }
    func trackThirdPartySharing(_ thirdPartySharing: AdjustThirdPartySharing) {
        if let object = thirdPartySharing.adjObject {
            Adjust.trackThirdPartySharing(object)
        }
    }

    func trackMeasurementConsent(_ consent: Bool) {
        Adjust.trackMeasurementConsent(consent)
    }

    func trackAdRevenue(_ revenue: AdjustAdRevenue) {
        if let object = revenue.adjObject {
            Adjust.trackAdRevenue(object)
        }
    }

    func trackAppStoreSubscription(_ subscription: AdjustAppStoreSubscription) {
        if let object = subscription.adjObject {
            Adjust.trackAppStoreSubscription(object)
        }
    }

    func requestAppTrackingAuthorization(completionHandler: @escaping (UInt?) -> Void) {
        Adjust.requestAppTrackingAuthorization(completionHandler: completionHandler)
    }

    func appTrackingAuthorizationStatus() -> Int32 {
        return Adjust.appTrackingAuthorizationStatus()
    }

    func updateSkanConversionValue(_ value: Int, coarseValue: String?, lockWindow: NSNumber?, completion: @escaping (Error?) -> Void) {
        Adjust.updateSkanConversionValue(value, coarseValue: coarseValue, lockWindow: lockWindow, withCompletionHandler: completion)
    }

    func verifyAppStorePurchase(transactionId: String,
                                productId: String,
                                completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
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
            completion(nil)
        }
    }

    func verifyAndTrackAppStorePurchase(with event: AdjustEvent, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        guard let object = event.adjObject else {
            completion(nil)
            return
        }
        Adjust.verifyAndTrackAppStorePurchase(object) { result in
            let verificationResult = AdjustPurchaseVerificationResult(adjResult: result)
            completion(verificationResult)
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

extension AdjustInterface: AdjustDelegate {
    func adjustDeferredDeeplinkReceived(_ deeplink: URL?) -> Bool {
        if let deeplink {
            deferredLinkDelegate?.didReceiveDeferredLink(deeplink)
        }

        return true
    }
}
