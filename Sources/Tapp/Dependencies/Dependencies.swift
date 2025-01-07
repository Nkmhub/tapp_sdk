//
//  Dependencies.swift
//

final class Dependencies {
    let keychainHelper: KeychainHelperProtocol
    let networkClient: NetworkClientProtocol
    let services: Services

    init(keychainHelper: KeychainHelperProtocol,
         networkClient: NetworkClientProtocol,
         services: Services) {
        self.keychainHelper = keychainHelper
        self.networkClient = networkClient
        self.services = services
    }
}

final class Services {
    let tappService: TappAffiliateServiceProtocol
    let adjustService: AdjustServiceProtocol
    let appsFlyerService: AppsFlyerAffiliateServiceProtocol

    init(tappService: TappAffiliateServiceProtocol,
         adjustService: AdjustServiceProtocol,
         appsFlyerService: AppsFlyerAffiliateServiceProtocol) {
        self.tappService = tappService
        self.adjustService = adjustService
        self.appsFlyerService = appsFlyerService
    }
}

extension Dependencies {
    static var live: Dependencies {
        let keychainHelper: KeychainHelperProtocol = KeychainHelper.shared
        let networkClient: NetworkClientProtocol = NetworkClient(sessionConfiguration: SessionConfiguration(),
                                                                 keychainHelper: keychainHelper)

        let tappService: TappAffiliateServiceProtocol = TappAffiliateService(keychainHelper: keychainHelper,
                                                                             networkClient: networkClient)
        let adjustService: AdjustServiceProtocol = AdjustAffiliateService(keychainHelper: keychainHelper)
        let appsFlyerService: AppsFlyerAffiliateServiceProtocol = AppsflyerAffiliateService(networkClient: networkClient)
        let services = Services(tappService: tappService,
                                adjustService: adjustService,
                                appsFlyerService: appsFlyerService)

        let dependencies = Dependencies(keychainHelper: keychainHelper,
                                        networkClient: networkClient,
                                        services: services)

        return dependencies
    }
}
