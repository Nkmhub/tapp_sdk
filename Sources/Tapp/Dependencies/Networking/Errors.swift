//
//  Errors.swift
//

import Foundation

public enum ServiceError: Error {
    case invalidRequest
    case invalidURL
    case invalidData
    case invalidID
    case unauthorized
    case unprocessableEntity
    case noNetwork
    case notFound
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
