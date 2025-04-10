//
//  AdjustAffiliateService.swift
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//
import Foundation
import AdjustSdk

final class AdjustAffiliateService: AdjustServiceProtocol {
    fileprivate(set) var isInitialized = false
    let keychainHelper: KeychainHelperProtocol
    let adjustInterface: AdjustInterfaceProtocol

    // Initialize with appToken
    init(keychainHelper: KeychainHelperProtocol,
         adjustInterface: AdjustInterfaceProtocol = AdjustInterface()) {
        self.keychainHelper = keychainHelper
        self.adjustInterface = adjustInterface
    }

    func set(deferredLinkDelegate: DeferredLinkDelegate) {
        adjustInterface.set(deferredLinkDelegate: deferredLinkDelegate)
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

    func handleCallback(with url: String, completion: ResolvedURLCompletion?) {
        guard let incomingURL = URL(string: url) else {
            Logger.logError(TappError.invalidURL)
            return
        }

        adjustInterface.processDeepLink(url: incomingURL, completion: completion)
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

    func getIdfv(completion: @escaping (String?) -> Void) {
        adjustInterface.getIdfv(completion: completion)
    }

    func enable() {
        adjustInterface.enable()
    }
    func disable() {
        adjustInterface.disable()
    }

    func isEnabled(completion: @escaping (Bool?) -> Void) {
        adjustInterface.isEnabled(completion: completion)
    }

    func switchToOfflineMode() {
        adjustInterface.switchToOfflineMode()
    }

    func switchBackToOnlineMode() {
        adjustInterface.switchBackToOnlineMode()
    }

    func sdkVersion(completion: @escaping (String?) -> Void) {
        adjustInterface.sdkVersion(completion: completion)
    }

    func convert(universalLink: URL, with scheme: String) -> URL? {
        adjustInterface.convert(universalLink: universalLink, with: scheme)
    }

    func addGlobalCallbackParameter(_ parameter: String, key: String) {
        adjustInterface.addGlobalCallbackParameter(parameter, key: key)
    }

    func removeGlobalCallbackParameter(for key: String) {
        adjustInterface.removeGlobalCallbackParameter(for: key)
    }

    func removeGlobalCallbackParameters() {
        adjustInterface.removeGlobalCallbackParameters()
    }

    func addGlobalPartnerParameter(_ parameter: String, key: String) {
        adjustInterface.addGlobalPartnerParameter(parameter, key: key)
    }

    func removeGlobalPartnerParameter(for key: String) {
        adjustInterface.removeGlobalPartnerParameter(for: key)
    }

    func removeGlobalPartnerParameters() {
        adjustInterface.removeGlobalPartnerParameters()
    }

    func trackThirdPartySharing(_ thirdPartySharing: AdjustThirdPartySharing) {
        adjustInterface.trackThirdPartySharing(thirdPartySharing)
    }

    func trackMeasurementConsent(_ consent: Bool) {
        adjustInterface.trackMeasurementConsent(consent)
    }

    func trackAdRevenue(_ revenue: AdjustAdRevenue) {
        adjustInterface.trackAdRevenue(revenue)
    }

    func trackAppStoreSubscription(_ subscription: AdjustAppStoreSubscription) {
        adjustInterface.trackAppStoreSubscription(subscription)
    }

    func requestAppTrackingAuthorization(completionHandler: @escaping (UInt?) -> Void) {
        adjustInterface.requestAppTrackingAuthorization(completionHandler: completionHandler)
    }

    func appTrackingAuthorizationStatus() -> Int32 {
        adjustInterface.appTrackingAuthorizationStatus()
    }

    func updateSkanConversionValue(_ value: Int, coarseValue: String?, lockWindow: NSNumber?, completion: @escaping (Error?) -> Void) {
        adjustInterface.updateSkanConversionValue(value, coarseValue: coarseValue, lockWindow: lockWindow, completion: completion)
    }

    func verifyAppStorePurchase(transactionId: String,
                                productId: String,
                                completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        adjustInterface.verifyAppStorePurchase(transactionId: transactionId,
                                               productId: productId,
                                               completion: completion)
    }

    func verifyAndTrackAppStorePurchase(with event: AdjustEvent, completion: @escaping (AdjustPurchaseVerificationResult?) -> Void) {
        adjustInterface.verifyAndTrackAppStorePurchase(with: event, completion: completion)
    }
}
