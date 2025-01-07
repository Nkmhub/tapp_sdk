import Foundation
import AdjustSdk

extension AdjustAttribution {
    init?(adjAttribution: ADJAttribution?) {
        guard let adjAttribution else { return nil }

        self.trackerToken = adjAttribution.trackerToken
        self.trackerName = adjAttribution.trackerName
        self.network = adjAttribution.network
        self.campaign = adjAttribution.campaign
        self.adGroup = adjAttribution.adgroup
        self.creative = adjAttribution.creative
        self.clickLabel = adjAttribution.clickLabel
        self.costType = adjAttribution.costType
        self.costAmount = adjAttribution.costAmount
        self.costCurrency = adjAttribution.costCurrency
    }

    var toADJAttribution: ADJAttribution {
        let attribution = ADJAttribution()

        attribution.trackerToken = trackerToken
        attribution.trackerName = trackerName
        attribution.network = network
        attribution.campaign = campaign
        attribution.adgroup = adGroup
        attribution.creative = creative
        attribution.clickLabel = clickLabel
        attribution.costType = costType
        attribution.costAmount = costAmount
        attribution.costCurrency = costCurrency

        return attribution
    }
}
