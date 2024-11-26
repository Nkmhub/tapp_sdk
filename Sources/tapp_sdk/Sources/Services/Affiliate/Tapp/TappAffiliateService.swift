//
//  TappAffiliateService.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 2/11/24.
//

import Foundation

public typealias VoidCompletion = (_ result: Result<Void, Error>) -> Void
public typealias GenerateURLCompletion = (_ result: Result<GeneratedURLResponse, Error>) -> Void
typealias SecretsCompletion = (_ result: Result<SecretsResponse, Error>) -> Void

protocol TappAffiliateServiceProtocol: AffiliateServiceProtocol, TappServiceProtocol {}

final class TappAffiliateService: TappAffiliateServiceProtocol {

    let isInitialized: Bool = true
    private let keychainHelper: KeychainHelperProtocol
    private let networkClient: NetworkClientProtocol

    init(keychainHelper: KeychainHelperProtocol, networkClient: NetworkClientProtocol) {
        self.keychainHelper = keychainHelper
        self.networkClient = networkClient
    }

    func initialize(environment: Environment, completion: VoidCompletion?) {
        Logger.logInfo("Initializing Tapp... Not implemented")
        completion?(.success(()))
    }

    func handleCallback(with url: String) {
        Logger.logInfo("Handling Tapp callback with URL: \(url)")
    }

    func url(request: GenerateURLRequest, completion: GenerateURLCompletion?) {
        url(uniqueID: request.influencer,
            adGroup: request.adGroup,
            creative: request.creative,
            data: request.data,
            completion: completion)
    }

    private func url(uniqueID: String,
                     adGroup: String?,
                     creative: String?,
                     data: [String: String]?,
                     completion: GenerateURLCompletion?) {
        guard let config = keychainHelper.config, let bundleID = config.bundleID else { return }
        let createRequest = CreateAffiliateURLRequest(tappToken: config.tappToken,
                                                      bundleID: bundleID,
                                                      mmp: config.affiliate.intValue,
                                                      influencer: uniqueID,
                                                      adGroup: adGroup,
                                                      creative: creative,
                                                      data: data)
        let endpoint = TappEndpoint.generateURL(createRequest)
        guard let request = endpoint.request else {
            completion?(Result.failure(ServiceError.invalidRequest))
            return
        }

        networkClient.executeAuthenticated(request: request) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(GeneratedURLResponse.self, from: data)
                    completion?(Result.success(response))
                } catch {
                    completion?(Result.failure(error))
                }
            case .failure(let error):
                completion?(Result.failure(error))
            }
        }
    }

    func handleImpression(url: URL, completion: VoidCompletion?) {
        guard let config = keychainHelper.config, let bundleID = config.bundleID else { return }
        let impressionRequest = ImpressionRequest(tappToken: config.tappToken, bundleID: bundleID, deepLink: url)
        commonVoid(with: TappEndpoint.deeplink(impressionRequest),
                   completion: completion)
    }

    func secrets(affiliate: Affiliate, completion: SecretsCompletion?) {
        guard let config = keychainHelper.config, let bundleID = config.bundleID else {
            completion?(Result.failure(ServiceError.invalidData))
            return
        }
        let secretsRequest = SecretsRequest(tappToken: config.tappToken, bundleID: bundleID, mmp: affiliate.intValue)
        let endpoint = TappEndpoint.secrets(secretsRequest)

        guard let request = endpoint.request else {
            completion?(Result.failure(ServiceError.invalidRequest))
            return
        }

        networkClient.executeAuthenticated(request: request) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(SecretsResponse.self, from: data)
                    completion?(Result.success(response))
                } catch {
                    completion?(Result.failure(error))
                }
            case .failure(let error):
                completion?(Result.failure(error))
            }
        }
    }

    func sendTappEvent(event: TappEvent, completion: VoidCompletion?) {
        guard let config = keychainHelper.config, let bundleID = config.bundleID else {
            completion?(Result.failure(ServiceError.invalidData))
            return
        }
        let eventRequest = TappEventRequest(tappToken: config.tappToken,
                                            bundleID: bundleID,
                                            eventName: event.eventName,
                                            eventAction: event.eventAction.rawValue,
                                            eventCustomAction: event.eventAction.eventCustomAction)
        let endpoint = TappEndpoint.tappEvent(eventRequest)
        commonVoid(with: endpoint, completion: completion)
    }

    func handleEvent(eventId: String, authToken: String?) {
        Logger.logInfo("Use the handleTappEvent method to handle Tapp events")
    }
}

private extension TappAffiliateService {
    func commonVoid(with endpoint: TappEndpoint, completion: VoidCompletion?) {
        guard let request = endpoint.request else {
            completion?(Result.failure(ServiceError.invalidRequest))
            return
        }

        networkClient.executeAuthenticated(request: request) { result in
            switch result {
            case .success:
                completion?(Result.success(()))
            case .failure(let error):
                completion?(Result.failure(error))
            }
        }
    }
}
