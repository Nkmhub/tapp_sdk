import Foundation
import XCTest
@testable import Tapp

enum AdjustMockURL: String {
    case goLink = "https://test.go.link/?adj_t=12345678&adj_label=someCustomParam"
    case scheme = "testScheme://?adj_t=12345678&adj_label=someCustomParam&adjust_no_sdkclick=1"
}

final class AdjustInterfaceTests: XCTestCase {
    var sut: AdjustInterface!

    override func setUp() {
        super.setUp()
        sut = AdjustInterface()
    }

    func testAdjustDelegateDeferredLinkReceived() {
        let delegate = DeferredLinkDelegateMock()
        sut.deferredLinkDelegate = delegate

        _ = sut.adjustDeferredDeeplinkReceived(nil)
        XCTAssertFalse(delegate.didReceiveDeferredLinkCalled)
        XCTAssertNil(delegate.didReceiveDeferredLinkURL)

        _ = sut.adjustDeferredDeeplinkReceived(URL(string: AdjustMockURL.goLink.rawValue))
        XCTAssertTrue(delegate.didReceiveDeferredLinkCalled)
        XCTAssertEqual(URL(string: AdjustMockURL.goLink.rawValue), delegate.didReceiveDeferredLinkURL)
    }
}

fileprivate final class DeferredLinkDelegateMock: DeferredLinkDelegate {
    var didReceiveDeferredLinkCalled: Bool = false
    var didReceiveDeferredLinkURL: URL?
    func didReceiveDeferredLink(_ url: URL) {
        didReceiveDeferredLinkCalled = true
        didReceiveDeferredLinkURL = url
    }
}
