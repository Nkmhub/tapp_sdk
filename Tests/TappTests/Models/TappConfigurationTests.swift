import Foundation
import XCTest
@testable import Tapp

final class TappConfigurationTests: XCTestCase {
    func testEquality() {
        var lhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        var rhs = TappConfiguration(authToken: "authToken2", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        XCTAssertFalse(lhs == rhs)

        lhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        rhs = TappConfiguration(authToken: "authToken1", env: .sandbox, tappToken: "tappToken1", affiliate: .adjust)
        XCTAssertFalse(lhs == rhs)

        lhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        rhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken2", affiliate: .adjust)
        XCTAssertFalse(lhs == rhs)

        lhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        rhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .appsflyer)
        XCTAssertFalse(lhs == rhs)

        lhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        rhs = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        XCTAssertTrue(lhs == rhs)
    }

    func testSetAppToken() {
        let config = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        config.set(appToken: "appToken")

        XCTAssertEqual(config.appToken, "appToken")
    }

    func testSetOriginURL() {
        let config = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        let url = URL(string: "https://tapp.com/test")!
        config.set(originURL: url)

        XCTAssertEqual(config.originURL, url)
    }

    func testHasProcessedReferralEngine() {
        let config = TappConfiguration(authToken: "authToken1", env: .production, tappToken: "tappToken1", affiliate: .adjust)
        XCTAssertFalse(config.hasProcessedReferralEngine)
        config.set(hasProcessedReferralEngine: true)
        XCTAssertTrue(config.hasProcessedReferralEngine)
    }
}
