//
//  CreateAffiliateURLRequest.swift
//

/**let requestBody: [String: Any] = [
 "tapp_token": tappToken,
 "bundle_id": bundleID,
 "mmp": mmp,
 "adgroup": adgroup,
 "creative": creative,
 "influencer": influencer,
 "data": jsonObject,
]
*/

import Foundation

public struct GenerateURLRequest: Codable {
    let influencer: String
    let adGroup: String?
    let creative: String?
    let data: Data

    enum CodingKeys: String, CodingKey {
        case influencer
        case creative
        case adGroup = "adgroup"
        case data
    }

    public init(influencer: String, adGroup: String? = nil, creative: String? = nil, data: Data) {
        self.influencer = influencer
        self.adGroup = adGroup
        self.creative = creative
        self.data = data
    }
}

struct CreateAffiliateURLRequest: Codable {
    private let tappToken: String
    private let bundleID: String
    private let mmp: Int
    private let influencer: String
    private let adGroup: String?
    private let creative: String?
    private let data: Data

    enum CodingKeys: String, CodingKey {
        case tappToken = "tapp_token"
        case bundleID = "bundle_id"
        case mmp
        case influencer
        case creative
        case adGroup = "adgroup"
        case data
    }

    init(tappToken: String,
         bundleID: String,
         mmp: Int,
         influencer: String,
         adGroup: String? = nil,
         creative: String? = nil,
         data: Data) {
        self.tappToken = tappToken
        self.bundleID = bundleID
        self.mmp = mmp
        self.influencer = influencer
        self.adGroup = adGroup
        self.creative = creative
        self.data = data
    }
}

public struct GeneratedURLResponse: Codable {
    public let url: URL
}

struct ImpressionRequest: Codable {
    private let tappToken: String
    private let bundleID: String
    private let deepLink: URL

    enum CodingKeys: String, CodingKey {
        case tappToken = "tapp_token"
        case bundleID = "bundle_id"
        case deepLink = "deeplink"
    }

    init(tappToken: String, bundleID: String, deepLink: URL) {
        self.tappToken = tappToken
        self.bundleID = bundleID
        self.deepLink = deepLink
    }
}

struct TappEventRequest: Codable {
    private let tappToken: String
    private let bundleID: String
    private let eventName: String
    private let eventAction: Int
    private let eventCustomAction: String

    enum CodingKeys: String, CodingKey {
        case tappToken = "tapp_token"
        case bundleID = "bundle_id"
        case eventName = "event_name"
        case eventAction = "event_action"
        case eventCustomAction = "event_custom_action"
    }

    init(tappToken: String, bundleID: String, eventName: String, eventAction: Int, eventCustomAction: String) {
        self.tappToken = tappToken
        self.bundleID = bundleID
        self.eventName = eventName
        self.eventAction = eventAction
        self.eventCustomAction = eventCustomAction
    }
}

public struct TappEvent {
    let eventName: String
    let eventAction: EventAction

    public init(eventName: String, eventAction: EventAction) {
        self.eventName = eventName
        self.eventAction = eventAction
    }
}

struct SecretsRequest: Codable {
    private let tappToken: String
    private let bundleID: String
    private let mmp: Int

    enum CodingKeys: String, CodingKey {
        case tappToken = "tapp_token"
        case bundleID = "bundle_id"
        case mmp
    }

    init(tappToken: String, bundleID: String, mmp: Int) {
        self.tappToken = tappToken
        self.bundleID = bundleID
        self.mmp = mmp
    }
}

struct SecretsResponse: Codable {
    let secret: String
}
