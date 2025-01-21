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
        dependenciesMock.keychainHelper.config = testConfiguration
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

    func testAppWillOpen() async throws {
        dependenciesMock.keychainHelper.config = testConfiguration
        dependenciesMock.tappAffiliateService.secretsTask = URLSessionDataTaskProtocolMock(identifier: 1)
        XCTAssertEqual(dependenciesMock.keychainHelper.config?.hasProcessedReferralEngine, false)

        let url = try XCTUnwrap(URL(string: "https://tapp.so"))

        let expectation = self.expectation(description: "appWillOpen")
        sut.appWillOpen(url, authToken: "authToken") { result in
            expectation.fulfill()
        }

        try await Task.sleep(milliseconds: 50)

        dependenciesMock.tappAffiliateService.secretsResponse = SecretsResponse(secret: "123")

        await fulfillment(of: [expectation], timeout: 0.5)
        XCTAssertEqual(dependenciesMock.keychainHelper.config?.originURL, url)
        XCTAssertEqual(dependenciesMock.keychainHelper.config?.hasProcessedReferralEngine, true)
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.handleCallbackCalled)
    }

    func testInitializeAndAppWillOpenSimultaneously() async throws {
        dependenciesMock.keychainHelper.config = testConfiguration
        dependenciesMock.tappAffiliateService.secretsTask = URLSessionDataTaskProtocolMock(identifier: 1)

        let expectation1 = self.expectation(description: "initialization1")
        sut.initializeEngine { result in
            expectation1.fulfill()
        }

        let url = try XCTUnwrap(URL(string: "https://tapp.so"))

        let expectation2 = self.expectation(description: "appWillOpen")
        sut.appWillOpen(url, authToken: "authToken") { result in
            expectation2.fulfill()
        }

        try await Task.sleep(milliseconds: 50)

        dependenciesMock.tappAffiliateService.secretsResponse = SecretsResponse(secret: "123")

        await fulfillment(of: [expectation1, expectation2], timeout: 0.5)

        XCTAssertEqual(dependenciesMock.tappAffiliateService.secretsCalledCount, 1)
        XCTAssertEqual(dependenciesMock.keychainHelper.config?.originURL, url)
        XCTAssertEqual(dependenciesMock.keychainHelper.config?.hasProcessedReferralEngine, true)
        XCTAssertTrue(dependenciesMock.adjustAffiliateService.handleCallbackCalled)
    }

    func testFetchURL() async throws {
        dependenciesMock.keychainHelper.config = testConfiguration
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

private extension TappTests {
    var testConfiguration: TappConfiguration {
        return TappConfiguration(authToken: "authToken",
                                 env: .sandbox,
                                 tappToken: "tappToken",
                                 affiliate: .adjust)
    }
}
