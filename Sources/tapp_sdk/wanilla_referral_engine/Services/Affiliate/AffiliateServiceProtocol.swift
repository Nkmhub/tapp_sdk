//
//  AffiliateService.swift
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//
//  AffiliateService.swift
//  wanilla_referral_engine/Services/Affiliate

import Foundation

enum AffiliateServiceError: Error {
    case missingToken
}

public protocol AffiliateServiceProtocol {
    func initialize(environment: Environment,
                    completion: @escaping (Result<Void, Error>) -> Void)

    func handleCallback(with url: String)
    func handleEvent(eventId: String, authToken: String?)
}
