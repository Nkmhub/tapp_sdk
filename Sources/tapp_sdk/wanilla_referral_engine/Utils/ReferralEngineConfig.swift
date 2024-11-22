//
//  ReferralEngineConfig.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

import Foundation

public final class ReferralEngineInitConfig: Codable {
    public let authToken: String
    public let env: Environment
    public let tappToken: String
    public let affiliate: Affiliate
    public let bundleID: String?
    private(set) var appToken: String?
    private(set) var hasProcessedReferralEngine: Bool = false

    public init(
        authToken: String,
        env: Environment,
        tappToken: String,
        affiliate: Affiliate
    ) {
        self.authToken = authToken
        self.env = env
        self.tappToken = tappToken
        self.affiliate = affiliate
        self.bundleID = Bundle.main.bundleIdentifier
    }

    public func set(appToken: String) {
        self.appToken = appToken
    }

    public func set(hasProcessedReferralEngine: Bool) {
        self.hasProcessedReferralEngine = hasProcessedReferralEngine
    }
}

public struct AffiliateURLConfiguration {
    public let influencer: String
    public let adgroup: String?
    public let creative: String?
    public let mmp: Affiliate
    public let data: [String: String]?

    public init(
        influencer: String,
        adgroup: String? = nil,
        creative: String? = nil,
        mmp: Affiliate,
        data: [String: String]?
    ) {
        self.influencer = influencer
        self.adgroup = adgroup
        self.creative = creative
        self.mmp = mmp
        self.data = data
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

public enum EventAction {
    case click
    case impression
    case count
    case custom(String)

    public var rawValue: Int {
        switch self {
        case .click:
            return 1
        case .impression:
            return 2
        case .count:
            return 3
        case .custom:
            return -1
        }
    }

    var isCustom: Bool {
        switch self {
        case .click, .impression, .count:
            return false
        case .custom:
            return true
        }
    }

    var isValid: Bool {
        switch self {
        case .click, .impression, .count:
            return true
        case .custom(let value):
            return !value.isEmpty
        }
    }

    var eventCustomAction: String {
        let defaultValue: String = "false"
        switch self {
        case .click, .impression, .count:
            return defaultValue
        case .custom(let value):
            return value.isEmpty ? defaultValue : value
        }
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
