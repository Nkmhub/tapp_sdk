import Foundation
import AdjustSdk

@objc public final class AdjustAppStorePurchase: NSObject {
    let adjObject: ADJAppStorePurchase?

    @objc
    public var transactionId: NSString {
        let value = adjObject?.transactionId as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public var productId: NSString {
        let value = adjObject?.productId as? NSString
        return (value?.copy() as? NSString) ?? String.emptyNSString
    }

    @objc
    public init?(transactionId: String, productId: String) {
        self.adjObject = ADJAppStorePurchase(transactionId: transactionId, productId: productId)
        super.init()
    }
}
