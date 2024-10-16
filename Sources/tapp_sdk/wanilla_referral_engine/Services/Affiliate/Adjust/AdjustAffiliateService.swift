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

    public func initialize(environment: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isInitialized else {
            print("Adjust is already initialized.")
            completion(.success(()))
            return
        }

        let adjustEnvironment = environment.lowercased() == "production" ? ADJEnvironmentProduction : ADJEnvironmentSandbox
        let adjustConfig = ADJConfig(appToken: appToken, environment: adjustEnvironment)
        Adjust.initSdk(adjustConfig)

        isInitialized = true
        completion(.success(()))
    }

    public func handleCallback(with url: String) {
        if let incomingURL = URL(string: url) {
            Adjust.processDeeplink(ADJDeeplink(deeplink: incomingURL)!)
            print("Adjust notified of the incoming URL: \(incomingURL)")
        }
    }
}
