//
//  ReferralEngineConfig.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 11/11/24.
//

import Foundation

@objc
public final class TappConfiguration: NSObject, Codable {
    public static func == (lhs: TappConfiguration, rhs: TappConfiguration) -> Bool {
        let equalNonOptionalValues = lhs.authToken == rhs.authToken && lhs.env == rhs.env && lhs.tappToken == rhs.tappToken && lhs.affiliate == rhs.affiliate

        let lhsHasAppToken = lhs.appToken != nil
        let rhsHasAppToken = rhs.appToken != nil

        var appTokensEqual: Bool = false

        if let lhsAppToken = lhs.appToken, let rhsAppToken = rhs.appToken {
            appTokensEqual = lhsAppToken == rhsAppToken
        } else {
            if !lhsHasAppToken, !rhsHasAppToken {
                appTokensEqual = true
            }
        }

        return equalNonOptionalValues && appTokensEqual
    }
    
    let authToken: String
    let env: Environment
    let tappToken: String
    let affiliate: Affiliate
    let bundleID: String?
    private(set) var originURL: URL?
    private(set) var appToken: String?
    private(set) var hasProcessedReferralEngine: Bool = false

    @objc
    public init(
        authToken: String,
        env: Environment,
        tappToken: String,
        affiliate: Affiliate
    ) {
        self.authToken = authToken
        self.env = env
        self.tappToken = tappToken
        self.affiliate = affiliate
        self.bundleID = Bundle.main.bundleIdentifier
        super.init()
    }

    func set(appToken: String) {
        self.appToken = appToken
    }

    func set(originURL: URL) {
        self.originURL = originURL
    }

    func set(hasProcessedReferralEngine: Bool) {
        self.hasProcessedReferralEngine = hasProcessedReferralEngine
    }
}

@objc
public final class AffiliateURLConfiguration: NSObject {
    public let influencer: String
    public let adgroup: String?
    public let creative: String?
    public let mmp: Affiliate
    public let data: [String: String]?

    public init(
        influencer: String,
        adgroup: String? = nil,
        creative: String? = nil,
        mmp: Affiliate,
        data: [String: String]?
    ) {
        self.influencer = influencer
        self.adgroup = adgroup
        self.creative = creative
        self.mmp = mmp
        self.data = data
        super.init()
    }
}

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

public enum EventAction {
    case addPaymentInfo
    case addToCart
    case addToWishlist
    case completeRegistration
    case contact
    case customizeProduct
    case donate
    case findLocation
    case initiateCheckout
    case generateLead
    case purchase
    case schedule
    case search
    case startTrial
    case submitApplication
    case subscribe
    case viewContent
    case clickButton
    case downloadFile
    case joinGroup
    case achieveLevel
    case createGroup
    case createRole
    case linkClick
    case linkImpression
    case applyForLoan
    case loanApproval
    case loanDisbursal
    case login
    case rate
    case spendCredits
    case unlockAchievement
    case addShippingInfo
    case earnVirtualCurrency
    case startLevel
    case completeLevel
    case postScore
    case selectContent
    case beginTutorial
    case completeTutorial
    case custom(String)

    var isCustom: Bool {
        switch self {
        case .custom:
            return true
        default:
            return false
        }
    }

    var isValid: Bool {
        switch self {
        case .custom(let value):
            return !value.isEmpty
        default:
            return true
        }
    }

    var name: String {
        switch self {
        case .addPaymentInfo:
            return "tapp_add_payment_info"
        case .addToCart:
            return "tapp_add_to_cart"
        case .addToWishlist:
            return "tapp_add_to_wishlist"
        case .completeRegistration:
            return "tapp_complete_registration"
        case .contact:
            return "tapp_contact"
        case .customizeProduct:
            return "tapp_customize_product"
        case .donate:
            return "tapp_donate"
        case .findLocation:
            return "tapp_find_location"
        case .initiateCheckout:
            return "tapp_initiate_checkout"
        case .generateLead:
            return "tapp_generate_lead"
        case .purchase:
            return "tapp_purchase"
        case .schedule:
            return "tapp_schedule"
        case .search:
            return "tapp_search"
        case .startTrial:
            return "tapp_start_trial"
        case .submitApplication:
            return "tapp_submit_application"
        case .subscribe:
            return "tapp_subscribe"
        case .viewContent:
            return "tapp_view_content"
        case .clickButton:
            return "tapp_click_button"
        case .downloadFile:
            return "tapp_download_file"
        case .joinGroup:
            return "tapp_join_group"
        case .achieveLevel:
            return "tapp_achieve_level"
        case .createGroup:
            return "tapp_create_group"
        case .createRole:
            return "tapp_create_role"
        case .linkClick:
            return "tapp_link_click"
        case .linkImpression:
            return "tapp_link_impression"
        case .applyForLoan:
            return "tapp_apply_for_loan"
        case .loanApproval:
            return "tapp_loan_approval"
        case .loanDisbursal:
            return "tapp_loan_disbursal"
        case .login:
            return "tapp_login"
        case .rate:
            return "tapp_rate"
        case .spendCredits:
            return "tapp_spend_credits"
        case .unlockAchievement:
            return "tapp_unlock_achievement"
        case .addShippingInfo:
            return "tapp_add_shipping_info"
        case .earnVirtualCurrency:
            return "tapp_earn_virtual_currency"
        case .startLevel:
            return "tapp_start_level"
        case .completeLevel:
            return "tapp_complete_level"
        case .postScore:
            return "tapp_post_score"
        case .selectContent:
            return "tapp_select_content"
        case .beginTutorial:
            return "tapp_begin_tutorial"
        case .completeTutorial:
            return "tapp_complete_tutorial"
        case .custom(let string):
            return string
        }
    }
}
