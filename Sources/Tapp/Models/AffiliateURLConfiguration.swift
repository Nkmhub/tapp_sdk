import Foundation

@objc
public final class AffiliateURLConfiguration: NSObject {
    public let influencer: String
    public let adgroup: String?
    public let creative: String?
    public let data: [String: String]?

    @objc
    public init(
        influencer: String,
        adgroup: String? = nil,
        creative: String? = nil,
        data: [String: String]? = nil
    ) {
        self.influencer = influencer
        self.adgroup = adgroup
        self.creative = creative
        self.data = data
        super.init()
    }
}
