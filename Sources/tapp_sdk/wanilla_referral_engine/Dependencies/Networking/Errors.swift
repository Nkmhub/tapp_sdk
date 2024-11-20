//
//  Errors.swift
//

import Foundation

enum ServiceError: Error {
    case invalidRequest
    case invalidURL
    case invalidData
    case invalidID
    case unauthorized

    case noNetwork
}

struct ServerError: Error, Codable {
    let error: Bool
    let reason: String

    enum ErrorType: String {
        case other
    }

    var type: ErrorType {
        return ErrorType(rawValue: reason) ?? .other
    }
}
