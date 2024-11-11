//
//  TappAffiliateService.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 2/11/24.
//

import Foundation

public class TappAffiliateService: AffiliateService {
    
    private let baseAPIURL = "https://www.nkmhub.com/api/wre/"
    
    public func initialize(environment: Environment, completion: @escaping (Result<Void, Error>) -> Void) {
        Logger.logInfo("Initializing Tapp... Not implemented")
        completion(.success(()))
    }

    public func handleCallback(with url: String) {
        Logger.logInfo("Handling Tapp callback with URL: \(url)")
    }
    
    public func handleEvent(eventId: String, authToken: String?) {
        guard let authToken = authToken, !authToken.isEmpty else {
            Logger.logError(ReferralEngineError.missingAuthToken)
            return
        }
        
        Logger.logInfo("Handling Tapp callback for events with ID: \(eventId)")
        
        let apiURL = "\(baseAPIURL)event"
        let requestBody: [String: Any] = [
            "event_name": eventId,
        ]
        
        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        let networkManager = NetworkManager()
        networkManager.postRequest(url: apiURL, params: requestBody, headers: headers) { result in
            switch result {
            case .success(let jsonResponse):
                Logger.logInfo("Event tracked successfully: \(jsonResponse)")
            case .failure(let error):
                Logger.logError(error)
            }
        }
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
        completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void
    ) {
        let apiURL = "\(baseAPIURL)generateUrl"
        
        let requestBody: [String: Any] = [
            "tapp_token": tapp_token,
            "bundle_id": bundle_id,
            "mmp": mmp,
            "adgroup": adgroup,
            "creative": creative,
            "influencer": influencer,
            "data": jsonObject
        ]
        
        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        let networkManager = NetworkManager()
        networkManager.postRequest(url: apiURL, params: requestBody, headers: headers) { result in
            switch result {
            case .success(let jsonResponse):
                Logger.logInfo("Affiliate URL generated successfully: \(jsonResponse)")
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
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        let apiURL = "\(baseAPIURL)checkStatus"
        
        let requestBody: [String: Any] = [
            "url": url
        ]
        
        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        let networkManager = NetworkManager()
        
        networkManager.postRequest(url: apiURL, params: requestBody, headers: headers) { result in
            switch result {
            case .success(let jsonResponse):
                if let status = jsonResponse["status"] as? Int,
                   let message = jsonResponse["message"] as? String {
                    Logger.logInfo("Handle impression success: Status \(status), Message: \(message)")
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
}
