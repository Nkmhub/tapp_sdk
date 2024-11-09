//  ReferralEngineSDK.swift
//  wanilla_referral_engine/Core

import Foundation
import AdjustSdk

public class ReferralEngineSDK {
    private let keychainKeyHasProcessed = "hasProcessedReferralEngine"
    
    public init() {}
    
    public func processReferralEngine(
        url: String?,
        appToken: String,
        authToken: String,
        env: Environment,
        wreToken: String,
        affiliate: Affiliate
    ) {
        // Save parameters to Keychain
        KeychainHelper.shared.save(key: "appToken", value: appToken)
        KeychainHelper.shared.save(key: "authToken", value: authToken)
        KeychainHelper.shared.save(key: "env", value: env.rawValue)
        KeychainHelper.shared.save(key: "wreToken", value: wreToken)
        
        // Now use these values in your flow
        let tappService = AffiliateServiceFactory.create(.tapp, appToken: appToken)
        let affiliateService = AffiliateServiceFactory.create(affiliate, appToken: appToken)
        
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
    
    // MARK: - Adjust Specific Methods
    
    /// Retrieves Adjust attribution information.
    public func getAdjustAttribution(completion: @escaping (ADJAttribution?) -> Void) {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            completion(nil)
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.getAttribution(completion: completion)
    }
    
    /// Sends a GDPR "Forget Me" request to Adjust.
    public func adjustGdprForgetMe() {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.gdprForgetMe()
    }
    
    /// Tracks third-party sharing preference in Adjust.
    public func adjustTrackThirdPartySharing(isEnabled: Bool) {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.trackThirdPartySharing(isEnabled: isEnabled)
    }
    
    /// Tracks ad revenue in Adjust.
    public func adjustTrackAdRevenue(source: String, revenue: Double, currency: String) {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.trackAdRevenue(source: source, revenue: revenue, currency: currency)
    }
    
    /// Verifies an App Store purchase with Adjust.
    public func adjustVerifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (ADJPurchaseVerificationResult) -> Void) {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            completion(ADJPurchaseVerificationResult())
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.verifyAppStorePurchase(transactionId: transactionId, productId: productId, completion: completion)
    }
    
    /// Sets the push notification token in Adjust.
    public func adjustSetPushToken(_ token: String) {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.setPushToken(token)
    }
    
    /// Retrieves the Adjust Device Identifier (ADID).
    public func adjustGetAdid(completion: @escaping (String?) -> Void) {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            completion(nil)
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.getAdid(completion: completion)
    }
    
    /// Retrieves the Identifier for Advertisers (IDFA).
    public func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        guard let appToken = KeychainHelper.shared.get(key: "appToken") else {
            print("Error: Missing appToken in Keychain")
            completion(nil)
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.getIdfa(completion: completion)
    }
    
    // MARK: - Use Keychain to track referral process state
    private func setProcessedReferralEngine() {
        KeychainHelper.shared.save(key: keychainKeyHasProcessed, value: true)
    }
    
    private func hasProcessedReferralEngine() -> Bool {
        return KeychainHelper.shared.getBool(key: keychainKeyHasProcessed)
    }
}
