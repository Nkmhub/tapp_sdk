import Foundation

public final class AdjustAttribution: NSObject {
    public var trackerToken: String?
    public var trackerName: String?
    public var network: String?
    public var campaign: String?
    public var adGroup: String?
    public var creative: String?
    public var clickLabel: String?
    public var costType: String?
    public var costAmount: NSNumber?
    public var costCurrency: String?

    public var dictionary: [AnyHashable: Any]? {
        return toADJAttribution.dictionary()
    }

    @objc
    public init(trackerToken: String? = nil,
                trackerName: String? = nil,
                network: String? = nil,
                campaign: String? = nil,
                adGroup: String? = nil,
                creative: String? = nil,
                clickLabel: String? = nil,
                costType: String? = nil,
                costAmount: NSNumber? = nil,
                costCurrency: String? = nil) {
        self.trackerToken = trackerToken
        self.trackerName = trackerName
        self.network = network
        self.campaign = campaign
        self.adGroup = adGroup
        self.creative = creative
        self.clickLabel = clickLabel
        self.costType = costType
        self.costAmount = costAmount
        self.costCurrency = costCurrency
    }
}
