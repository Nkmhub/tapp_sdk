import Foundation
import XCTest
@testable import Tapp

final class AdjustAffiliateServiceTests: XCTestCase {
    var subject: AdjustAffiliateService!
    var keychainHelper: KeychainHelperProtocolMock!
    var adjustInterface: AdjustInterfaceProtocolMock!

    override func setUp() {
        super.setUp()
        adjustInterface = AdjustInterfaceProtocolMock()
        keychainHelper = KeychainHelperProtocolMock()
        subject = AdjustAffiliateService(keychainHelper: keychainHelper,
                                         adjustInterface: adjustInterface)
    }

    func testInitialize() {
        let config = TappConfiguration(authToken: "authToken",
                                       env: .sandbox,
                                       tappToken: "tappToken",
                                       affiliate: .adjust)

        keychainHelper.config = config
        subject.initialize(environment: .sandbox,
                           completion: nil)
        XCTAssertFalse(adjustInterface.initializeCalled)

        config.set(appToken: "appToken")

        subject.initialize(environment: .sandbox,
                           completion: nil)
        XCTAssertTrue(adjustInterface.initializeCalled)

        adjustInterface.initializeCalled = false
        subject.initialize(environment: .sandbox,
                           completion: nil)
        XCTAssertFalse(adjustInterface.initializeCalled)
    }

    func testHandleCallback() {
        subject.handleCallback(with: "", completion: nil)
        XCTAssertFalse(adjustInterface.processDeepLinkCalled)
    }

    func testHandleEvent() {
        subject.handleEvent(eventId: "",
                            authToken: nil)
        XCTAssertFalse(adjustInterface.trackEventCalled)

        subject.handleEvent(eventId: "1234",
                            authToken: nil)
        XCTAssertTrue(adjustInterface.trackEventCalled)
    }
}
