//
//  AdjustAffiliateService.swift
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

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
    
    public func handleEvent(eventId: String, authToken: String?) {
        guard !eventId.isEmpty else {
            print("Error: eventId is empty.")
            return
        }
        
        if let event = ADJEvent(eventToken: eventId) {
            Adjust.trackEvent(event)
            print("Tracked event on Adjust: \(event.description)")
        } else {
            print("Error: Could not create ADJEvent with eventId \(eventId).")
        }
    }
    
    public func affiliateUrl(tapp_token: String, bundle_id: String, mmp: Int, adgroup: String, creative: String, influencer: String, authToken: String, jsonObject: [String : Any], completion: @escaping (Result<[String : Any], ReferralEngineError>) -> Void) {
        print("Handling Adjust callback for custom url...not implemented yet")
    }

    public func handleImpression(url: String, authToken: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        print("Handle impression is not implemented yet. Use Tapp's method.")
    }

    // MARK: - Attribution
    public func getAttribution(completion: @escaping (ADJAttribution?) -> Void) {
        Adjust.attribution { attribution in
            completion(attribution)
            if let attribution = attribution {
                print("Attribution: \(attribution)")
            } else {
                print("No attribution available.")
            }
        }
    }

    // MARK: - Privacy Compliance
    public func gdprForgetMe() {
        Adjust.gdprForgetMe()
        print("GDPR Forget Me request sent.")
    }

    public func trackThirdPartySharing(isEnabled: Bool) {
        guard let thirdPartySharing = ADJThirdPartySharing(isEnabled: NSNumber(value: isEnabled)) else {
            print("Failed to create ADJThirdPartySharing object.")
            return
        }
        Adjust.trackThirdPartySharing(thirdPartySharing)
        print("Third-party sharing set to: \(isEnabled).")
    }

    // MARK: - Monetization
    public func trackAdRevenue(source: String, revenue: Double, currency: String) {
        if let adRevenue = ADJAdRevenue(source: source) {
            adRevenue.setRevenue(revenue, currency: currency)
            Adjust.trackAdRevenue(adRevenue)
            print("Tracked ad revenue for \(source).")
        } else {
            print("Failed to create ADJAdRevenue object.")
        }
    }

    public func verifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (ADJPurchaseVerificationResult) -> Void) {
        if let purchase = ADJAppStorePurchase(transactionId: transactionId, productId: productId) {
            Adjust.verifyAppStorePurchase(purchase) { result in
                completion(result)
                print("Purchase verification result: \(result)")
            }
        } else {
            print("Failed to create ADJAppStorePurchase object.")
        }
    }

    // MARK: - Push Token
    public func setPushToken(_ token: String) {
        Adjust.setPushTokenAs(token)
        print("Push token set: \(token)")
    }

    // MARK: - Device IDs
    public func getAdid(completion: @escaping (String?) -> Void) {
        Adjust.adid { adid in
            completion(adid)
            print("ADID: \(adid ?? "No ADID available")")
        }
    }

    public func getIdfa(completion: @escaping (String?) -> Void) {
        Adjust.idfa { idfa in
            completion(idfa)
            print("IDFA: \(idfa ?? "No IDFA available")")
        }
    }
    
    public func test(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        print("Unique method on Adjust service.")
        completion(.success(["status": "Test methods executed"]))
    }
}
