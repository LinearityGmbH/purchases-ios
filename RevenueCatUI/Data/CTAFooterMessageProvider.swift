//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 16/5/2024.
//

import Foundation

struct CTAFooterMessageProvider {
    let locale: Locale
    static var bundle = Foundation.Bundle.main

    private let introOfferText = NSLocalizedString(
        "Offering.IntroOffering.Description",
        bundle: Self.bundle,
        value: "%1$@ free, then %2$@ from %3$@",
        comment: ""
    )
    func makeTextWithIntroOffer(_ variableDataProvider: VariableDataProvider) -> String {
        String(
            format: introOfferText,
            variableDataProvider.introductoryOfferDuration(locale) ?? "",
            variableDataProvider.localizedPricePerPeriod(locale),
            variableDataProvider.subscriptionStartingDay(locale) ?? ""
        )
    }

    private let noIntroOfferText = NSLocalizedString(
        "Offering.NoIntroOffering.Description",
        bundle: Self.bundle,
        value: "%@ recurring, cancel anytime",
        comment: ""
    )
    func makeTextWithNoIntroOffer(_ variableDataProvider: VariableDataProvider) -> String {
        String(format: noIntroOfferText, variableDataProvider.localizedPricePerPeriodFull(locale))
    }
}
