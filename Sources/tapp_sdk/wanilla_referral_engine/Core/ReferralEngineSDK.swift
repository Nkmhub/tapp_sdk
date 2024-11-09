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
    
    public func processReferralEngine(url: String?,
                                      appToken: String,
                                      authToken: String,
                                      env: Environment,
                                      wreToken: String,
                                      affiliate: Affiliate) {
        // Save parameters to Keychain
        KeychainHelper.shared.save(key: "appToken", value: appToken)
        KeychainHelper.shared.save(key: "authToken", value: authToken)
        KeychainHelper.shared.save(key: "env", value: env.rawValue)
        KeychainHelper.shared.save(key: "wreToken", value: wreToken)
        
        // Now use these values in your flow
        let tappService = AffiliateServiceFactory.create(.tapp, appToken: appToken)
        let affiliateService = AffiliateServiceFactory.create(affiliate, appToken: appToken)
        
        // Continue the rest of the method as before
        affiliateService.initialize(environment: env) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                if self.hasProcessedReferralEngine() {
                    print("Referral engine processing has already been executed.")
                    return
                }
                
                if let urlString = url, !urlString.isEmpty, URL(string: urlString) != nil {
                    tappService.handleImpression(url: urlString, authToken: authToken) { result in
                        switch result {
                        case .success(let jsonResponse):
                            print("Tapp handleImpression service success response:", jsonResponse)
                        case .failure(let error):
                            print("Tapp handleImpression service error response:", error)
                        }
                    }
                    affiliateService.handleCallback(with: urlString)
                } else {
                    print("URL is nil or invalid, skipping handleImpression and handleCallback.")
                }
                
                self.setProcessedReferralEngine()
            case .failure(let error):
                print("Error initializing \(affiliate): \(error)")
            }
        }
    }

    public func eventHandler(affiliate: Affiliate, eventToken: String) {
        if let appToken = KeychainHelper.shared.get(key: "appToken"),
           let authToken = KeychainHelper.shared.get(key: "authToken") {
            let affiliateService = AffiliateServiceFactory.create(affiliate, appToken: appToken)
            affiliateService.handleEvent(eventId: eventToken, authToken: authToken)
        } else {
            print("Error: Missing required tokens in Keychain")
        }
    }

    public func affiliateUrl(
        influencer: String,
        adgroup: String,
        creative: String,
        mmp: UrlAffiliate,
        jsonObject: [String: Any],
        completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void
    ) {
        if let appToken = KeychainHelper.shared.get(key: "appToken"),
           let authToken = KeychainHelper.shared.get(key: "authToken"),
           let wreToken = KeychainHelper.shared.get(key: "wreToken") {
            
            let affiliateService = AffiliateServiceFactory.create(Affiliate.tapp, appToken: appToken)
            affiliateService.affiliateUrl(
                wre_token: wreToken,
                influencer: influencer,
                adgroup: adgroup,
                creative: creative,
                mmp: mmp,
                token: authToken,
                jsonObject: jsonObject,
                completion: completion
            )
        } else {
            completion(.failure(.missingParameters))
        }
    }

    private func setProcessedReferralEngine() {
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }

    private func hasProcessedReferralEngine() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
}
