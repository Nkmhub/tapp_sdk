import Foundation
@testable import Tapp

final class TappAffiliateServiceProtocolMock: AffiliateServiceProtocolMock, TappAffiliateServiceProtocol {
    var urlResponse: GeneratedURLResponse? {
        didSet {
            if let urlResponse {
                completion?(Result.success(urlResponse))
            }
        }
    }
    var urlError: Error? {
        didSet {
            if let urlError {
                completion?(Result.failure(urlError))
            }
        }
    }
    var completion: GenerateURLCompletion?
    func url(request: GenerateURLRequest, completion: GenerateURLCompletion?) {
        self.completion = completion
    }

    var handleImpressionError: Error?
    func handleImpression(url: URL, completion: VoidCompletion?) {
        if let handleImpressionError {
            completion?(Result.failure(handleImpressionError))
        } else {
            completion?(Result.success(()))
        }
    }

    var sendTappEventError: Error?
    func sendTappEvent(event: TappEvent, completion: VoidCompletion?) {
        if let sendTappEventError {
            completion?(Result.failure(sendTappEventError))
        } else {
            completion?(Result.success(()))
        }
    }

    var secretsTask: URLSessionDataTaskProtocol?
    var secretsResponse: SecretsResponse? {
        didSet {
            if let secretsError {
                secretsCompletion?(Result.failure(secretsError))
            } else if let secretsResponse {
                secretsCompletion?(Result.success(secretsResponse))
            }
        }
    }
    var secretsError: Error?
    var secretsCalledCount: Int = 0
    var secretsCompletion: SecretsCompletion?
    func secrets(affiliate: Affiliate, completion: SecretsCompletion?) -> URLSessionDataTaskProtocol? {
        secretsCalledCount += 1
        secretsCompletion = completion

        return secretsTask
    }
}
