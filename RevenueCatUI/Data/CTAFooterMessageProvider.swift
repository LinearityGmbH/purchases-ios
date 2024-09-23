//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 16/5/2024.
//

import Foundation
import RevenueCat

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
    
    private let nonRenewableText = NSLocalizedString(
        "Footer.NonRenewable.Description",
        bundle: Self.bundle,
        value: "%@, cancel anytime",
        comment: ""
    )
    func makeTextWithNoIntroOffer(_ package: Package) -> String {
        if package.packageType == .custom {
            return String(format: nonRenewableText, package.localizedPricePerPeriodFull(locale, showZeroDecimalPlacePrices: true))
        }
        return String(format: noIntroOfferText, package.localizedPricePerPeriodFull(locale, showZeroDecimalPlacePrices: true))
    }
}
