//
//  Core.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  ReferralEngineSDK.swift
//  wanilla_referral_engine/Core

import Foundation

public class ReferralEngineSDK {
    private let userDefaultsKey = "hasProcessedReferralEngine"
    private var tokenKey = "";
    private var env:Environment = Environment.sandbox;

    public init() {}

    // Main function to process referral based on the affiliate
    public func processReferralEngine(url: String, environment: Environment, affiliate: Affiliate, appToken: String) {
        tokenKey = appToken
        env = environment

        // TODO:: service to check if the user is active

        // TODO:: service to inform our backend that the app is installed to map the user

        // Use factory to create the right affiliate service
        let affiliateService = AffiliateServiceFactory.create(affiliate, appToken: appToken)

        // Initialize the selected affiliate service
        affiliateService.initialize(environment: environment) { [weak self] result in
            guard let self = self else { return } // Ensures self is available within the closure
            
            switch result {
            case .success:
                if self.hasProcessedReferralEngine() {
                    print("Referral engine processing has already been executed.")
                    return
                }
                // Handle affiliate callback with URL
                affiliateService.handleCallback(with: url)
                self.setProcessedReferralEngine()
            case .failure(let error):
                print("Error initializing \(affiliate): \(error)")
            }
        }
    }

    
    public func eventHandler(affiliate: Affiliate,eventToken:String) {
        // Use factory to create the right affiliate service
        let affiliateService = AffiliateServiceFactory.create(affiliate,appToken: tokenKey)
        affiliateService.handleEvent(with: eventToken )
    }
    
    // Method to generate affiliate URL with completion handler
    public func affiliateUrl(
        wre_token: String,
        influencer: String,
        adgroup: String,
        creative: String,
        mmp: Affiliate,
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

    // Helper function to extract uId from the URL
    public func getUidParam(from url: String) -> String? {
        guard let url = URL(string: url) else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "uId" }?.value
    }

    private func setProcessedReferralEngine() {
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }

    private func hasProcessedReferralEngine() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
}
