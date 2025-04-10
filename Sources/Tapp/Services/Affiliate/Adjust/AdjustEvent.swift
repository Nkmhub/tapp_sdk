import Foundation
import AdjustSdk

@objc public final class AdjustEvent: NSObject {
    @objc public let eventToken: String
    @objc
    public var revenue: NSNumber {
        return adjObject?.revenue ?? .init()
    }

    @objc
    public var currency: String {
        return adjObject?.currency ?? .empty
    }

    @objc
    public var deduplicationId: String {
        return adjObject?.deduplicationId ?? .empty
    }

    @objc
    public var callbackId: String {
        return adjObject?.callbackId ?? .empty
    }

    @objc
    public var transactionId: String {
        return adjObject?.transactionId ?? .empty
    }

    @objc
    public var productId: String {
        return adjObject?.productId ?? .empty
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
    public var isValid: Bool {
        return adjObject?.isValid() ?? false
    }

    @objc
    public func set(revenue: Double, currency: String) {
        adjObject?.setRevenue(revenue, currency: currency)
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
    public func setDeduplicationId(_ id: String) {
        adjObject?.setDeduplicationId(id)
    }

    @objc
    public func setCallbackId(_ id: String) {
        adjObject?.setCallbackId(id)
    }

    @objc
    public func setTransactionId(_ id: String) {
        adjObject?.setTransactionId(id)
    }

    @objc
    public func setProductId(_ id: String) {
        adjObject?.setProductId(id)
    }

    let adjObject: ADJEvent?

    init(eventToken: String) {
        let object = ADJEvent(eventToken: eventToken)
        self.adjObject = object
        self.eventToken = eventToken
    }
}
