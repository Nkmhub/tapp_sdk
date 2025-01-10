import Foundation

struct EventActionMapper {
    let eventActionName: String

    init(eventActionName: String) {
        self.eventActionName = eventActionName
    }

    var eventAction: EventAction {
        let dictionary = EventAction.allCases.nameDictionary
        if let eventAction = dictionary[eventActionName.lowercased()] {
            return eventAction
        }
        return .custom(eventActionName)
    }
}

public enum EventAction: CaseIterable, Equatable {
    public static var allCases: [EventAction] = [
        .addPaymentInfo,
        .addToCart,
        .addToWishlist,
        .completeRegistration,
        .contact,
        .customizeProduct,
        .donate,
        .findLocation,
        .initiateCheckout,
        .generateLead,
        .purchase,
        .schedule,
        .search,
        .startTrial,
        .submitApplication,
        .subscribe,
        .viewContent,
        .clickButton,
        .downloadFile,
        .joinGroup,
        .achieveLevel,
        .createGroup,
        .createRole,
        .linkClick,
        .linkImpression,
        .applyForLoan,
        .loanApproval,
        .loanDisbursal,
        .login,
        .rate,
        .spendCredits,
        .unlockAchievement,
        .addShippingInfo,
        .earnVirtualCurrency,
        .startLevel,
        .completeLevel,
        .postScore,
        .selectContent,
        .beginTutorial,
        .completeTutorial
    ]

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

private extension Array where Element == EventAction {
    var nameDictionary: [String: EventAction] {
        var dictionary: [String: EventAction] = [:]
        forEach { action in
            dictionary[action.name.lowercased()] = action
        }
        return dictionary
    }
}
