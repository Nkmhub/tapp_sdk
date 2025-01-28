import Foundation
@testable import Tapp

final class SessionConfigurationMock: NSObject, SessionConfigurationProtocol {
    let configuration: URLSessionConfiguration = .default
}

final class URLSessionDataTaskProtocolMock: URLSessionDataTaskProtocol {
    let identifier: Int

    init(identifier: Int) {
        self.identifier = identifier
    }

    var resumeCalled: Bool = false
    func resume() {
        resumeCalled = true
    }

    var cancelCalled: Bool = false
    func cancel() {
        cancelCalled = true
    }
}

final class URLSessionMock: URLSessionProtocol {
    let identifier: Int
    init(identifier: Int = 1) {
        self.identifier = identifier
    }

    var serverError: ServerError?
    var error: Error?
    var data: Data?
    var receivedRequest: URLRequest?

    func internalDataTask(with request: URLRequest, taskCompletion: DataTaskCompletion) -> any URLSessionDataTaskProtocol {
        receivedRequest = request
        let dataTask =  URLSessionDataTaskProtocolMock(identifier: identifier)

        if let error {
            taskCompletion(nil, nil, error)
        } else if let serverError {
            taskCompletion(nil, nil, serverError)
        } else if let data {
            taskCompletion(data, nil, nil)
        }

        return dataTask
    }
}

final class KeychainHelperProtocolMock: KeychainHelperProtocol {

    var saveCalled: Bool = false
    var savedConfig: TappConfiguration?
    func save(config: TappConfiguration) {
        saveCalled = true
        savedConfig = config
    }
    
    var config: TappConfiguration?
}

final class AdjustInterfaceProtocolMock: AdjustInterfaceProtocol {
    var initializeCalled: Bool = false
    func initialize(appToken: String, environment: Environment) {
        initializeCalled = true
    }

    var processDeepLinkCalled: Bool = false
    func processDeepLink(url: URL, completion: ResolvedURLCompletion?) {
        processDeepLinkCalled = true
    }

    var trackEventCalled: Bool = false
    var trackEventID: String?
    var trackEventResult: Bool = true
    func trackEvent(eventID: String) -> Bool {
        trackEventCalled = true
        trackEventID = eventID
        return trackEventResult
    }

    var getAttributionCalled: Bool = false
    var attribution: AdjustAttribution?
    func getAttribution(completion: @escaping (AdjustAttribution?) -> Void) {
        getAttributionCalled = true
        completion(attribution)
    }

    var gdprForgetMeCalled: Bool = false
    func gdprForgetMe() {
        gdprForgetMeCalled = true
    }

    var trackThirdPartySharingCalled: Bool = false
    func trackThirdPartySharing(isEnabled: Bool) {
        trackThirdPartySharingCalled = true
    }

    var trackAdRevenueCalled: Bool = false
    func trackAdRevenue(source: String, revenue: Double, currency: String) {
        trackAdRevenueCalled = true
    }

    var verifyAppStorePurchaseCalled: Bool = false
    func verifyAppStorePurchase(transactionId: String, productId: String, completion: @escaping (AdjustPurchaseVerificationResult) -> Void) {
        verifyAppStorePurchaseCalled = true
    }

    var setPushTokenCalled: Bool = false
    func setPushToken(_ token: String) {
        setPushTokenCalled = true
    }

    var getAdidCalled: Bool = false
    func getAdid(completion: @escaping (String?) -> Void) {
        getAdidCalled = true
    }

    var getIdfaCalled: Bool = false
    func getIdfa(completion: @escaping (String?) -> Void) {
        getIdfaCalled = true
    }
}

final class NetworkClientProtocolMock: NetworkClientProtocol {

    var executeCompletion: NetworkServiceCompletion?
    var executeDataTask: URLSessionDataTaskProtocol?
    var executeData: Data?
    var executeError: Error?
    @discardableResult func execute(request: URLRequest, completion: NetworkServiceCompletion?) -> URLSessionDataTaskProtocol? {
        if let executeError {
            completion?(Result.failure(executeError))
        } else if let executeData {
            completion?(Result.success(executeData))
        }
        return executeDataTask
    }

    var executeAuthenticatedCompletion: NetworkServiceCompletion?
    var executeAuthenticatedDataTask: URLSessionDataTaskProtocol?
    var executeAuthenticatedData: Data?
    var executeAuthenticatedError: Error?
    @discardableResult func executeAuthenticated(request: URLRequest, completion: NetworkServiceCompletion?) -> URLSessionDataTaskProtocol? {

        if let executeAuthenticatedError {
            completion?(Result.failure(executeAuthenticatedError))

        } else if let executeAuthenticatedData {
            completion?(Result.success(executeAuthenticatedData))
        }

        return executeAuthenticatedDataTask
    }
}

final class DependenciesMock {
    let keychainHelper: KeychainHelperProtocolMock = .init()
    let networkClient: NetworkClientProtocolMock = .init()
    let tappAffiliateService: TappAffiliateServiceProtocolMock = .init()
    let adjustAffiliateService: AdjustServiceProtocolMock = .init()
    let appsFlyerAffiliateService: AppsFlyerAffiliateServiceProtocolMock = .init()
    let services: Services
    let dependencies: Dependencies

    init() {
        let services = Services(tappService: tappAffiliateService, adjustService: adjustAffiliateService, appsFlyerService: appsFlyerAffiliateService)
        self.services = services
        self.dependencies = Dependencies(keychainHelper: keychainHelper,
                                         networkClient: networkClient,
                                         services: services)
    }
}

