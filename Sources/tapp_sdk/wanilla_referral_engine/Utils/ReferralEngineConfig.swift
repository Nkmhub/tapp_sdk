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

public struct TappEventConfig {
    public let event_name: String
    public let event_action: EventAction
    public let event_custom_action: String? // Optional since it only applies to custom actions
    
    public init(
        event_name: String,
        event_action: EventAction,
        event_custom_action: String? = nil
    ) {
        self.event_name = event_name
        self.event_action = event_action
        self.event_custom_action = event_custom_action
    }
    
    // Validate if event_action is .custom and event_custom_action is provided
    public func isValid() -> Bool {
        if case .custom = event_action {
            return event_custom_action != nil && !event_custom_action!.isEmpty
        }
        return true
    }
}

public enum EventAction {
    case click
    case impression
    case count
    case custom(String) // Associate a String value for custom actions
    
    public var rawValue: Int {
        switch self {
        case .click: return 1
        case .impression: return 2
        case .count: return 3
        case .custom: return -1
        }
    }
    
    public init?(rawValue: Int, customAction: String? = nil) {
        switch rawValue {
        case 1: self = .click
        case 2: self = .impression
        case 3: self = .count
        case -1:
            if let customAction = customAction, !customAction.isEmpty {
                self = .custom(customAction)
            } else {
                return nil // Invalid custom action without a String
            }
        default:
            return nil // Invalid raw value
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
