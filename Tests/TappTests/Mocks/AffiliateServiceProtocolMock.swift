import Foundation
@testable import Tapp

class AffiliateServiceProtocolMock: NSObject, AffiliateServiceProtocol {
    var isInitialized: Bool = false
    var initializeCompletion: VoidCompletion?
    var initializeError: Error?
    func initialize(environment: Environment,
                    completion: VoidCompletion?) {
        if let initializeError {
            completion?(Result.failure(initializeError))
        } else {
            completion?(Result.success(()))
        }
    }

    var handleCallbackCalled: Bool = false
    func handleCallback(with url: String) {
        handleCallbackCalled = true
    }

    var handleEventCalled: Bool = false
    func handleEvent(eventId: String, authToken: String?) {
        handleEventCalled = true
    }
}
