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

public struct TappEventConfig {
    public let eventName: String
    public let eventAction: EventAction
    public let eventCustomAction: String?  // Optional since it only applies to custom actions

    public init(
        eventName: String,
        eventAction: EventAction,
        eventCustomAction: String? = nil
    ) {
        self.eventName = eventName
        self.eventAction = eventAction
        self.eventCustomAction = eventCustomAction
    }

    // Validate if event_action is .custom and event_custom_action is provided
    public func isValid() -> Bool {
        if case .custom = eventAction {
            return eventCustomAction != nil && !eventCustomAction!.isEmpty
        }
        return true
    }
}

public enum EventAction {
    case click
    case impression
    case count
    case custom(String)  // Associate a String value for custom actions

    public var rawValue: Int {
        switch self {
        case .click: return 1
        case .impression: return 2
        case .count: return 3
        case .custom: return -1
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
