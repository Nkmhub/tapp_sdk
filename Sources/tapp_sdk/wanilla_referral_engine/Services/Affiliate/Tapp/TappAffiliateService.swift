//
//  TappAffiliateService.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 2/11/24.
//

import Foundation

public class TappAffiliateService: AffiliateService {
    public func initialize(environment: Environment, completion: @escaping (Result<Void, Error>) -> Void) {
        // Tapp-specific initialization logic here
        print("Initializing Tapp...Not implemented")
        completion(.success(()))
    }

    public func handleCallback(with url: String) {
        // Tapp-specific callback handling logic here
        print("Handling Tapp callback with URL: \(url)")
    }
    
    public func handleEvent(eventId: String, authToken: String?) {
        // Check if authToken is nil or empty
        guard let authToken = authToken, !authToken.isEmpty else {
            print("Error: authToken shouldn't be empty.")
            return
        }
        
        print("Handling Tapp callback for events with ID: \(eventId)")
        
        let apiURL = "https://www.nkmhub.com/api/wre/event"
        let requestBody: [String: Any] = [
            "event_name": eventId,
        ]
        
        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        // Make network request to track the event
        let networkManager = NetworkManager()
        networkManager.postRequest(url: apiURL, params: requestBody, headers: headers) { result in
            switch result {
            case .success(let jsonResponse):
                // Successfully tracked the event
                print("Event tracked:", jsonResponse)
            case .failure(let error):
                // Failed to track the event
                print("Event did not track:", error)
            }
        }
    }


    public func affiliateUrl(
        wre_token: String,
        influencer: String,
        adgroup: String,
        creative: String,
        mmp: UrlAffiliate,
        token: String,
        jsonObject: [String: Any],
        completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void
    ) {
        // Construct the URL for the API
        let apiURL = "https://www.nkmhub.com/api/wre/generateUrl"
        
        // Prepare the JSON body with the token, affiliate, and username
        let requestBody: [String: Any] = [
            "wre_token": wre_token,
            "mmp": mmp.rawValue,
            "influencer": influencer,
            "adgroup": adgroup,
            "creative": creative,
            "data": jsonObject
        ]
        
        // Set up headers, including the Authorization header
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        // Initialize NetworkManager and make the POST request
        let networkManager = NetworkManager()
        networkManager.postRequest(url: apiURL, params: requestBody, headers: headers) { result in
            switch result {
            case .success(let jsonResponse):
                // Success: Return the JSON response
                completion(.success(jsonResponse))
                print("jsonResponse:", jsonResponse)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
