import XCTest
@testable import Tapp

final class TappTests: XCTestCase {
    var dependenciesMock: DependenciesMock!
    var sut: Tapp!

    override func setUp() {
        super.setUp()
        dependenciesMock = .init()
        sut = Tapp(dependencies: dependenciesMock.dependencies)
    }

    func testInitializeWithoutConfig() {
        sut.initializeEngine { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                guard let error = error as? TappError else {
                    XCTFail()
                    return
                }
                switch error {
                case .missingConfiguration:
                    break
                default:
                    XCTFail()
                }
            }
        }
    }

    func testMultipleInitializeEngineCalls() async throws {
        dependenciesMock.keychainHelper.config = Self.testConfiguration
        dependenciesMock.tappAffiliateService.secretsTask = URLSessionDataTaskProtocolMock(identifier: 1)

        let expectation1 = self.expectation(description: "initialization1")
        sut.initializeEngine { result in
            expectation1.fulfill()
        }

        let expectation2 = self.expectation(description: "initialization2")

        sut.initializeEngine { result in
            expectation2.fulfill()
        }

        try await Task.sleep(milliseconds: 100)

        dependenciesMock.tappAffiliateService.secretsResponse = SecretsResponse(secret: "123")

        await fulfillment(of: [expectation1, expectation2], timeout: 0.5)

        XCTAssertEqual(dependenciesMock.tappAffiliateService.secretsCalledCount, 1)
    }

    func testFetchURL() async throws {
        dependenciesMock.keychainHelper.config = Self.testConfiguration
        dependenciesMock.tappAffiliateService.secretsTask = URLSessionDataTaskProtocolMock(identifier: 1)
        let expectation = self.expectation(description: "urlFetch")
        let configuration = AffiliateURLConfiguration(influencer: "someID")
        let url = try XCTUnwrap(URL(string: "https://tapp.so"))
        sut.url(config: configuration) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.url, url)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }

        try await Task.sleep(milliseconds: 50)
        
        dependenciesMock.tappAffiliateService.secretsResponse = SecretsResponse(secret: "123")
        dependenciesMock.tappAffiliateService.urlResponse = GeneratedURLResponse(url: url)

        await fulfillment(of: [expectation], timeout: 0.5)
    }
}

extension TappTests {
    static var testConfiguration: TappConfiguration {
        return TappConfiguration(authToken: "authToken",
                                 env: .sandbox,
                                 tappToken: "tappToken",
                                 affiliate: .adjust)
    }
}

fileprivate final class TappDelegateMock: TappDelegate {
    var didOpenApplicationCalled = false
    func didOpenApplication(with data: TappDeferredLinkData) {
        didOpenApplicationCalled = true
    }

    var didFailResolvingURLCalled = false
    func didFailResolvingURL(url: URL, error: Error) {
        didFailResolvingURLCalled = true
    }
}
