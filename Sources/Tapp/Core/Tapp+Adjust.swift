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
        single.dependencies.services.adjustService.getAttribution(completion: completion)
    }

    @objc
    public static func adjustGdprForgetMe() {
        single.dependencies.services.adjustService.gdprForgetMe()
    }

    @objc
    public static func adjustTrackThirdPartySharing(isEnabled: Bool) {
        single.dependencies.services.adjustService.trackThirdPartySharing(isEnabled: isEnabled)
    }

    @objc
    public static func adjustTrackAdRevenue(source: String,
                                     revenue: Double,
                                     currency: String) {
        single.dependencies.services.adjustService.trackAdRevenue(
            source: source, revenue: revenue, currency: currency)
    }

    @objc
    public static func adjustVerifyAppStorePurchase(transactionId: String,
                                             productId: String,
                                                    completion: @escaping (AdjustPurchaseVerificationResult) -> Void) {
        single.dependencies.services.adjustService.verifyAppStorePurchase(transactionId: transactionId,
                                                      productId: productId,
                                                      completion: completion)
    }

    @objc
    public static func adjustSetPushToken(token: String) {
        single.dependencies.services.adjustService.setPushToken(token)
    }

    @objc
    public static func adjustGetAdid(completion: @escaping (String?) -> Void) {
        single.dependencies.services.adjustService.getAdid(completion: completion)
    }

    @objc
    public static func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        single.dependencies.services.adjustService.getIdfa(completion: completion)
    }
}
