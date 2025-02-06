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
        dependencies.services.adjustService.getAttribution(completion: completion)
    }

    @objc
    public static func adjustGdprForgetMe() {
        single.adjustGdprForgetMe()
    }

    func adjustGdprForgetMe() {
        dependencies.services.adjustService.gdprForgetMe()
    }

    @objc
    public static func adjustTrackThirdPartySharing(isEnabled: Bool) {
        single.adjustTrackThirdPartySharing(isEnabled: isEnabled)
    }

    func adjustTrackThirdPartySharing(isEnabled: Bool) {
        dependencies.services.adjustService.trackThirdPartySharing(isEnabled: isEnabled)
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
        dependencies.services.adjustService.trackAdRevenue(source: source,
                                                           revenue: revenue,
                                                           currency: currency)
    }

    @objc
    public static func adjustVerifyAppStorePurchase(transactionId: String,
                                             productId: String,
                                                    completion: @escaping (AdjustPurchaseVerificationResult) -> Void) {
        single.adjustVerifyAppStorePurchase(transactionId: transactionId,
                                            productId: productId,
                                            completion: completion)
    }

    func adjustVerifyAppStorePurchase(transactionId: String,
                                             productId: String,
                                                    completion: @escaping (AdjustPurchaseVerificationResult) -> Void) {
        dependencies.services.adjustService.verifyAppStorePurchase(transactionId: transactionId,
                                                      productId: productId,
                                                      completion: completion)
    }

    @objc
    public static func adjustSetPushToken(token: String) {
        single.adjustSetPushToken(token: token)
    }

    func adjustSetPushToken(token: String) {
        dependencies.services.adjustService.setPushToken(token)
    }

    @objc
    public static func adjustGetAdid(completion: @escaping (String?) -> Void) {
        single.adjustGetAdid(completion: completion)
    }

    func adjustGetAdid(completion: @escaping (String?) -> Void) {
        dependencies.services.adjustService.getAdid(completion: completion)
    }

    @objc
    public static func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        single.adjustGetIdfa(completion: completion)
    }

    func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        dependencies.services.adjustService.getIdfa(completion: completion)
    }
}

enum AdjustURLParamKey: String {
    case token = "adj_t"
}
