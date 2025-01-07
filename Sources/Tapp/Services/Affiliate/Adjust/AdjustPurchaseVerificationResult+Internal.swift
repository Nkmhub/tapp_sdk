import Foundation
import AdjustSdk
extension AdjustPurchaseVerificationResult {
    init(adjResult: ADJPurchaseVerificationResult) {
        self.message = adjResult.message
        self.code = adjResult.code
        self.verificationStatus = adjResult.verificationStatus
    }
}
