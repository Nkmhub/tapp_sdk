//
//  AdjustAffiliateService.swift
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//
import Foundation
import AdjustSdk

final class AdjustAffiliateService: AdjustServiceProtocol {

    private(set) var isInitialized = false
    private let keychainHelper: KeychainHelperProtocol
    private let adjustInterface: AdjustInterfaceProtocol

    // Initialize with appToken
    init(keychainHelper: KeychainHelperProtocol,
         adjustInterface: AdjustInterfaceProtocol = AdjustInterface()) {
        self.keychainHelper = keychainHelper
        self.adjustInterface = adjustInterface
    }

    func initialize(environment: Environment, completion: VoidCompletion?) {
        guard !isInitialized else {
            Logger.logInfo("Adjust is already initialized.")
            completion?(.success(()))
            return
        }

        guard let token = keychainHelper.config?.appToken else {
            completion?(Result.failure(AffiliateServiceError.missingToken))
            return
        }

        adjustInterface.initialize(appToken: token,
                                   environment: environment)

        isInitialized = true
        Logger.logInfo("Adjust initialized successfully.")
        completion?(.success(()))
    }

    func handleCallback(with url: String) {
        guard let incomingURL = URL(string: url) else {
            Logger.logError(TappError.invalidURL)
            return
        }

        adjustInterface.processDeepLink(url: incomingURL)
    }

    func handleEvent(eventId: String, authToken: String?) {
        guard !eventId.isEmpty else {
            let error = TappError.missingParameters(details: "Event ID is empty.")
            Logger.logError(error)
            return
        }

        if adjustInterface.trackEvent(eventID: eventId) {
            Logger.logInfo("Tracked event on Adjust: \(eventId)")
        } else {
            let error = TappError.apiError(message:
                                            "Could not create ADJEvent with eventId \(eventId).",
                                           endpoint: "")
            Logger.logError(error)
        }
    }
}

extension AdjustAffiliateService {
    // MARK: - Attribution
    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void)
    {
        adjustInterface.getAttribution(completion: completion)
    }

    // MARK: - Privacy Compliance
    func gdprForgetMe() {
        adjustInterface.gdprForgetMe()
    }

    func trackThirdPartySharing(isEnabled: Bool) {
        adjustInterface.trackThirdPartySharing(isEnabled: isEnabled)
    }

    // MARK: - Monetization
    func trackAdRevenue(source: String,
                        revenue: Double,
                        currency: String) {
        adjustInterface.trackAdRevenue(source: source,
                                       revenue: revenue,
                                       currency: currency)
    }

    func verifyAppStorePurchase(transactionId: String,
                                productId: String,
                                completion: @escaping (AdjustPurchaseVerificationResult) -> Void) {
        adjustInterface.verifyAppStorePurchase(transactionId: transactionId,
                                               productId: productId,
                                               completion: completion)
    }

    // MARK: - Push Token
    func setPushToken(_ token: String) {
        adjustInterface.setPushToken(token)
    }

    // MARK: - Device IDs
    func getAdid(completion: @escaping (String?) -> Void) {
        adjustInterface.getAdid(completion: completion)
    }

    func getIdfa(completion: @escaping (String?) -> Void) {
        adjustInterface.getIdfa(completion: completion)
    }
}
