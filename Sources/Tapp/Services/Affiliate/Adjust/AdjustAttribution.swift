import Foundation

@objc
public final class AdjustAttribution: NSObject {
    @objc public var trackerToken: String?
    @objc public var trackerName: String?
    @objc public var network: String?
    @objc public var campaign: String?
    @objc public var adGroup: String?
    @objc public var creative: String?
    @objc public var clickLabel: String?
    @objc public var costType: String?
    @objc public var costAmount: NSNumber?
    @objc public var costCurrency: String?

    @objc
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
