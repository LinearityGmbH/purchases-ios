//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 16/5/2024.
//

import Foundation

struct CTAFooterMessageProvider {
    let locale: Locale
    
    private let introOfferText = Bundle.main.localizedString(
        forKey: "Offering.IntroOffering.Description",
        value: "%1$@ free, then %2$@ from %3$@",
        table: "Paywall"
    )
    func makeTextWithIntroOffer(_ variableDataProvider: VariableDataProvider) -> String {
        String(
            format: introOfferText,
            variableDataProvider.introductoryOfferDuration(locale) ?? "",
            variableDataProvider.localizedPricePerPeriod(locale),
            variableDataProvider.subscriptionStartingDay(locale) ?? ""
        )
    }

    private let noIntroOfferText = Bundle.main.localizedString(
        forKey: "Offering.NoIntroOffering.Description",
        value: "%@ recurring, cancel anytime",
        table: "Paywall"
    )
    func makeTextWithNoIntroOffer(_ variableDataProvider: VariableDataProvider) -> String {
        String(format: noIntroOfferText, variableDataProvider.localizedPricePerPeriodFull(locale))
    }
}
