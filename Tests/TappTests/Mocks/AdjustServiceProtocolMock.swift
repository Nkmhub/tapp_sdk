import Foundation
@testable import Tapp

protocol AdjustAffiliateServiceProtocol: AffiliateServiceProtocol, AdjustServiceProtocol {}

final class AdjustServiceProtocolMock: AffiliateServiceProtocolMock, AdjustAffiliateServiceProtocol {

    var getAttributionCalled: Bool = false
    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void) {
        getAttributionCalled = true
    }

    var gdprForgetMeCalled: Bool = false
    func gdprForgetMe() {
        gdprForgetMeCalled = true
    }

    var trackThirdPartySharingCalled: Bool = false
    func trackThirdPartySharing(isEnabled: Bool) {
        trackThirdPartySharingCalled = true
    }

    var trackAdRevenueCalled: Bool = false
    func trackAdRevenue(source: String, revenue: Double, currency: String) {
        trackAdRevenueCalled = true
    }

    var verifyAppStorePurchaseCalled: Bool = false
    func verifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (AdjustPurchaseVerificationResult) -> Void) {
        verifyAppStorePurchaseCalled = true
    }

    var setPushTokenCalled: Bool = false
    func setPushToken(_ token: String) {
        setPushTokenCalled = true
    }

    var getAdidCalled: Bool = false
    func getAdid(completion: @escaping (String?) -> Void) {
        getAdidCalled = true
    }

    var getIdfaCalled: Bool = false
    func getIdfa(completion: @escaping (String?) -> Void) {
        getIdfaCalled = true
    }
}
