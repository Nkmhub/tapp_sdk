import Foundation

public struct AdjustAttribution: Equatable {
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
}
