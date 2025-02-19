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

    internal let authToken: String
    internal let env: Environment
    internal let tappToken: String
    internal let affiliate: Affiliate
    internal let bundleID: String?
    private(set) var originURL: URL?
    private(set) var appToken: String?
    private(set) var hasProcessedReferralEngine: Bool = false

    @objc
    public init(
        authToken: String,
        env: Environment,
        tappToken: String,
        affiliate: Affiliate,
        bundleID: String? = nil
    ) {
        self.authToken = authToken
        self.env = env
        self.tappToken = tappToken
        self.affiliate = affiliate
        self.bundleID = bundleID ?? Bundle.main.bundleIdentifier
        super.init()
    }

    @objc
    public init(
        authToken: String,
        env: String,
        tappToken: String,
        affiliateName: String,
        bundleID: String? = nil
    ) {
        self.authToken = authToken
        self.env = env.toEnvironment
        self.tappToken = tappToken
        self.affiliate = affiliateName.toAffiliate
        self.bundleID = bundleID ?? Bundle.main.bundleIdentifier
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

private extension String {
    var toAffiliate: Affiliate {
        if self.lowercased() == "adjust" {
            return .adjust
        } else if self.lowercased() == "appsflyer" {
            return .appsflyer
        } else {
            return .tapp
        }
    }

    var toEnvironment: Environment {
        if self.lowercased() == "production" {
            return .production
        } else if self.lowercased() == "sandbox" {
            return .sandbox
        } else {
            return .sandbox
        }
    }
}
