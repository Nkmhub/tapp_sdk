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
    case missingUid(String)
    case apiError(String)
    case missingParameters
    case networkError(String)
    case invalidResponse
    case unknownErrorL
}
