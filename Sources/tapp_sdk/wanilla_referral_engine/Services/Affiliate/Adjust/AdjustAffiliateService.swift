//
//  AdjustAffiliateService.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  AdjustAffiliateService.swift
//  wanilla_referral_engine/Services/Affiliate

import Foundation
import AdjustSdk // Adjust SDK import

public class AdjustAffiliateService: AffiliateService {
    
    private var isInitialized = false
    private let appToken: String  // Store the appToken

    // Initialize with appToken
    public init(appToken: String) {
        self.appToken = appToken
    }

    public func initialize(environment: Environment, completion: @escaping (Result<Void, Error>) -> Void) {

        guard !isInitialized else {
            print("Adjust is already initialized.")
            completion(.success(()))
            return
        }

        let adjustEnvironment = environment == Environment.production ? ADJEnvironmentProduction : ADJEnvironmentSandbox
        let adjustConfig = ADJConfig(appToken: appToken, environment: adjustEnvironment)
        Adjust.initSdk(adjustConfig)

        isInitialized = true
        print("Adjust initialized complete.")
        completion(.success(()))
    }

    public func handleCallback(with url: String) {
        if let incomingURL = URL(string: url) {
            Adjust.processDeeplink(ADJDeeplink(deeplink: incomingURL)!)
            print("Adjust notified of the incoming URL: \(incomingURL)")
        }
    }
    
    //TODO:: insert the event logic for adjust
    public func handleEvent(eventId: String, authToken: String?) {
        // Validate eventId
        guard !eventId.isEmpty else {
            print("Error: eventId is empty.")
            return
        }
        
        // Create ADJEvent instance
        if let event = ADJEvent(eventToken: eventId) {
            // Track the event
            Adjust.trackEvent(event)
            print("Tracked event on Adjust: \(event.description)")
            //TODO:: API call to tapp sdk to notify about the event
        } else {
            // Handle the case where event creation fails
            print("Error: Could not create ADJEvent with eventId \(eventId).")
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
        print("Handling Adjust callback for custom url...not implemented yet")
    }
    
    public func handleImpression(url: String, authToken: String, completion: @escaping (Result<[String: Any], any Error>) -> Void) {
        print("Handle impression is not implemented yet. Use Tapp's method.")
    }
    
}
