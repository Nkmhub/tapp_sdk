import Foundation
import AdjustSdk

extension AdjustAttribution {
    convenience init?(adjAttribution: ADJAttribution?) {
        guard let adjAttribution else { return nil }

        self.init(trackerToken: adjAttribution.trackerToken,
                  trackerName: adjAttribution.trackerName,
                  network: adjAttribution.network,
                  campaign: adjAttribution.campaign,
                  adGroup: adjAttribution.adgroup,
                  creative: adjAttribution.creative,
                  clickLabel: adjAttribution.clickLabel,
                  costType: adjAttribution.costType,
                  costAmount: adjAttribution.costAmount,
                  costCurrency: adjAttribution.costCurrency)
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
