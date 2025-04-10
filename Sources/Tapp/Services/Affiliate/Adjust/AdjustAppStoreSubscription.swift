import Foundation
import AdjustSdk

@objc public final class AdjustAppStoreSubscription: NSObject {
    let adjObject: ADJAppStoreSubscription?

    @objc
    public var price: NSDecimalNumber {
        return adjObject?.price ?? .init()
    }

    @objc
    public var currency: NSString {
        let value = adjObject?.currency as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var transactionId: NSString {
        let value = adjObject?.transactionId as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var transactionDate: Date? {
        return adjObject?.transactionDate
    }

    @objc
    public var salesRegion: NSString {
        let value = adjObject?.salesRegion as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var callbackParameters: NSDictionary {
        return (adjObject?.callbackParameters as? NSDictionary) ?? .init()
    }

    @objc
    public var partnerParameters: NSDictionary {
        return (adjObject?.partnerParameters as? NSDictionary) ?? .init()
    }

    @objc
    public init?(price: NSDecimalNumber, currency: String, transactionId: String) {
        self.adjObject = ADJAppStoreSubscription(price: price,
                                                 currency: currency,
                                                 transactionId: transactionId)
        super.init()
    }
}
