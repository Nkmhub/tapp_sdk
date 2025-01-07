import Foundation
import XCTest
@testable import Tapp

final class EnumTests: XCTestCase {
    func testAffiliateValues() {
        XCTAssertEqual(Affiliate.adjust.rawValue, 1)
        XCTAssertEqual(Affiliate.appsflyer.rawValue, 2)
        XCTAssertEqual(Affiliate.tapp.rawValue, 3)
    }

    func testEnvironmentValues() {
        XCTAssertEqual(Environment.sandbox.rawValue, 0)
        XCTAssertEqual(Environment.production.rawValue, 1)
    }
}
