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

struct ServerError: Error, Codable, Equatable {
    let error: Bool
    let reason: String

    init(error: Bool, reason: String) {
        self.error = error
        self.reason = reason
    }

    enum ErrorType: String {
        case other
    }

    var type: ErrorType {
        return ErrorType(rawValue: reason) ?? .other
    }
}
