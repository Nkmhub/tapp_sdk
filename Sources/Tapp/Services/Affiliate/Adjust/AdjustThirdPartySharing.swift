import Foundation
import AdjustSdk

@objc public final class AdjustThirdPartySharing: NSObject {
    let adjObject: ADJThirdPartySharing?

    @objc public var enabled: NSNumber? {
        return adjObject?.enabled
    }

    @objc public var granularOptions: NSMutableDictionary {
        return adjObject?.granularOptions ?? [:]
    }
    @objc public var partnerSharingSettings: NSMutableDictionary {
        return adjObject?.partnerSharingSettings ?? [:]
    }

    @objc
    public init(enabled: NSNumber? = nil) {
        self.adjObject = ADJThirdPartySharing(isEnabled: enabled)
        super.init()
    }

    @objc
    public func addGranularOption(partnerName: String, key: String, value: String) {
        adjObject?.addGranularOption(partnerName, key: key, value: value)
    }

    @objc
    public func addPartnerSharingSetting(partnerName: String, key: String, value: Bool) {
        adjObject?.addPartnerSharingSetting(partnerName, key: key, value: value)
    }
}
