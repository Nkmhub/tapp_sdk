import Foundation

@objc
public final class AdjustPurchaseVerificationResult: NSObject {
    public var message: String
    public var code: Int32
    public var verificationStatus: String

    @objc
    public init(message: String, code: Int32, verificationStatus: String) {
        self.message = message
        self.code = code
        self.verificationStatus = verificationStatus
    }
}
