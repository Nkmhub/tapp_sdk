//
//  AffiliateService.swift
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//
//  AffiliateService.swift
//  wanilla_referral_engine/Services/Affiliate

import Foundation

public protocol AffiliateService {
    func initialize(
        environment: Environment,
        completion: @escaping (Result<Void, Error>) -> Void)
    func handleCallback(with url: String)
    func handleEvent(eventId: String, authToken: String?)
    func affiliateUrl(
        tapp_token: String,
        bundle_id: String,
        mmp: Int,
        adgroup: String,
        creative: String,
        influencer: String,
        authToken: String,
        jsonObject: [String: Any],
        completion: @escaping (Result<[String: Any], ReferralEngineError>) ->
            Void)
    func handleImpression(
        url: String, authToken: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void)

}
