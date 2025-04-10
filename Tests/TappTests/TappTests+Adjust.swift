import XCTest
@testable import Tapp

extension TappTests {
    func testGetAdjustAttribution() {
        sut.getAdjustAttribution { _ in }
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.getAttributionCalled)
    }

    func testAdjustGdprForgetMe() {
        sut.adjustGdprForgetMe()
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.gdprForgetMeCalled)
    }

    func testAdjustTrackThirdPartySharing() {
        sut.adjustTrackThirdPartySharing(isEnabled: false)
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.trackThirdPartySharingCalled)
    }

    func testAdjustTrackAdRevenue() {
        sut.adjustTrackAdRevenue(source: .empty,
                                 revenue: 0,
                                 currency: .empty)
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.trackAdRevenueCalled)
    }

    func testAdjustVerifyAppStorePurchase() {
        sut.adjustVerifyAppStorePurchase(transactionId: .empty, productId: .empty) { _ in }
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.verifyAppStorePurchaseWithTransactionIdCalled)
    }

    func testAdjustSetPushToken() {
        sut.adjustSetPushToken(token: .empty)
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.setPushTokenCalled)
    }

    func testAdjustGetAdid() {
        sut.adjustGetAdid { _ in }
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.getAdidCalled)
    }

    func testAdjustGetIdfa() {
        sut.adjustGetIdfa { _ in }
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.getIdfaCalled)
    }
}

private extension String {
    static var empty: String {
        return ""
    }
}
