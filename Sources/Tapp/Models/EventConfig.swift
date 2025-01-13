//
//  ReferralEngineConfig.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

import Foundation

@objc
public final class EventConfig: NSObject {
    public let eventToken: String

    @objc
    public init(eventToken: String) {
        self.eventToken = eventToken
        super.init()
    }
}
