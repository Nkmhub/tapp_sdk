//
//  ReferralEngineConfig.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

import Foundation

@objc
public final class EventConfig: NSObject {
    public let affiliate: Affiliate
    public let eventToken: String

    @objc
    public init(affiliate: Affiliate, eventToken: String) {
        self.affiliate = affiliate
        self.eventToken = eventToken
        super.init()
    }
}
