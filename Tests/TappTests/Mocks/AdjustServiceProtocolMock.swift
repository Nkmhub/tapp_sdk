import Foundation
@testable import Tapp

protocol AdjustAffiliateServiceProtocol: AffiliateServiceProtocol, AdjustServiceProtocol {}

final class AdjustServiceProtocolMock: AffiliateServiceProtocolMock, AdjustAffiliateServiceProtocol {
    var getIdfvCalled: Bool = false
    func getIdfv(completion: @escaping (String?) -> Void) {
        getIdfvCalled = true
    }

    var enableCalled: Bool = false
    func enable() {
        enableCalled = true
    }

    var disableCalled: Bool = false
    func disable() {
        disableCalled = true
    }

    var isEnabledCalled: Bool = false
    func isEnabled(completion: @escaping (Bool?) -> Void) {
        isEnabledCalled = true
    }

    var switchToOfflineModeCalled: Bool = false
    func switchToOfflineMode() {
        switchToOfflineModeCalled = true
    }

    var switchBackToOnlineModeCalled: Bool = false
    func switchBackToOnlineMode() {
        switchBackToOnlineModeCalled = true
    }

    var sdkVersionCalled: Bool = false
    func sdkVersion(completion: @escaping (String?) -> Void) {
        sdkVersionCalled = true
    }

    var convertUniveralLinkCalled: Bool = false
    func convert(universalLink: URL, with scheme: String) -> URL? {
        convertUniveralLinkCalled = true
        return nil
    }

    var addGlobalCallbackParameterCalled: Bool = false
    func addGlobalCallbackParameter(_ parameter: String, key: String) {
        addGlobalCallbackParameterCalled = true
    }

    var removeGlobalCallbackParameterCalled: Bool = false
    func removeGlobalCallbackParameter(for key: String) {
        removeGlobalCallbackParameterCalled = true
    }

    var removeGlobalCallbackParametersCalled: Bool = false
    func removeGlobalCallbackParameters() {
        removeGlobalCallbackParametersCalled = true
    }

    var addGlobalPartnerParameterCalled: Bool = false
    func addGlobalPartnerParameter(_ parameter: String, key: String) {
        addGlobalPartnerParameterCalled = true
    }

    var removeGlobalPartnerParameterCalled: Bool = false
    func removeGlobalPartnerParameter(for key: String) {
        removeGlobalPartnerParameterCalled = true
    }

    var removeGlobalPartnerParametersCalled: Bool = false
    func removeGlobalPartnerParameters() {
        removeGlobalPartnerParametersCalled = true
    }

    var trackThirdPartySharingCalled: Bool = false
    func trackThirdPartySharing(isEnabled: Bool) {
        trackThirdPartySharingCalled = true
    }

    var trackMeasurementConsentCalled: Bool = false
    func trackMeasurementConsent(_ consent: Bool) {
        trackMeasurementConsentCalled = true
    }

    var trackAppStoreSubscriptionCalled: Bool = false
    func trackAppStoreSubscription(_ subscription: AdjustAppStoreSubscription) {
        trackAppStoreSubscriptionCalled = true
    }

    var requestAppTrackingAuthorizationCalled: Bool = false
    func requestAppTrackingAuthorization(completionHandler: @escaping (UInt?) -> Void) {
        requestAppTrackingAuthorizationCalled = true
    }
    
    func appTrackingAuthorizationStatus() -> Int32 {
        return 0
    }
    
    func updateSkanConversionValue(_ value: Int, coarseValue: String?, lockWindow: NSNumber?, completion: @escaping ((any Error)?) -> Void) {

    }

    var verifyAppStorePurchaseWithTransactionIdCalled: Bool = false
    func verifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        verifyAppStorePurchaseWithTransactionIdCalled = true
    }
    
    func verifyAndTrackAppStorePurchase(with event: AdjustEvent, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {

    }
    
    var getAttributionCalled: Bool = false
    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void) {
        getAttributionCalled = true
    }

    var gdprForgetMeCalled: Bool = false
    func gdprForgetMe() {
        gdprForgetMeCalled = true
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

    var setDeferredLinkDelegateCalled: Bool = false
    func set(deferredLinkDelegate: DeferredLinkDelegate) {
        setDeferredLinkDelegateCalled = true
    }
}
