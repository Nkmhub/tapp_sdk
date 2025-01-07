import Foundation

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
