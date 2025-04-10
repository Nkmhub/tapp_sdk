import Foundation
import AdjustSdk

@objc public final class AdjustAdRevenue: NSObject {
    let adjObject: ADJAdRevenue?

    @objc
    public var source: NSString {
        let value = adjObject?.source as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var revenue: NSNumber {
        return adjObject?.revenue ?? .init()
    }

    @objc
    public var currency: NSString {
        let value = adjObject?.currency as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var adImpressionsCount: NSNumber {
        return adjObject?.adImpressionsCount ?? .init()
    }

    @objc
    public var adRevenueNetwork: NSString {
        let value = adjObject?.adRevenueNetwork as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var adRevenueUnit: NSString {
        let value = adjObject?.adRevenueUnit as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var adRevenuePlacement: NSString {
        let value = adjObject?.adRevenuePlacement as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var partnerParameters: NSDictionary {
        return (adjObject?.partnerParameters as? NSDictionary) ?? .init()
    }

    @objc
    public var callbackParameters: NSDictionary {
        return (adjObject?.callbackParameters as? NSDictionary) ?? .init()
    }

    @objc
    public init?(source: String) {
        self.adjObject = ADJAdRevenue(source: source)
        super.init()
    }

    @objc
    public func setRevenue(amount: Double, currency: String) {
        adjObject?.setRevenue(amount, currency: currency)
    }

    @objc
    public func setAdImpressionsCount(_ count: Int32) {
        adjObject?.setAdImpressionsCount(count)
    }

    @objc
    public func setAdRevenueNetwork(_ network: String) {
        adjObject?.setAdRevenueNetwork(network)
    }

    @objc
    public func setAdRevenueUnit(_ unit: String) {
        adjObject?.setAdRevenueUnit(unit)
    }

    @objc
    public func setAdRevenuePlacement(_ placement: String) {
        adjObject?.setAdRevenuePlacement(placement)
    }

    @objc
    public func addCallbackParameter(key: String, value: String) {
        adjObject?.addCallbackParameter(key, value: value)
    }

    @objc
    public func addPartnerParameter(key: String, value: String) {
        adjObject?.addPartnerParameter(key, value: value)
    }

    @objc
    public var isValid: Bool {
        return adjObject?.isValid() ?? false
    }
}

extension String {
    static var empty: String {
        return ""
    }

    static var emptyNSString: NSString {
        return String.empty as NSString
    }
}
