//
//  ReferralEngineAdjustSDK.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 12/11/24.
//
import AdjustSdk

extension Tapp {

    // MARK: - Adjust Specific Features

    @objc
    public static func getAdjustAttribution(completion: @escaping (AdjustAttribution?) -> Void) {
        single.getAdjustAttribution(completion: completion)
    }

    func getAdjustAttribution(completion: @escaping (AdjustAttribution?) -> Void) {
        adjustService.getAttribution(completion: completion)
    }

    @objc
    public static func adjustGdprForgetMe() {
        single.adjustGdprForgetMe()
    }

    func adjustGdprForgetMe() {
        adjustService.gdprForgetMe()
    }

    @objc
    public static func adjustTrackThirdPartySharing(isEnabled: Bool) {
        single.adjustTrackThirdPartySharing(isEnabled: isEnabled)
    }

    func adjustTrackThirdPartySharing(isEnabled: Bool) {
        adjustService.trackThirdPartySharing(isEnabled: isEnabled)
    }

    @objc
    public static func adjustTrackAdRevenue(source: String,
                                     revenue: Double,
                                     currency: String) {
        single.adjustTrackAdRevenue(source: source,
                                    revenue: revenue,
                                    currency: currency)
    }

    func adjustTrackAdRevenue(source: String,
                                     revenue: Double,
                                     currency: String) {
        adjustService.trackAdRevenue(source: source,
                                                           revenue: revenue,
                                                           currency: currency)
    }

    @objc
    public static func adjustSetPushToken(token: String) {
        single.adjustSetPushToken(token: token)
    }

    func adjustSetPushToken(token: String) {
        adjustService.setPushToken(token)
    }

    @objc
    public static func adjustGetAdid(completion: @escaping (String?) -> Void) {
        single.adjustGetAdid(completion: completion)
    }

    func adjustGetAdid(completion: @escaping (String?) -> Void) {
        adjustService.getAdid(completion: completion)
    }

    @objc
    public static func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        single.adjustGetIdfa(completion: completion)
    }

    func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        adjustService.getIdfa(completion: completion)
    }

    @objc
    public static func adjustEnable() {
        single.adjustEnable()
    }

    func adjustEnable() {
        adjustService.enable()
    }

    @objc public static func adjustDisable() {
        single.adjustDisable()
    }

    func adjustDisable() {
        adjustService.disable()
    }

    @objc public static func adjustIsEnabled(completion: @escaping (NSNumber) -> Void) {
        single.adjustIsEnabled(completion: completion)
    }

    func adjustIsEnabled(completion: @escaping (NSNumber) -> Void) {
        adjustService.isEnabled { result in
            if let result {
                completion(NSNumber(value: result))
            } else {
                completion(NSNumber(value: false))
            }
        }
    }

    @objc public static func adjustSwitchToOfflineMode() {
        single.adjustSwitchToOfflineMode()
    }

    func adjustSwitchToOfflineMode() {
        adjustService.switchToOfflineMode()
    }

    @objc public static func adjustSwitchBackToOnlineMode() {
        single.adjustSwitchBackToOnlineMode()
    }

    func adjustSwitchBackToOnlineMode() {
        adjustService.switchBackToOnlineMode()
    }

    @objc public static func adjustSdkVersion(completion: @escaping (String?) -> Void) {
        single.adjustSdkVersion(completion: completion)
    }

    func adjustSdkVersion(completion: @escaping (String?) -> Void) {
        adjustService.sdkVersion(completion: completion)
    }

    @objc public static func adjustConvert(universalLink: URL, with scheme: String) -> URL? {
        single.adjustConvert(universalLink: universalLink, with: scheme)
    }

    func adjustConvert(universalLink: URL, with scheme: String) -> URL? {
        adjustService.convert(universalLink: universalLink, with: scheme)
    }

    @objc public static func adjustAddGlobalCallbackParameter(_ parameter: String, key: String) {
        single.adjustAddGlobalCallbackParameter(parameter, key: key)
    }

    func adjustAddGlobalCallbackParameter(_ parameter: String, key: String) {
        adjustService.addGlobalCallbackParameter(parameter, key: key)
    }

    @objc public static func adjustRemoveGlobalCallbackParameter(for key: String) {
        single.adjustRemoveGlobalCallbackParameter(for: key)
    }
    
    func adjustRemoveGlobalCallbackParameter(for key: String) {
        adjustService.removeGlobalCallbackParameter(for: key)
    }

    @objc public static func adjustRemoveGlobalCallbackParameters() {
        single.adjustRemoveGlobalCallbackParameters()
    }

    func adjustRemoveGlobalCallbackParameters() {
        adjustService.removeGlobalCallbackParameters()
    }

    @objc public static func adjustAddGlobalPartnerParameter(_ parameter: String, key: String) {
        single.adjustAddGlobalPartnerParameter(parameter, key: key)
    }

    func adjustAddGlobalPartnerParameter(_ parameter: String, key: String) {
        adjustService.addGlobalPartnerParameter(parameter, key: key)
    }

    @objc public static func adjustRemoveGlobalPartnerParameter(for key: String) {
        single.adjustRemoveGlobalPartnerParameter(for: key)
    }

    func adjustRemoveGlobalPartnerParameter(for key: String) {
        adjustService.removeGlobalPartnerParameter(for: key)
    }

    @objc public static func adjustRemoveGlobalPartnerParameters() {
        single.adjustRemoveGlobalPartnerParameters()
    }

    func adjustRemoveGlobalPartnerParameters() {
        adjustService.removeGlobalPartnerParameters()
    }

    @objc public static func adjustTrackThirdPartySharing(_ thirdPartySharing: AdjustThirdPartySharing) {
        single.adjustTrackThirdPartySharing(thirdPartySharing)
    }

    func adjustTrackThirdPartySharing(_ thirdPartySharing: AdjustThirdPartySharing) {
        adjustService.trackThirdPartySharing(thirdPartySharing)
    }

    @objc public static func adjustTrackMeasurementConsent(_ consent: Bool) {
        single.adjustTrackMeasurementConsent(consent)
    }

    func adjustTrackMeasurementConsent(_ consent: Bool) {
        adjustService.trackMeasurementConsent(consent)
    }

    @objc public static func adjustTrackAdRevenue(_ revenue: AdjustAdRevenue) {
        single.adjustTrackAdRevenue(revenue)
    }

    func adjustTrackAdRevenue(_ revenue: AdjustAdRevenue) {
        adjustService.trackAdRevenue(revenue)
    }

    @objc public static func adjustTrackAppStoreSubscription(_ subscription: AdjustAppStoreSubscription) {
        single.adjustTrackAppStoreSubscription(subscription)
    }

    func adjustTrackAppStoreSubscription(_ subscription: AdjustAppStoreSubscription) {
        adjustService.trackAppStoreSubscription(subscription)
    }

    @objc public static func adjustRequestAppTrackingAuthorization(completionHandler: @escaping (NSNumber?) -> Void) {
        single.adjustRequestAppTrackingAuthorization(completionHandler: completionHandler)
    }

    func adjustRequestAppTrackingAuthorization(completionHandler: @escaping (NSNumber?) -> Void) {
        adjustService.requestAppTrackingAuthorization { value in
            if let value {
                completionHandler(NSNumber(value: value))
            } else {
                completionHandler(nil)
            }
        }
    }

    @objc public static func adjustAppTrackingAuthorizationStatus() -> Int32 {
        single.adjustAppTrackingAuthorizationStatus()
    }

    func adjustAppTrackingAuthorizationStatus() -> Int32 {
        adjustService.appTrackingAuthorizationStatus()
    }

    @objc public static func adjustUpdateSkanConversionValue(_ value: Int, coarseValue: String?, lockWindow: NSNumber?, completion: @escaping (Error?) -> Void) {
        single.adjustUpdateSkanConversionValue(value,
                                               coarseValue: coarseValue,
                                               lockWindow: lockWindow,
                                               completion: completion)
    }
    func adjustUpdateSkanConversionValue(_ value: Int, coarseValue: String?, lockWindow: NSNumber?, completion: @escaping (Error?) -> Void) {
        adjustService.updateSkanConversionValue(value,
                                                coarseValue: coarseValue,
                                                lockWindow: lockWindow,
                                                completion: completion)
    }

    @objc
    public static func adjustVerifyAppStorePurchase(transactionId: String,
                                             productId: String,
                                                    completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        single.adjustVerifyAppStorePurchase(transactionId: transactionId,
                                            productId: productId,
                                            completion: completion)
    }

    func adjustVerifyAppStorePurchase(transactionId: String,
                                             productId: String,
                                                    completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        adjustService.verifyAppStorePurchase(transactionId: transactionId,
                                                      productId: productId,
                                                      completion: completion)
    }

    @objc public static func adjustVerifyAndTrackAppStorePurchase(with event: AdjustEvent, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        single.adjustVerifyAndTrackAppStorePurchase(with: event, completion: completion)
    }

    func adjustVerifyAndTrackAppStorePurchase(with event: AdjustEvent, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        adjustService.verifyAndTrackAppStorePurchase(with: event, completion: completion)
    }

    fileprivate var adjustService: AdjustServiceProtocol {
        return dependencies.services.adjustService
    }
}

enum AdjustURLParamKey: String {
    case token = "adj_t"
}
