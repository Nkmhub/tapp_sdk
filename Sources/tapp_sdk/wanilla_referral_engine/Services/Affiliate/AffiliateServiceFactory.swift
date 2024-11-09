//
//  Affiliate.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  AffiliateServiceFactory.swift
//  wanilla_referral_engine/Services/Affiliate

import Foundation

public class AffiliateServiceFactory {
    public static func create(_ affiliate: Affiliate, appToken: String) -> AffiliateService {
        switch affiliate {
        case .adjust:
            return AdjustAffiliateService(appToken: appToken)
        case .appsflyer:
            return AppsflyerAffiliateService()
        case .tapp:
            return TappAffiliateService()
        }
    }
    
    public static func createAdjustService(appToken: String) -> AdjustAffiliateService {
           return AdjustAffiliateService(appToken: appToken)
       }
}

