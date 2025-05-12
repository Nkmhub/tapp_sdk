import Foundation
import XCTest

@testable import Tapp

final class KeychainHelperTests: XCTestCase {
    var subject: KeychainHelper!
    var keychainTool: KeychainToolMock!

    override func setUp() async throws {
        try await super.setUp()
        keychainTool = .init()
        subject = KeychainHelper(keychainTool: keychainTool)
    }

    func testSave() async throws {
        var configuration = TappConfiguration.mock
        subject.save(configuration: configuration)

        var storedConfig = try XCTUnwrap(subject.config)
        XCTAssertNil(storedConfig.originURL)

        let originURL = try XCTUnwrap(URL(string: "https://tapp.so"))
        configuration.set(originURL: originURL)
        subject.save(configuration: configuration)

        storedConfig = try XCTUnwrap(subject.config)
        XCTAssertNotNil(storedConfig.originURL)

        configuration = TappConfiguration.mock
        
        subject.save(configuration: configuration)
        storedConfig = try XCTUnwrap(subject.config)
        XCTAssertNotNil(storedConfig.originURL)
    }
}
