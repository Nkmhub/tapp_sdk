//
//  ReferralEngineAdjustSDK.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 12/11/24.
//
import AdjustSdk

extension ReferralEngineSDK {

    // MARK: - Adjust Specific Features

    public func getAdjustAttribution(completion: @escaping (ADJAttribution?) -> Void) {
        dependencies.services.adjustService.getAttribution(completion: completion)
    }

    public func adjustGdprForgetMe() {
        dependencies.services.adjustService.gdprForgetMe()
    }

    public func adjustTrackThirdPartySharing(isEnabled: Bool) {
        dependencies.services.adjustService.trackThirdPartySharing(isEnabled: isEnabled)
    }

    public func adjustTrackAdRevenue(source: String,
                                     revenue: Double,
                                     currency: String) {
        dependencies.services.adjustService.trackAdRevenue(
            source: source, revenue: revenue, currency: currency)
    }

    public func adjustVerifyAppStorePurchase(transactionId: String,
                                             productId: String,
                                             completion: @escaping (ADJPurchaseVerificationResult) -> Void) {
        dependencies.services.adjustService.verifyAppStorePurchase(transactionId: transactionId,
                                                      productId: productId,
                                                      completion: completion)
    }

    public func adjustSetPushToken(token: String) {
        dependencies.services.adjustService.setPushToken(token)
    }

    public func adjustGetAdid(completion: @escaping (String?) -> Void) {
        dependencies.services.adjustService.getAdid(completion: completion)
    }

    public func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        dependencies.services.adjustService.getIdfa(completion: completion)
    }
}
