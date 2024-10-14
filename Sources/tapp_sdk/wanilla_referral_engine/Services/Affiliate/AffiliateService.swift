//
//  AffiliateService.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  AffiliateService.swift
//  wanilla_referral_engine/Services/Affiliate

import Foundation

public protocol AffiliateService {
    func initialize(environment: String, completion: @escaping (Result<Void, Error>) -> Void)
    func handleCallback(with url: String)
}
