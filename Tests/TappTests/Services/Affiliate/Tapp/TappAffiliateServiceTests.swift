import Foundation
import XCTest
@testable import Tapp

final class TappAffiliateServiceTests: XCTestCase {
    var dependenciesHelper: DependenciesMock!
    var sut: TappAffiliateService!

    override func setUp() {
        super.setUp()

        self.dependenciesHelper = .init()
        sut = TappAffiliateService(keychainHelper: dependenciesHelper.keychainHelper,
                                   networkClient: dependenciesHelper.networkClient)
    }

    func testDidReceiveDeferredURL() throws {
        let url = try XCTUnwrap(URL(string: AdjustMockURL.goLink.rawValue))

        dependenciesHelper.keychainHelper.config = TappTests.testConfiguration

        sut.didReceiveDeferredURL(url, completion: nil)

        let receivedRequest = try XCTUnwrap(dependenciesHelper.networkClient.executeAuthenticatedRequestReceived)
        let body = try XCTUnwrap(receivedRequest.httpBody)
        let decoder = JSONDecoder()
        let linkRequest = try decoder.decode(TappLinkDataRequest.self, from: body)
        XCTAssertEqual(linkRequest.linkToken, "12345678")
    }
}
