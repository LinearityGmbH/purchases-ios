//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 16/5/2024.
//

import Foundation

@available(iOS 15.0, *)
struct CTAFooterMessageProvider {
    let locale: Locale
    static var bundle = Foundation.Bundle.module

    private let introOfferText = NSLocalizedString(
        "Footer.IntroOffering.Description",
        bundle: Self.bundle,
        value: "%1$@ free, then %2$@ from %3$@",
        comment: ""
    )
    func makeTextWithIntroOffer(_ variableDataProvider: VariableDataProvider) -> String {
        String(
            format: introOfferText,
            variableDataProvider.introductoryOfferDuration(locale) ?? "",
            variableDataProvider.localizedPricePerPeriod(locale, showZeroDecimalPlacePrices: true),
            variableDataProvider.subscriptionStartingDay(locale) ?? ""
        )
    }

    private let noIntroOfferText = NSLocalizedString(
        "Footer.NoIntroOffering.Description",
        bundle: Self.bundle,
        value: "%@ recurring, cancel anytime",
        comment: ""
    )
    func makeTextWithNoIntroOffer(_ variableDataProvider: VariableDataProvider) -> String {
        String(format: noIntroOfferText, variableDataProvider.localizedPricePerPeriodFull(locale, showZeroDecimalPlacePrices: true))
    }
}
