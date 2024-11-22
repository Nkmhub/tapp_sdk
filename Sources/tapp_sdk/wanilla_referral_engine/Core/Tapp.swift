import AdjustSdk
import Foundation

public class Tapp {
    static let single: Tapp = .init()
    let dependencies: Dependencies = .live
    private var isFetchingSecrets = false
    private var secretsFetchCompletionHandlers: [VoidCompletion] = []
    private let synchronizationQueue = DispatchQueue(label: "com.tapp.secretsFetchQueue")

    private init() {}


    // MARK: - Configuration
    // AppDelegate: Called upon didFinishLaunching
    public static func start(config: ReferralEngineInitConfig) {
        KeychainHelper.shared.save(config: config)

        single.fetchSecretsAndInitializeReferralEngineIfNeeded(completion: nil)
    }
    // MARK: - Process Referral Engine

    //AppDelegate called when receiving a url
    public static func appWillOpen(_ url: URL, completion: VoidCompletion?) {
        guard let config = KeychainHelper.shared.config else {
            completion?(Result.failure(TappError.missingConfiguration))
            return
        }

        single.appWillOpen(url, authToken: config.authToken, completion: completion)
    }

    public static func url(config: AffiliateURLConfiguration,
                    completion: GenerateURLCompletion?) {
        single.fetchSecretsAndInitializeReferralEngineIfNeeded { result in
            switch result {
            case .success:
                let request = GenerateURLRequest(influencer: config.influencer, adGroup: config.adgroup, creative: config.creative, data: config.data)

                single.dependencies.services.tappService.url(request: request, completion: completion)
            case .failure(let error):
                completion?(Result.failure(error))
            }
        }
    }

    // MARK: - Handle Event
    //For MMP Specific events
    public static func handleEvent(config: EventConfig) {
        guard let storedConfig = KeychainHelper.shared.config else { return }
        single.affiliateService?.handleEvent(eventId: config.eventToken,
                                             authToken: storedConfig.authToken)
    }

    //For Tapp Events
    public static func handleTappEvent(event: TappEvent) {
        guard event.eventAction.isValid else {
            Logger.logError(TappError.eventActionMissing)
            return
        }

        single.dependencies.services.tappService.sendTappEvent(event: event, completion: nil)
    }
}

//MARK: - AppWillOpen + Processing
private extension Tapp {
    private func handleReferralCallback(url: URL,
                                        authToken: String,
                                        completion: VoidCompletion? = nil) {

        dependencies.services.tappService.handleImpression(url: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.affiliateService?.handleCallback(with: url.absoluteString)
                self.setProcessedReferralEngine()
            case .failure(let error):
                completion?(self.affiliateErrorResult(error: error, affiliate: .tapp))
            }
        }
    }
    
    private func secrets(config: ReferralEngineInitConfig, completion: VoidCompletion?) {
        synchronizationQueue.async {
            guard let storedConfig = KeychainHelper.shared.config else {
                completion?(Result.failure(TappError.missingConfiguration))
                return
            }

            if storedConfig.appToken != nil {
                // Secrets are already fetched
                completion?(.success(()))
                return
            }

            // Fetch secrets from the service
            self.dependencies.services.tappService.secrets(affiliate: config.affiliate) { [unowned config] result in
                switch result {
                case .success(let response):
                    storedConfig.set(appToken: response.secret)
                    KeychainHelper.shared.save(config: storedConfig)
                    completion?(.success(()))
                case .failure(let error):
                    completion?(Result.failure(error))
                }
            }
        }
    }



    private func appWillOpen(_ url: URL, authToken: String, completion: VoidCompletion?) {
        fetchSecretsAndInitializeReferralEngineIfNeeded { [weak self] result in
            switch result {
            case .success:
                self?.handleReferralCallback(url: url, authToken: authToken, completion: completion)
            case .failure(let error):
                completion?(Result.failure(error))
            }
        }
    }


    private func fetchSecretsAndInitializeReferralEngineIfNeeded(completion: VoidCompletion?) {
        synchronizationQueue.async {
            // Check if secrets are already fetched
            if let config = KeychainHelper.shared.config, config.appToken != nil {
                // Secrets are already fetched, proceed to initialize affiliate service
                DispatchQueue.main.async {
                    self.initializeAffiliateService(completion: completion)
                }
                return
            }

            // If secrets are being fetched, add the completion handler to the queue and return
            if self.isFetchingSecrets {
                if let completion = completion {
                    self.secretsFetchCompletionHandlers.append(completion)
                }
                return
            }

            // Start fetching secrets
            self.isFetchingSecrets = true

            // Add the current completion handler to the queue
            if let completion = completion {
                self.secretsFetchCompletionHandlers.append(completion)
            }

            // Proceed to fetch secrets
            guard let config = KeychainHelper.shared.config else {
                self.completeSecretsFetch(with: .failure(TappError.missingConfiguration))
                return
            }

            self.secrets(config: config) { result in
                switch result {
                case .success:
                    self.initializeAffiliateService { initResult in
                        self.completeSecretsFetch(with: initResult)
                    }
                case .failure(let error):
                    let affiliateErrorResult = self.affiliateErrorResult(error: error, affiliate: config.affiliate)
                    self.completeSecretsFetch(with: affiliateErrorResult)
                }
            }
        }
    }
    
    private func completeSecretsFetch(with result: Result<Void, Error>) {
        synchronizationQueue.async {
            // Reset the fetching flag
            self.isFetchingSecrets = false

            // Capture the completion handlers and clear the array
            let completionHandlers = self.secretsFetchCompletionHandlers
            self.secretsFetchCompletionHandlers = []

            // Call each completion handler
            DispatchQueue.main.async {
                for handler in completionHandlers {
                    handler(result)
                }
            }
        }
    }

    private func initializeAffiliateService(completion: VoidCompletion?) {
        guard let service = affiliateService else {
            completion?(Result.failure(TappError.missingParameters(details: "Affiliate service not configured")))
            return
        }

        guard let storedConfig = KeychainHelper.shared.config else {
            completion?(Result.failure(TappError.missingParameters(details:
                            "Missing required credentials or bundle identifier")))
            return
        }


        service.initialize(environment: storedConfig.env, completion: completion)
    }

    // MARK: - Referral Engine State Management
    private func setProcessedReferralEngine() {
        guard let storedConfig = KeychainHelper.shared.config else { return }
        storedConfig.set(hasProcessedReferralEngine: true)
        KeychainHelper.shared.save(config: storedConfig)
    }

    private func hasProcessedReferralEngine() -> Bool {
        return KeychainHelper.shared.config?.hasProcessedReferralEngine ?? false
    }

    private func affiliateErrorResult(error: any Error, affiliate: Affiliate) -> Result<Void, Error> {
        return Result.failure(TappError.affiliateServiceError(affiliate: affiliate, underlyingError: error))
    }
}

private extension Tapp {
    var affiliateService: AffiliateServiceProtocol? {
        guard let config = dependencies.keychainHelper.config else { return nil }

        switch config.affiliate {
        case .tapp:
            return dependencies.services.tappService
        case .adjust:
            return dependencies.services.adjustService
        case .appsflyer:
            return dependencies.services.appsFlyerService
        }
    }
}
