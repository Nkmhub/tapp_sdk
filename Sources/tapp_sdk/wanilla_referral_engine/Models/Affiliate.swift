//
//  Models.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  Affiliate.swift
//  wanilla_referral_engine/Models

public enum Affiliate: String, Codable {
    case adjust
    case appsflyer
    case tapp

    var intValue: Int {
        switch self {
        case .adjust:
            return 1
        case .appsflyer:
            return 2
        case .tapp:
            return 3
        }
    }
}


public enum UrlAffiliate: String {
    case adjust
    case appsflyer
}
