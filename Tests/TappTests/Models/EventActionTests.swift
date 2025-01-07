import Foundation
import XCTest
@testable import Tapp

final class EventActionTests: XCTestCase {
    func testEnumCases() {
        XCTAssertEqual(EventAction.allCases, allExpectedCases)
    }

    func testValidity() {
        XCTAssertTrue(EventAction.addPaymentInfo.isValid)
        XCTAssertFalse(EventAction.custom("").isValid)
        XCTAssertTrue(EventAction.custom("some value").isValid)
    }

    func testCustom() {
        XCTAssertFalse(EventAction.addPaymentInfo.isCustom)
        XCTAssertTrue(EventAction.custom("").isCustom)
        XCTAssertTrue(EventAction.custom("some value").isCustom)
    }

    func testName() {
        XCTAssertEqual(EventAction.addToCart.name, "tapp_add_to_cart")
        XCTAssertEqual(EventAction.custom("value1").name, "value1")
    }
}

private extension EventActionTests {
    var allExpectedCases: [EventAction] {
        [
            .addPaymentInfo,
            .addToCart,
            .addToWishlist,
            .completeRegistration,
            .contact,
            .customizeProduct,
            .donate,
            .findLocation,
            .initiateCheckout,
            .generateLead,
            .purchase,
            .schedule,
            .search,
            .startTrial,
            .submitApplication,
            .subscribe,
            .viewContent,
            .clickButton,
            .downloadFile,
            .joinGroup,
            .achieveLevel,
            .createGroup,
            .createRole,
            .linkClick,
            .linkImpression,
            .applyForLoan,
            .loanApproval,
            .loanDisbursal,
            .login,
            .rate,
            .spendCredits,
            .unlockAchievement,
            .addShippingInfo,
            .earnVirtualCurrency,
            .startLevel,
            .completeLevel,
            .postScore,
            .selectContent,
            .beginTutorial,
            .completeTutorial
        ]
    }
}
