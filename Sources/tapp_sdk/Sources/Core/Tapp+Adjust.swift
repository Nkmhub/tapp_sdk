//
//  ReferralEngineAdjustSDK.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 12/11/24.
//
import AdjustSdk

extension Tapp {

    // MARK: - Adjust Specific Features

    public static func getAdjustAttribution(completion: @escaping (ADJAttribution?) -> Void) {
        single.dependencies.services.adjustService.getAttribution(completion: completion)
    }

    public static func adjustGdprForgetMe() {
        single.dependencies.services.adjustService.gdprForgetMe()
    }

    public static func adjustTrackThirdPartySharing(isEnabled: Bool) {
        single.dependencies.services.adjustService.trackThirdPartySharing(isEnabled: isEnabled)
    }

    public static func adjustTrackAdRevenue(source: String,
                                     revenue: Double,
                                     currency: String) {
        single.dependencies.services.adjustService.trackAdRevenue(
            source: source, revenue: revenue, currency: currency)
    }

    public static func adjustVerifyAppStorePurchase(transactionId: String,
                                             productId: String,
                                             completion: @escaping (ADJPurchaseVerificationResult) -> Void) {
        single.dependencies.services.adjustService.verifyAppStorePurchase(transactionId: transactionId,
                                                      productId: productId,
                                                      completion: completion)
    }

    public static func adjustSetPushToken(token: String) {
        single.dependencies.services.adjustService.setPushToken(token)
    }

    public static func adjustGetAdid(completion: @escaping (String?) -> Void) {
        single.dependencies.services.adjustService.getAdid(completion: completion)
    }

    public static func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        single.dependencies.services.adjustService.getIdfa(completion: completion)
    }
}
