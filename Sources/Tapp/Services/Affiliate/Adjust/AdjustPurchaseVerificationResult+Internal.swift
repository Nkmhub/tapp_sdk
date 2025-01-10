import Foundation
import AdjustSdk
extension AdjustPurchaseVerificationResult {
    convenience init(adjResult: ADJPurchaseVerificationResult) {
        self.init(message: adjResult.message,
                  code: adjResult.code,
                  verificationStatus: adjResult.verificationStatus)
    }
}
