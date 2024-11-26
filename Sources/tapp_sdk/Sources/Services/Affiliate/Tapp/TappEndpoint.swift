//
//  TappEndpoint.swift
//

import Foundation

enum TappEndpoint: Endpoint {
    case generateURL(CreateAffiliateURLRequest)
    case deeplink(ImpressionRequest)
    case secrets(SecretsRequest)
    case tappEvent(TappEventRequest)

    var httpMethod: HTTPMethod {
        switch self {
        case .generateURL, .deeplink, .secrets, .tappEvent:
            return .post
        }
    }

    var path: String {
        switch  self {
        case .generateURL:
            return APIPath.add.prefixInfluencer
        case .deeplink:
            return APIPath.deeplink.rawValue
        case .secrets:
            return APIPath.secrets.rawValue
        case .tappEvent:
            return APIPath.event.rawValue
        }
    }

    var request: URLRequest? {
        switch self {
        case .generateURL(let requestData):
            return request(encodable: requestData)
        case .deeplink(let requestData):
            return request(encodable: requestData)
        case .secrets(let requestData):
            return request(encodable: requestData)
        case .tappEvent(let requestData):
            return request(encodable: requestData)
        }
    }
}
