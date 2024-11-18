//
//  TappSpecificService.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 16/11/24.
//

import Foundation

public protocol TappSpecificService {
    func handleTappEvent(
        authToken: String,
        tappToken: String,
        bundleID: String,
        eventName: String,
        eventAction: Int,
        eventCustomAction: String?
    )
    
    func getSecrets(
           authToken: String,
           tappToken: String,
           bundleID: String,
           mmp:Affiliate,
           completion: @escaping (Result<String, ReferralEngineError>) -> Void
       )
    
    func handleImpression(
        url: String,
        authToken: String,
        tappToken: String,
        bundleID: String,
        completion: @escaping (Result<[String: Any], Error>) -> Void)
}
