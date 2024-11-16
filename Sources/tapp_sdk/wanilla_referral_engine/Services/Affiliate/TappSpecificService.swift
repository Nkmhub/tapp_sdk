//
//  TappSpecificService.swift
//  tapp_sdk
//
//  Created by Nikolaos Tseperkas on 16/11/24.
//

import Foundation

public protocol TappSpecificService {
    func handleTappEvent(
        auth_token: String,
        tapp_token: String,
        bundle_id: String,
        event_name: String,
        event_action: Int,
        event_custom_action: String?
    )
    
    func getSecrets(
           auth_token: String,
           tapp_token: String,
           bundle_id: String,
           mmp:Affiliate,
           completion: @escaping (Result<String, ReferralEngineError>) -> Void
       )
}
