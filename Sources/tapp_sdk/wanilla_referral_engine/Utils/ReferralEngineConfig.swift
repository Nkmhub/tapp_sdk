//
//  ReferralEngineConfig.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

import Foundation

public struct ReferralEngineConfig {
    public let url: String?
    public let authToken: String
    public let env: Environment
    public let tappToken: String
    public let affiliate: Affiliate

    public init(
        url: String?,
        authToken: String,
        env: Environment,
        tappToken: String,
        affiliate: Affiliate
    ) {
        self.url = url
        self.authToken = authToken
        self.env = env
        self.tappToken = tappToken
        self.affiliate = affiliate
    }
}

public struct AffiliateUrlConfig {
    public let influencer: String
    public let adgroup: String
    public let creative: String
    public let mmp: Affiliate
    public let jsonObject: [String: Any]

    public init(
        influencer: String,
        adgroup: String,
        creative: String,
        mmp: Affiliate,
        jsonObject: [String: Any]
    ) {
        self.influencer = influencer
        self.adgroup = adgroup
        self.creative = creative
        self.mmp = mmp
        self.jsonObject = jsonObject
    }
}


public struct EventConfig {
    public let affiliate: Affiliate
    public let eventToken: String

    public init(affiliate: Affiliate, eventToken: String) {
        self.affiliate = affiliate
        self.eventToken = eventToken
    }
}

public struct AdRevenueConfig {
    public let source: String
    public let revenue: Double
    public let currency: String

    public init(source: String, revenue: Double, currency: String) {
        self.source = source
        self.revenue = revenue
        self.currency = currency
    }
}


public struct PurchaseVerificationConfig {
    public let transactionId: String
    public let productId: String

    public init(transactionId: String, productId: String) {
        self.transactionId = transactionId
        self.productId = productId
    }
}

public struct PushTokenConfig {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}
