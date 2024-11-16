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
        event_action: EventAction,
        event_custom_action: String?,
        completion: @escaping (Result<[String: Any], ReferralEngineError>) ->
            Void)
}
