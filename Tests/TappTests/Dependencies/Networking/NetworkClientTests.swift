import Foundation
import XCTest
@testable import Tapp

final class NetworkClientTests: XCTestCase {
    var subject: NetworkClient!
    var session: URLSessionMock!
    var configuration: SessionConfigurationMock!
    var keychainHelper: KeychainHelperProtocolMock!

    override func setUp() {
        super.setUp()
        configuration = .init()
        session = .init()
        keychainHelper = .init()
        subject = NetworkClient(sessionConfiguration: configuration,
                                keychainHelper: keychainHelper,
                                session: session)
    }

    func testExecuteWithGenericError() {
        let serviceError = ServiceError.invalidID
        session.error = serviceError
        session.data = Data()

        subject.execute(request: request) { result in
            switch result {
            case .success:
                XCTFail()
                return
            case .failure(let error):
                guard let sError = error as? ServiceError else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(sError, serviceError)
            }
        }
    }

    func testExecuteWithServerError() {
        let serverError = ServerError(error: true, reason: "some")
        session.serverError = serverError
        session.data = Data()

        subject.execute(request: request) { result in
            switch result {
            case .success:
                XCTFail()
                return
            case .failure(let error):
                guard let sError = error as? ServerError else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(sError, serverError)
            }
        }
    }

    func testExecuteWithSuccess() {
        session.data = Data()

        subject.execute(request: request) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }
        }
    }

    func testExecuteAuthenticatedAuthorizationValue() throws {
        let configuration = TappConfiguration(authToken: "authToken1",
                                              env: .sandbox,
                                              tappToken: "tappToken1",
                                              affiliate: .adjust)
        keychainHelper.config = configuration

        subject.executeAuthenticated(request: request, completion: nil)

        let receivedRequest = try XCTUnwrap(session.receivedRequest)
        let authorization = try XCTUnwrap(receivedRequest.allHTTPHeaderFields?["Authorization"])
        XCTAssertEqual(authorization, "Bearer authToken1")
    }
}

private extension NetworkClientTests {
    var request: URLRequest {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        return request
    }
}

