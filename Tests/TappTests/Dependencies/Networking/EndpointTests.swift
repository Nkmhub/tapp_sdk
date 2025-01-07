import Foundation
import XCTest
@testable import Tapp

final class EndpointTests: XCTestCase {
    func testAPIPath() {
        XCTAssertEqual(APIPath.id.prefixInfluencer, "influencer/id")
        XCTAssertEqual(APIPath.id.prefixAdd, "add/id")
    }

    func testBaseURL() {
        XCTAssertEqual(BaseURL.value(for: .sandbox), "https://api.nkmhub.com/sandbox/ref")
        XCTAssertEqual(BaseURL.value(for: .production), "https://api.nkmhub.com/v1/ref")
    }

    func testEndpointRequestProvider() throws {
        let provider = EndpointRequestProvider()

        XCTAssertNil(provider.request(url: nil, httpMethod: .get))

        let url = URL(string: "http://example.com")!
        let httpMethod: HTTPMethod = .post
        let data = Data()
        let request = try XCTUnwrap(provider.request(url: url, httpMethod: httpMethod, body: data))
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.httpMethod, httpMethod.rawValue)
        XCTAssertNotNil(request.httpBody)
    }

    func testEndpointRequest() throws {
        let endpoint = TestEndpoint.test
        let request = try XCTUnwrap(endpoint.request)
        XCTAssertEqual(request.url?.absoluteString, "https://api.nkmhub.com/sandbox/ref/testPath")
    }

    func testRequestWithEncodable() throws {
        let encodable = TestEndcodable(value: "value")
        let accessToken = "accessToken1"
        let request = try XCTUnwrap(TestEndpoint.test.request(encodable: encodable, accessToken: accessToken))
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer accessToken1")
        XCTAssertNotNil(request.httpBody)
    }

    func testURLWithID() throws {
        let id = UUID()
        let url = try XCTUnwrap(TestEndpoint.test.url(id: id))
        let idString = id.uuidString
        let absoluteString = url.absoluteString
        let expectedURLString = "https://api.nkmhub.com/sandbox/ref/testPath?id=\(idString)"
        XCTAssertEqual(absoluteString, expectedURLString)
    }
}

enum TestEndpoint: Endpoint {
    case test

    var httpMethod: HTTPMethod {
        return .post
    }

    var path: String {
        return "testPath"
    }
}

struct TestEndcodable: Codable {
    let value: String
}
