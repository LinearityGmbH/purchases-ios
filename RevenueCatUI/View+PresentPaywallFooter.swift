//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  View+PresentPaywallFooter.swift
//
//  Created by Josh Holtz on 8/18/23.

import RevenueCat
import SwiftUI

#if !os(watchOS) && !os(tvOS) && !os(macOS)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
extension View {

    // swiftlint:disable line_length
    /// Presents a ``PaywallFooterView`` at the bottom of a view that loads the `Offerings.current`.
    /// ```swift
    /// var body: some View {
    ///    YourPaywall()
    ///      .paywallFooter()
    /// }
    /// ```
    ///
    /// ### Related Articles
    /// [Documentation](https://rev.cat/paywalls)
    @available(iOS, deprecated: 1, renamed: "paywallFooter(condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(tvOS, deprecated: 1, renamed: "paywallFooter(condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(watchOS, deprecated: 1, renamed: "paywallFooter(condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(macOS, deprecated: 1, renamed: "paywallFooter(condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(macCatalyst, deprecated: 1, renamed: "paywallFooter(condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    // swiftlint:enable line_length
    public func paywallFooter(
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
        purchaseStarted: @escaping PurchaseStartedHandler,
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseCancelled: PurchaseCancelledHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseFailure: PurchaseFailureHandler? = nil,
        restoreFailure: PurchaseFailureHandler? = nil
    ) -> some View {
        return self.paywallFooter(
            condensed: condensed,
            fonts: fonts,
            purchaseStarted: { _ in
                purchaseStarted()
            },
            purchaseCompleted: purchaseCompleted,
            purchaseCancelled: purchaseCancelled,
            restoreStarted: nil,
            restoreCompleted: restoreCompleted,
            purchaseFailure: purchaseFailure,
            restoreFailure: restoreFailure
        )
    }

    /// Presents a ``PaywallFooterView`` at the bottom of a view that loads the `Offerings.current`.
    /// ```swift
    /// var body: some View {
    ///    YourPaywall()
    ///      .paywallFooter()
    /// }
    /// ```
    ///
    /// ### Related Articles
    /// [Documentation](https://rev.cat/paywalls)
    public func paywallFooter(
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
<<<<<<< HEAD
        purchaseHandler: PurchaseHandler,
=======
        purchaseStarted: PurchaseOfPackageStartedHandler? = nil,
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseCancelled: PurchaseCancelledHandler? = nil,
        restoreStarted: RestoreStartedHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseFailure: PurchaseFailureHandler? = nil,
        restoreFailure: PurchaseFailureHandler? = nil
    ) -> some View {
        return self.paywallFooter(
            offering: nil,
            customerInfo: nil,
            condensed: condensed,
            fonts: fonts,
<<<<<<< HEAD
            introEligibility: nil, 
            purchaseHandler: purchaseHandler,
=======
            introEligibility: nil,
            purchaseStarted: purchaseStarted,
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c
            purchaseCompleted: purchaseCompleted,
            purchaseCancelled: purchaseCancelled,
            restoreCompleted: restoreCompleted,
            purchaseFailure: purchaseFailure,
            restoreFailure: restoreFailure
        )
    }

    // swiftlint:disable line_length
    /// Presents a ``PaywallFooterView`` at the bottom of a view with the given offering.
    /// ```swift
    /// var body: some View {
    ///    YourPaywall()
    ///      .paywallFooter(offering: offering)
    /// }
    /// ```
    ///
    /// ### Related Articles
    /// [Documentation](https://rev.cat/paywalls)
    @available(iOS, deprecated: 1, renamed: "paywallFooter(offering:condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(tvOS, deprecated: 1, renamed: "paywallFooter(offering:condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(watchOS, deprecated: 1, renamed: "paywallFooter(offering:condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(macOS, deprecated: 1, renamed: "paywallFooter(offering:condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    @available(macCatalyst, deprecated: 1, renamed: "paywallFooter(offering:condensed:fonts:purchaseStarted:purchaseCompleted:purchaseCancelled:restoreStarted:restoreCompleted:purchaseFailure:restoreFailure:)")
    // swiftlint:enable line_length
    public func paywallFooter(
        offering: Offering,
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
        purchaseStarted: @escaping PurchaseStartedHandler,
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseCancelled: PurchaseCancelledHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseFailure: PurchaseFailureHandler? = nil,
        restoreFailure: PurchaseFailureHandler? = nil
    ) -> some View {
        return self.paywallFooter(
            offering: offering,
            customerInfo: nil,
            condensed: condensed,
            fonts: fonts,
            introEligibility: nil,
            purchaseStarted: { _ in
                purchaseStarted()
            },
            purchaseCompleted: purchaseCompleted,
            purchaseCancelled: purchaseCancelled,
            restoreStarted: nil,
            restoreCompleted: restoreCompleted,
            purchaseFailure: purchaseFailure,
            restoreFailure: restoreFailure
        )
    }

    /// Presents a ``PaywallFooterView`` at the bottom of a view with the given offering.
    /// ```swift
    /// var body: some View {
    ///    YourPaywall()
    ///      .paywallFooter(offering: offering)
    /// }
    /// ```
    ///
    /// ### Related Articles
    /// [Documentation](https://rev.cat/paywalls)
    public func paywallFooter(
        offering: Offering,
        offeringSelection: ((Offerings) -> Offering?)? = nil,
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
<<<<<<< HEAD
        purchaseHandler: PurchaseHandler,
=======
        purchaseStarted: PurchaseOfPackageStartedHandler? = nil,
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseCancelled: PurchaseCancelledHandler? = nil,
        restoreStarted: RestoreStartedHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseFailure: PurchaseFailureHandler? = nil,
        restoreFailure: PurchaseFailureHandler? = nil
    ) -> some View {
        return self.paywallFooter(
            offering: offering,
            offeringSelection: offeringSelection,
            customerInfo: nil,
            condensed: condensed,
            fonts: fonts,
            introEligibility: nil,
<<<<<<< HEAD
            purchaseHandler: purchaseHandler,
=======
            purchaseStarted: purchaseStarted,
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c
            purchaseCompleted: purchaseCompleted,
            purchaseCancelled: purchaseCancelled,
            restoreStarted: nil,
            restoreCompleted: restoreCompleted,
            purchaseFailure: purchaseFailure,
            restoreFailure: restoreFailure
        )
    }

    func paywallFooter(
        offering: Offering?,
        offeringSelection: ((Offerings) -> Offering?)? = nil,
        customerInfo: CustomerInfo?,
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
        introEligibility: TrialOrIntroEligibilityChecker? = nil,
<<<<<<< HEAD
        purchaseHandler: PurchaseHandler,
=======
        purchaseHandler: PurchaseHandler? = nil,
        purchaseStarted: PurchaseOfPackageStartedHandler? = nil,
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseCancelled: PurchaseCancelledHandler? = nil,
        restoreStarted: RestoreStartedHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        purchaseFailure: PurchaseFailureHandler? = nil,
        restoreFailure: PurchaseFailureHandler? = nil
    ) -> some View {
        return self
<<<<<<< HEAD
            .modifier(PresentingPaywallFooterModifier(
                offering: offering,
                offeringSelection: offeringSelection,
                customerInfo: customerInfo,
                condensed: condensed,
                purchaseCompleted: purchaseCompleted,
                restoreCompleted: restoreCompleted,
                fontProvider: fonts,
                introEligibility: introEligibility,
                purchaseHandler: purchaseHandler
            ))
=======
            .modifier(
                PresentingPaywallFooterModifier(
                    configuration: .init(
                        content: .optionalOffering(offering),
                        customerInfo: customerInfo,
                        mode: condensed ? .condensedFooter : .footer,
                        fonts: fonts,
                        displayCloseButton: false,
                        introEligibility: introEligibility,
                        purchaseHandler: purchaseHandler
                    ),
                    purchaseStarted: purchaseStarted,
                    purchaseCompleted: purchaseCompleted,
                    purchaseCancelled: purchaseCancelled,
                    purchaseFailure: purchaseFailure,
                    restoreStarted: restoreStarted,
                    restoreCompleted: restoreCompleted,
                    restoreFailure: restoreFailure
                )
            )
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private struct PresentingPaywallFooterModifier: ViewModifier {

<<<<<<< HEAD
    let offering: Offering?
    let offeringSelection: ((Offerings) -> Offering?)?
    let customerInfo: CustomerInfo?
    let condensed: Bool
=======
    let configuration: PaywallViewConfiguration
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c

    let purchaseStarted: PurchaseOfPackageStartedHandler?
    let purchaseCompleted: PurchaseOrRestoreCompletedHandler?
    let purchaseCancelled: PurchaseCancelledHandler?
    let purchaseFailure: PurchaseFailureHandler?

    let restoreStarted: RestoreStartedHandler?
    let restoreCompleted: PurchaseOrRestoreCompletedHandler?
<<<<<<< HEAD
    let fontProvider: PaywallFontProvider
    let introEligibility: TrialOrIntroEligibilityChecker?
    let purchaseHandler: PurchaseHandler
=======
    let restoreFailure: PurchaseFailureHandler?
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
<<<<<<< HEAD
                PaywallView(
                    offering: self.offering,
                    offeringSelection: self.offeringSelection,
                    customerInfo: self.customerInfo,
                    mode: self.condensed ? .condensedFooter : .footer,
                    fonts: self.fontProvider,
                    introEligibility: self.introEligibility,
                    purchaseHandler: self.purchaseHandler
                )
                .onPurchaseCompleted {
                    self.purchaseCompleted?($0)
                }
                .onRestoreCompleted {
                    self.restoreCompleted?($0)
                }
=======
                PaywallView(configuration: self.configuration)
                    .onPurchaseStarted {
                        self.purchaseStarted?($0)
                    }
                    .onPurchaseCompleted {
                        self.purchaseCompleted?($0)
                    }
                    .onPurchaseCancelled {
                        self.purchaseCancelled?()
                    }
                    .onRestoreCompleted {
                        self.restoreCompleted?($0)
                    }
                    .onPurchaseFailure {
                        self.purchaseFailure?($0)
                    }
                    .onRestoreStarted {
                        self.restoreStarted?()
                    }
                    .onRestoreFailure {
                        self.restoreFailure?($0)
                    }
>>>>>>> 9c0d2b825abfea95ccbedd371bcd4605f7bdc48c
        }
    }
}

#endif
