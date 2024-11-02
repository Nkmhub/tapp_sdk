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
    private var authToken = "";

    public init() {}

    // Main function to process referral based on the affiliate
    public func processReferralEngine(url: String, environment: Environment, affiliate: Affiliate, appToken: String, tappToken: String) {
        tokenKey = appToken
        env = environment
        authToken = tappToken;
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
        mmp: UrlAffiliate,
        jsonObject: [String: Any],
        completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void
    ) {
        let affiliateService = AffiliateServiceFactory.create(Affiliate.tapp, appToken: tokenKey)

        affiliateService.affiliateUrl(
            wre_token: wre_token,
            influencer: influencer,
            adgroup: adgroup,
            creative: creative,
            mmp: mmp,
            token: authToken,
            jsonObject: jsonObject
        ) { result in
            // No need to capture self since it's not used
            switch result {
            case .success(let jsonResponse):
                // Pass the response to the completion handler
                completion(.success(jsonResponse))
                print("jsonResponse:", jsonResponse)
            case .failure(let error):
                // Pass the error to the completion handler
                completion(.failure(error))
                print("Error:", error)
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
