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

    public init() {}

    // Main function to process referral based on the affiliate
    public func processReferralEngine(url: String, environment: String, affiliate: Affiliate,appToken:String) {
        if hasProcessedReferralEngine() {
            print("Referral engine processing has already been executed.")
            return
        }
        
        //TODO:: service to check if the user is active
        
        //TODO:: service to inform our backend that the app is install to map the user

        // Use factory to create the right affiliate service
        let affiliateService = AffiliateServiceFactory.create(affiliate,appToken: appToken)
        
        // Initialize the selected affiliate service
        affiliateService.initialize(environment: environment) { [weak self] result in
            switch result {
            case .success:
                // Handle affiliate callback with URL
                affiliateService.handleCallback(with:url)
                self?.setProcessedReferralEngine()
            case .failure(let error):
                print("Error initializing \(affiliate): \(error)")
            }
        }
    }
    
    // Method to generate affiliate URL with completion handler
    public func affiliateUrl(wre_token: String, influencer: String,adgroup:String,creative:String, mmp: Affiliate,token:String, jsonObject: [String: Any], completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void) {

           // Construct the URL for the API
           guard let apiURL = URL(string: "https://www.nkmhub.com/api/wre/generateUrl") else {
               completion(.failure(.apiError("Invalid API URL.")))
               return
           }

           // Create the URL request
           var request = URLRequest(url: apiURL)
           request.httpMethod = "POST"
           
           // Prepare the JSON body with the token, affiliate, and username
           let requestBody: [String: Any] = [
               "wre_token": wre_token,
               "mmp": mmp.rawValue,
               "influencer": influencer,
               "adgroup":adgroup,
               "creative":creative,
               "data": jsonObject
           ]
           
           // Convert the request body to JSON data
           request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
           // Make the API call
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               // Handle network error
               if let error = error {
                   completion(.failure(.apiError(error.localizedDescription)))
                   return
               }

               // Ensure valid data is received
               guard let data = data else {
                   completion(.failure(.apiError("No data received from server.")))
                   return
               }

               // Print raw response data for debugging
               if let responseDataString = String(data: data, encoding: .utf8) {
                   print("Raw response data: \(responseDataString)")
               }

               // Parse the JSON response
               do {
                   if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                       // Success: Return the entire JSON response
                       completion(.success(jsonResponse))
                       print("jsonResponse",jsonResponse)
                   } else {
                       completion(.failure(.apiError("Unable to parse JSON response.")))
                   }
               } catch {
                   completion(.failure(.apiError("Failed to decode JSON response: \(error.localizedDescription)")))
               }
           }

           task.resume()
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
