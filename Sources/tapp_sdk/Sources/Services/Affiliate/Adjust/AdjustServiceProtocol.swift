//
//  AdjustSpecificService.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

// AdjustSpecificService.swift

import Foundation
import AdjustSdk

protocol AdjustServiceProtocol: AffiliateServiceProtocol {
    func getAttribution(completion: @escaping (ADJAttribution?) -> Void)
    func gdprForgetMe()
    func trackThirdPartySharing(isEnabled: Bool)
    func trackAdRevenue(source: String, revenue: Double, currency: String)
    func verifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (ADJPurchaseVerificationResult) -> Void)
    func setPushToken(_ token: String)
    func getAdid(completion: @escaping (String?) -> Void)
    func getIdfa(completion: @escaping (String?) -> Void)
}
