//
//  CreateAffiliateURLRequest.swift
//

import Foundation

@objc
final class GenerateURLRequest: NSObject, Codable {
    let influencer: String
    let adGroup: String?
    let creative: String?
    let data: [String: String]?

    enum CodingKeys: String, CodingKey {
        case influencer
        case creative
        case adGroup = "adgroup"
        case data
    }

    @objc
    public init(influencer: String, adGroup: String? = nil, creative: String? = nil, data: [String: String]?) {
        self.influencer = influencer
        self.adGroup = adGroup
        self.creative = creative
        self.data = data
        super.init()
    }
}

struct CreateAffiliateURLRequest: Codable {
    private let tappToken: String
    private let bundleID: String
    private let mmp: Int
    private let influencer: String
    private let adGroup: String?
    private let creative: String?
    private let data: [String: String]?

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
         data: [String: String]?) {
        self.tappToken = tappToken
        self.bundleID = bundleID
        self.mmp = mmp
        self.influencer = influencer
        self.adGroup = adGroup
        self.creative = creative
        self.data = data
    }
}

@objc
public final class GeneratedURLResponse: NSObject, Codable {

    @objc
    public let url: URL

    enum CodingKeys: String, CodingKey {
        case url = "influencer_url"
    }
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
    private let url: String?

    enum CodingKeys: String, CodingKey {
        case tappToken = "tapp_token"
        case bundleID = "bundle_id"
        case eventName = "event_name"
        case url = "event_url"
    }

    init(tappToken: String, bundleID: String, eventName: String, url: String?) {
        self.tappToken = tappToken
        self.bundleID = bundleID
        self.eventName = eventName
        self.url = url
    }
}

@objc
public final class TappEvent: NSObject {
    let eventAction: EventAction

    public init(eventAction: EventAction) {
        self.eventAction = eventAction
        super.init()
    }

    @objc
    public init(eventActionName: String) {
        let mapper = EventActionMapper(eventActionName: eventActionName)
        let eventAction = mapper.eventAction
        self.eventAction = eventAction
        super.init()
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
