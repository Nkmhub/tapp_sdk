//
//  AppsflyerAffiliateService.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  AppsflyerAffiliateService.swift
//  wanilla_referral_engine/Services/Affiliate

import Foundation

protocol AppsFlyerAffiliateServiceProtocol: AffiliateServiceProtocol {}

final class AppsflyerAffiliateService: AppsFlyerAffiliateServiceProtocol {

    fileprivate(set) var isInitialized = false
    let networkClient: NetworkClientProtocol
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func initialize(environment: Environment, completion: VoidCompletion?) {
        guard !isInitialized else {
            completion?(Result.success(()))
            return
        }

        Logger.logInfo("Initializing Appsflyer...")
        isInitialized = true
        completion?(Result.success(()))
    }

    func handleCallback(with url: String, completion: ResolvedURLCompletion?) {
        guard let validURL = URL(string: url) else {
            Logger.logError(TappError.invalidURL)
            return
        }

        Logger.logInfo("Handling Appsflyer callback with URL: \(validURL)")
        // Appsflyer-specific callback handling logic here
        completion?(Result.success(validURL))
    }

    func handleEvent(eventId: String, authToken: String?) {
        guard !eventId.isEmpty else {
            Logger.logError(
                TappError.missingParameters(
                    details: "Event ID is empty."))
            return
        }

        Logger.logInfo("Handling Appsflyer event with ID: \(eventId)")
        // Appsflyer-specific event handling logic here
    }
}
