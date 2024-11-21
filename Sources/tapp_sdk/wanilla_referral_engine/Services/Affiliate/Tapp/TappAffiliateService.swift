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

    private let keychainHelper: KeychainHelperProtocol
    private let networkClient: NetworkClientProtocol

    init(keychainHelper: KeychainHelperProtocol, networkClient: NetworkClientProtocol) {
        self.keychainHelper = keychainHelper
        self.networkClient = networkClient
    }

    public func initialize(
        environment: Environment,
        completion: VoidCompletion?) {
        Logger.logInfo("Initializing Tapp... Not implemented")
        completion?(.success(()))
    }

    public func handleCallback(with url: String) {
        Logger.logInfo("Handling Tapp callback with URL: \(url)")
    }

    public func url(request: GenerateURLRequest, completion: GenerateURLCompletion?) {
        url(uniqueID: request.influencer,
            adGroup: request.adGroup,
            creative: request.creative,
            data: request.data,
            completion: completion)
    }

    private func url(uniqueID: String,
                     adGroup: String?,
                     creative: String?,
                     data: Data,
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

    public func handleImpression(url: URL, completion: VoidCompletion?) {
        guard let config = keychainHelper.config, let bundleID = config.bundleID else { return }
        let impressionRequest = ImpressionRequest(tappToken: config.tappToken, bundleID: bundleID, deepLink: url)
        commonVoid(with: TappEndpoint.deeplink(impressionRequest),
                   completion: completion)
    }

    public func secrets(affiliate: Affiliate, completion: SecretsCompletion?) {
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

    public func sendTappEvent(event: TappEvent, completion: VoidCompletion?) {
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

    public func handleEvent(eventId: String, authToken: String?) {
        Logger.logInfo("Use the handleTappEvent method to handle Tapp events")
    }


//    public func affiliateUrl(
//        tappToken: String,
//        bundleID: String,
//        mmp: Int,
//        adgroup: String,
//        creative: String,
//        influencer: String,
//        authToken: String,
//        jsonObject: [String: Any],
//        completion: @escaping (Result<[String: Any], TappError>) ->
//            Void
//    ) {
//        let apiURL = "\(baseAPIURL)influencer/add"
//
//        let requestBody: [String: Any] = [
//            "tapp_token": tappToken,
//            "bundle_id": bundleID,
//            "mmp": mmp,
//            "adgroup": adgroup,
//            "creative": creative,
//            "influencer": influencer,
//            "data": jsonObject,
//        ]
//
//        let headers = [
//            "Authorization": "Bearer \(authToken)"
//        ]
//
//        let networkManager = NetworkManager()
//        networkManager.postRequest(
//            url: apiURL, params: requestBody, headers: headers
//        ) { result in
//            switch result {
//            case .success(let jsonResponse):
//                Logger.logInfo(
//                    "Affiliate URL generated successfully: \(jsonResponse)")
//                completion(.success(jsonResponse))
//            case .failure(let error):
//                Logger.logError(error)
//                completion(.failure(error))
//            }
//        }
//    }
//
//    public func handleImpression(
//        url: String,
//        authToken: String,
//        tappToken: String,
//        bundleID: String,
//        completion: @escaping (Result<[String: Any], Error>) -> Void
//    ) {
//        let apiURL = "\(baseAPIURL)deeplink"
//
//        let requestBody: [String: Any] = [
//            "tapp_token": tappToken,
//            "bundle_id": bundleID,
//            "deeplink": url,
//        ]
//
//        let headers = [
//            "Authorization": "Bearer \(authToken)"
//        ]
//
//        let networkManager = NetworkManager()
//
//        networkManager.postRequest(
//            url: apiURL, params: requestBody, headers: headers
//        ) { result in
//            switch result {
//            case .success(let jsonResponse):
//                if let error = jsonResponse["error"] as? Bool, !error,
//                    let message = jsonResponse["message"] as? String
//                {
//                    Logger.logInfo(
//                        "Handle impression success:Message: \(message)"
//                    )
//                    completion(.success(jsonResponse))
//                } else if let error = jsonResponse["error"] as? Bool, error,
//                    let message = jsonResponse["message"] as? String
//                {
//                    let parsingError = TappError.apiError(
//                        message: message,
//                        endpoint: apiURL
//                    )
//                    Logger.logError(parsingError)
//                    completion(.failure(parsingError))
//                } else {
//                    let parsingError = TappError.apiError(
//                        message: "Invalid response format",
//                        endpoint: apiURL
//                    )
//                    Logger.logError(parsingError)
//                    completion(.failure(parsingError))
//                }
//            case .failure(let error):
//                Logger.logError(error)
//                completion(.failure(error))
//            }
//        }
//    }
//    public func handleTappEvent(
//        authToken: String,
//        tappToken: String,
//        bundleID: String,
//        eventName: String,
//        eventAction: Int,
//        eventCustomAction: String? = nil
//    ) {
//        let apiURL = "\(baseAPIURL)event"
//        let networkManager = NetworkManager()
//
//        let requestBody: [String: Any] = [
//            "tapp_token": tappToken,
//            "bundle_id": bundleID,
//            "event_name": eventName,
//            "event_action": eventAction,
//            "event_custom_action": eventCustomAction ?? "false",
//        ]
//
//        let headers = [
//            "Authorization": "Bearer \(authToken)"
//        ]
//
//        networkManager.postRequest(
//            url: apiURL, params: requestBody, headers: headers
//        ) { result in
//            switch result {
//            case .success(let jsonResponse):
//                if let message = jsonResponse["message"] as? String {
//                    Logger.logInfo(
//                        "Handle tapp event tracked: Message: \(message)")
//                } else if let errorMessage = jsonResponse["error"] as? String {
//                    let apiError = TappError.apiError(
//                        message: errorMessage, endpoint: apiURL)
//                    Logger.logError(apiError)
//                } else {
//                    let parsingError = TappError.apiError(
//                        message: "Invalid response format",
//                        endpoint: apiURL
//                    )
//                    Logger.logError(parsingError)
//                }
//            case .failure(let error):
//                Logger.logError(error)
//            }
//        }
//    }
//
//    public func getSecrets(
//        authToken: String,
//        tappToken: String,
//        bundleID: String,
//        mmp: Affiliate,
//        completion: @escaping (Result<String, TappError>) -> Void
//    ) {
//        let apiURL = "\(baseAPIURL)secrets"
//        let networkManager = NetworkManager()
//
//        let requestBody: [String: Any] = [
//            "tapp_token": tappToken,
//            "bundle_id": bundleID,
//            "mmp": mmp.intValue,
//        ]
//
//        let headers = [
//            "Authorization": "Bearer \(authToken)",
//            "Content-Type": "application/json",
//        ]
//
//        // Log the request
//        Logger.logInfo(
//            "Sending GetSecrets request to \(apiURL) with parameters: \(requestBody)"
//        )
//
//        networkManager.postRequest(
//            url: apiURL, params: requestBody, headers: headers
//        ) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let jsonResponse):
//                    Logger.logInfo("Received response: \(jsonResponse)")
//                    if let error = jsonResponse["error"] as? Bool, !error,
//                        let secret = jsonResponse["secret"] as? String
//                    {
//                        Logger.logInfo(
//                            "inside the success case, secret: \(secret)")
//                        completion(.success(secret))
//                    } else if let errorMessage = jsonResponse["message"]
//                        as? String
//                    {
//                        let apiError = TappError.apiError(
//                            message: errorMessage,
//                            endpoint: apiURL
//                        )
//                        Logger.logError(apiError)
//                        completion(.failure(apiError))
//                    } else {
//                        let parsingError = TappError.apiError(
//                            message: "Invalid response format",
//                            endpoint: apiURL
//                        )
//                        Logger.logError(parsingError)
//                        completion(.failure(parsingError))
//                    }
//                case .failure(let error):
//                    Logger.logError(error)
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
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
