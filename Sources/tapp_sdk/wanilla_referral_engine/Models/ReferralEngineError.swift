//
//  TappError.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  TappError.swift
//  wanilla_referral_engine/Models

import Foundation

public enum TappError: Error {
    case missingAppToken
    case missingAuthToken
    case missingTappToken
    case invalidURL
    case initializationFailed(affiliate: Affiliate, underlyingError: Error?)
    case alreadyProcessed
    case affiliateServiceError(affiliate: Affiliate, underlyingError: Error)
    case unknownError(details:String?)
    case apiError(message: String,endpoint: String)
    case networkError(message: String)
    case missingParameters(details: String? = nil) // Add details
    case eventActionMissing
    case missingConfiguration
    // You can add more cases as needed
}

extension TappError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingAppToken:
            return "The app token is missing."
        case .missingAuthToken:
            return "The authentication token is missing."
        case .missingTappToken:
            return "The Tapp token is missing."
        case .invalidURL:
            return "The provided URL is invalid."
        case .initializationFailed(let affiliate, let underlyingError):
            return "Initialization failed for \(affiliate). \(underlyingError?.localizedDescription ?? "")"
        case .alreadyProcessed:
            return "Referral engine processing has already been executed."
        case .affiliateServiceError(let affiliate, let underlyingError):
            return "An error occurred in \(affiliate): \(underlyingError.localizedDescription)"
        case .unknownError(let details):
            return "An unknown error occurred. \(details ?? "No additional details")"
        case .apiError(let message,let endpoint):
            return "API Error: \(message), on endpoint: \(endpoint)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .missingParameters(let details):
            return "Missing parameters: \(details ?? "No additional details")"
        case .eventActionMissing:
            return "event_custom_action is required when event_action is -1"
        case .missingConfiguration:
            return "missing configuration"
        }
    }
}
