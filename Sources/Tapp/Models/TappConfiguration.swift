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

    let mmpToken: String
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
        affiliate: Affiliate,
        mmpToken: String
    ) {
        self.authToken = authToken
        self.env = env
        self.tappToken = tappToken
        self.affiliate = affiliate
        self.mmpToken = mmpToken
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
