import Foundation
@testable import Tapp

class AffiliateServiceProtocolMock: NSObject, TappAffiliateServiceProtocol {

    var generateURLCalled: Bool = false
    func url(request: GenerateURLRequest, completion: GenerateURLCompletion?) {
        generateURLCalled = true
    }

    var handleImpressionCalled: Bool = false
    func handleImpression(url: URL, completion: VoidCompletion?) {
        handleImpressionCalled = true
    }

    var sendTappEventCalled: Bool = false
    func sendTappEvent(event: TappEvent, completion: VoidCompletion?) {
        sendTappEventCalled = true
    }

    var secretsDataTask: URLSessionDataTaskProtocol?
    func secrets(affiliate: Affiliate, completion: SecretsCompletion?) -> URLSessionDataTaskProtocol? {
        return secretsDataTask
    }

    var didReceiveDeferredURLCalled: Bool = false
    func didReceiveDeferredURL(_ url: URL, completion: LinkDataCompletion?) {
        didReceiveDeferredURLCalled = true
    }
    
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
    func handleCallback(with url: String, completion: ResolvedURLCompletion?) {
        handleCallbackCalled = true
    }

    var handleEventCalled: Bool = false
    func handleEvent(eventId: String, authToken: String?) {
        handleEventCalled = true
    }
}
