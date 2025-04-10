//
//  AdjustSpecificService.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

// AdjustSpecificService.swift

import Foundation
import AdjustSdk

protocol AdjustServiceProtocol: AffiliateServiceProtocol {
    func set(deferredLinkDelegate: DeferredLinkDelegate)
    
    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void)
    func gdprForgetMe()
    func trackThirdPartySharing(isEnabled: Bool)
    func trackAdRevenue(source: String, revenue: Double, currency: String)
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
    func verifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void)
    func verifyAndTrackAppStorePurchase(with event: AdjustEvent, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void)
}
