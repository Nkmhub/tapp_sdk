//
//  ReferralEngineError.swift
//  test_app
//
//  Created by Nikolaos Tseperkas on 28/9/24.
//

//  ReferralEngineError.swift
//  wanilla_referral_engine/Models

import Foundation

public enum ReferralEngineError: Error {
    case missingAppToken
    case missingAuthToken
    case missingTappToken
    case missingParameters
    case invalidURL
    case initializationFailed(affiliate: Affiliate, underlyingError: Error?)
    case alreadyProcessed
    case affiliateServiceError(affiliate: Affiliate, underlyingError: Error)
    case unknownError
    case apiError(message: String)
    case networkError(message: String)
    // You can add more cases as needed
}

extension ReferralEngineError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingAppToken:
            return "The app token is missing."
        case .missingAuthToken:
            return "The authentication token is missing."
        case .missingTappToken:
            return "The Tapp token is missing."
        case .missingParameters:
            return "Required parameters are missing."
        case .invalidURL:
            return "The provided URL is invalid."
        case .initializationFailed(let affiliate, let underlyingError):
            return "Initialization failed for \(affiliate). \(underlyingError?.localizedDescription ?? "")"
        case .alreadyProcessed:
            return "Referral engine processing has already been executed."
        case .affiliateServiceError(let affiliate, let underlyingError):
            return "An error occurred in \(affiliate): \(underlyingError.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred."
        case .apiError(let message):
            return "API Error: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        }
    }
}
