//  ReferralEngineSDK.swift
//  wanilla_referral_engine/Core

//  ReferralEngineSDK.swift
//  wanilla_referral_engine/Core

import Foundation
import AdjustSdk

public class ReferralEngineSDK {
    public init() {}
    
    public func processReferralEngine(
        url: String?,
        appToken: String,
        authToken: String,
        env: Environment,
        tappToken: String,
        affiliate: Affiliate,
        completion: @escaping (Result<Void, ReferralEngineError>) -> Void
    ) {
        // Save parameters to KeychainCredentials
        KeychainCredentials.appToken = appToken
        KeychainCredentials.authToken = authToken
        KeychainCredentials.environment = env.rawValue
        KeychainCredentials.tappToken = tappToken
        
        // Create affiliate services
        guard let tappService = createAffiliateService(affiliate: .tapp),
        let affiliateService = createAffiliateService(affiliate: affiliate) else {
            completion(.failure(.missingAppToken))
            return
        }
        
        // Initialize affiliate service
        affiliateService.initialize(environment: env) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.continueProcessingReferralEngine(
                    url: url,
                    authToken: authToken,
                    tappService: tappService,
                    affiliateService: affiliateService,
                    completion: completion
                )
            case .failure(let error):
                print("Error initializing \(affiliate): \(error)")
                completion(.failure(.initializationFailed(affiliate: affiliate, underlyingError: error)))
            }
        }
    }
    
    private func continueProcessingReferralEngine(
        url: String?,
        authToken: String,
        tappService: AffiliateService,
        affiliateService: AffiliateService,
        completion: @escaping (Result<Void, ReferralEngineError>) -> Void
    ) {
        if hasProcessedReferralEngine() {
            print("Referral engine processing has already been executed.")
            completion(.failure(.alreadyProcessed))
            return
        }
        
        guard let urlString = url, !urlString.isEmpty, let validURL = URL(string: urlString) else {
            print("URL is nil or invalid, skipping handleImpression and handleCallback.")
            completion(.failure(.invalidURL))
            return
        }
        
        affiliateService.handleCallback(with: urlString)
        
        tappService.handleImpression(url: urlString, authToken: authToken) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let jsonResponse):
                print("Tapp handleImpression service success response:", jsonResponse)
                self.setProcessedReferralEngine()
                completion(.success(()))
            case .failure(let error):
                print("Tapp handleImpression service error response:", error)
                completion(.failure(.affiliateServiceError(affiliate: .tapp, underlyingError: error)))
            }
        }
    }


    
    public func eventHandler(affiliate: Affiliate, eventToken: String) {
        if let appToken = KeychainCredentials.appToken,
           let authToken = KeychainCredentials.authToken {
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
        mmp: Affiliate,
        jsonObject: [String: Any],
        completion: @escaping (Result<[String: Any], ReferralEngineError>) -> Void
    ) {
        if let appToken = KeychainCredentials.appToken,
           let authToken = KeychainCredentials.authToken,
           let tappToken = KeychainCredentials.tappToken {
            
            // Retrieve the bundle identifier
            guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                print("Error: Unable to retrieve bundle identifier")
                completion(.failure(.missingParameters))
                return
            }
            
            print("Bundle Identifier: \(bundleIdentifier)")
            
            let affiliateService = AffiliateServiceFactory.create(.tapp, appToken: appToken)
            affiliateService.affiliateUrl(
                tapp_token: tappToken,
                bundle_id: bundleIdentifier,
                mmp: mmp.intValue,
                adgroup: adgroup,
                creative: creative,
                influencer: influencer,
                authToken: authToken,
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
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            completion(nil)
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.getAttribution(completion: completion)
    }
    
    /// Sends a GDPR "Forget Me" request to Adjust.
    public func adjustGdprForgetMe() {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.gdprForgetMe()
    }
    
    /// Tracks third-party sharing preference in Adjust.
    public func adjustTrackThirdPartySharing(isEnabled: Bool) {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.trackThirdPartySharing(isEnabled: isEnabled)
    }
    
    /// Tracks ad revenue in Adjust.
    public func adjustTrackAdRevenue(source: String, revenue: Double, currency: String) {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.trackAdRevenue(source: source, revenue: revenue, currency: currency)
    }
    
    /// Verifies an App Store purchase with Adjust.
    public func adjustVerifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (ADJPurchaseVerificationResult) -> Void) {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            completion(ADJPurchaseVerificationResult())
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.verifyAppStorePurchase(transactionId: transactionId, productId: productId, completion: completion)
    }
    
    /// Sets the push notification token in Adjust.
    public func adjustSetPushToken(_ token: String) {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.setPushToken(token)
    }
    
    /// Retrieves the Adjust Device Identifier (ADID).
    public func adjustGetAdid(completion: @escaping (String?) -> Void) {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            completion(nil)
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.getAdid(completion: completion)
    }
    
    /// Retrieves the Identifier for Advertisers (IDFA).
    public func adjustGetIdfa(completion: @escaping (String?) -> Void) {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            completion(nil)
            return
        }
        let adjustService = AffiliateServiceFactory.createAdjustService(appToken: appToken)
        adjustService.getIdfa(completion: completion)
    }
    
    private func createAffiliateService(affiliate: Affiliate) -> AffiliateService? {
        guard let appToken = KeychainCredentials.appToken else {
            print("Error: Missing appToken in Keychain")
            return nil
        }
        return AffiliateServiceFactory.create(affiliate, appToken: appToken)
    }
    
    // MARK: - Use KeychainCredentials to track referral process state
    private func setProcessedReferralEngine() {
        KeychainCredentials.hasProcessedReferralEngine = true
    }
    
    private func hasProcessedReferralEngine() -> Bool {
        return KeychainCredentials.hasProcessedReferralEngine
    }
}
