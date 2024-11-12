//
//  ReferralEngineAdjustSDK.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 12/11/24.
//
import AdjustSdk

extension ReferralEngineSDK {

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
}
