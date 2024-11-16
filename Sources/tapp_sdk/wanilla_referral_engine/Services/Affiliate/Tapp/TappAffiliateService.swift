//
//  TappAffiliateService.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 2/11/24.
//

import Foundation

public class TappAffiliateService: AffiliateService, TappSpecificService {

    private var baseAPIURL = "https://api.nkmhub.com/v1/ref/"
//    private var baseAPIURL: String {
//        guard let environment = KeychainCredentials.environment else {
//            return "https://api.nkmhub.com/sandbox/ref"
//        }
//
//        switch environment {
//        case "production":
//            return "https://api.nkmhub.com/v1/ref/"
//        case "sandbox":
//            return "https://api.nkmhub.com/sandbox/ref"
//        default:
//            return "https://api.nkmhub.com/sandbox/ref"
//        }
//    }

    public func initialize(
        environment: String,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        Logger.logInfo("Initializing Tapp... Not implemented")
        completion(.success(()))
    }

    public func handleCallback(with url: String) {
        Logger.logInfo("Handling Tapp callback with URL: \(url)")
    }

    public func affiliateUrl(
        tapp_token: String,
        bundle_id: String,
        mmp: Int,
        adgroup: String,
        creative: String,
        influencer: String,
        authToken: String,
        jsonObject: [String: Any],
        completion: @escaping (Result<[String: Any], ReferralEngineError>) ->
            Void
    ) {
        let apiURL = "\(baseAPIURL)influencer/add"

        let requestBody: [String: Any] = [
            "tapp_token": tapp_token,
            "bundle_id": bundle_id,
            "mmp": mmp,
            "adgroup": adgroup,
            "creative": creative,
            "influencer": influencer,
            "data": jsonObject,
        ]

        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]

        let networkManager = NetworkManager()
        networkManager.postRequest(
            url: apiURL, params: requestBody, headers: headers
        ) { result in
            switch result {
            case .success(let jsonResponse):
                Logger.logInfo(
                    "Affiliate URL generated successfully: \(jsonResponse)")
                completion(.success(jsonResponse))
            case .failure(let error):
                Logger.logError(error)
                completion(.failure(error))
            }
        }
    }

    public func handleImpression(
        url: String,
        authToken: String,
        tapp_token: String,
        bundle_id: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        let apiURL = "\(baseAPIURL)deeplink"

        let requestBody: [String: Any] = [
            "tapp_token":tapp_token,
            "bundle_id":bundle_id,
            "deeplink": url
        ]

        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]

        let networkManager = NetworkManager()

        networkManager.postRequest(
            url: apiURL, params: requestBody, headers: headers
        ) { result in
            switch result {
            case .success(let jsonResponse):
                if  let error = jsonResponse["error"] as? Bool, !error,
                    let message = jsonResponse["message"] as? String
                {
                    Logger.logInfo(
                        "Handle impression success:Message: \(message)"
                    )
                    completion(.success(jsonResponse))
                } else {
                    let parsingError = ReferralEngineError.apiError(
                        message: "Invalid response format",
                        endpoint: apiURL
                    )
                    Logger.logError(parsingError)
                    completion(.failure(parsingError))
                }
            case .failure(let error):
                Logger.logError(error)
                completion(.failure(error))
            }
        }
    }

    public func handleTappEvent(
        auth_token authToken: String,
        tapp_token: String,
        bundle_id: String,
        event_name: String,
        event_action: Int,
        event_custom_action: String? = nil
    ) {
        let apiURL = "\(baseAPIURL)event"
        let networkManager = NetworkManager()

        let requestBody: [String: Any] = [
            "tapp_token": tapp_token,
            "bundle_id": bundle_id,
            "event_name": event_name,
            "event_action": event_action,
            "event_custom_action": event_custom_action ?? "false",
        ]

        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]

        networkManager.postRequest(
            url: apiURL, params: requestBody, headers: headers
        ) { result in
            switch result {
            case .success(let jsonResponse):
                if let message = jsonResponse["message"] as? String {
                    Logger.logInfo(
                        "Handle tapp event tracked: Message: \(message)")
                } else if let errorMessage = jsonResponse["error"] as? String {
                    let apiError = ReferralEngineError.apiError(
                        message: errorMessage, endpoint: apiURL)
                    Logger.logError(apiError)
                } else {
                    let parsingError = ReferralEngineError.apiError(
                        message: "Invalid response format",
                        endpoint: apiURL
                    )
                    Logger.logError(parsingError)
                }
            case .failure(let error):
                Logger.logError(error)
            }
        }
    }

    public func getSecrets(
        auth_token: String,
        tapp_token: String,
        bundle_id: String,
        mmp: Affiliate,
        completion: @escaping (Result<String, ReferralEngineError>) -> Void
    ) {
        let apiURL = "\(baseAPIURL)secrets"
        let networkManager = NetworkManager()

        let requestBody: [String: Any] = [
            "tapp_token": tapp_token,
            "bundle_id": bundle_id,
            "mmp": mmp.intValue,
        ]

        let headers = [
            "Authorization": "Bearer \(auth_token)",
            "Content-Type": "application/json",
        ]

        // Log the request
        Logger.logInfo(
            "Sending GetSecrets request to \(apiURL) with parameters: \(requestBody)"
        )

        networkManager.postRequest(
            url: apiURL, params: requestBody, headers: headers
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let jsonResponse):
                    Logger.logInfo("Received response: \(jsonResponse)")
                    if let error = jsonResponse["error"] as? Bool, !error,
                        let secret = jsonResponse["secret"] as? String
                    {
                        Logger.logInfo(
                            "inside the success case, secret: \(secret)")
                        completion(.success(secret))
                    } else if let errorMessage = jsonResponse["message"]
                        as? String
                    {
                        let apiError = ReferralEngineError.apiError(
                            message: errorMessage,
                            endpoint: apiURL
                        )
                        Logger.logError(apiError)
                        completion(.failure(apiError))
                    } else {
                        let parsingError = ReferralEngineError.apiError(
                            message: "Invalid response format",
                            endpoint: apiURL
                        )
                        Logger.logError(parsingError)
                        completion(.failure(parsingError))
                    }
                case .failure(let error):
                    Logger.logError(error)
                    completion(.failure(error))
                }
            }
        }
    }

    public func handleEvent(eventId: String, authToken: String?) {
        Logger.logInfo("Use the handleTappEvent method to handle Tapp events")
    }

}
