//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PaywallFooterViewController.swift
//
//  Created by Antonio Rico Diez on 4/12/23.
//

#if canImport(UIKit) && !os(tvOS) && !os(watchOS)

import RevenueCat
import UIKit

/// A view controller for displaying `PaywallData` for an `Offering` in a footer format.
/// This is used by the RevenueCat hybrid SDKs in order to get a View of the footer.
///
/// Consumers should normally use ``PaywallViewController`` instead.
///
/// - Seealso: ``PaywallView`` for `SwiftUI`.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
@objc(RCPaywallFooterViewController)
public final class PaywallFooterViewController: PaywallViewController {

    /// Initialize a `PaywallFooterViewController` with an optional `Offering`.
    /// - Parameter offering: The `Offering` containing the desired `PaywallData` to display.
    /// `Offerings.current` will be used by default.
    @objc
    public init(
        offering: Offering? = nil,
        dismissRequestedHandler: ((_ controller: PaywallViewController) -> Void)? = nil
    ) {
        super.init(content: .optionalOffering(offering),
                   fonts: DefaultPaywallFontProvider(),
                   displayCloseButton: false,
                   shouldBlockTouchEvents: false,
                   performPurchase: nil,
                   performRestore: nil,
                   dismissRequestedHandler: dismissRequestedHandler)
    }

    /// Initialize a `PaywallFooterViewController` with an `Offering` identifier.
    @objc
    public init(
        offeringIdentifier: String,
        dismissRequestedHandler: ((_ controller: PaywallViewController) -> Void)? = nil
    ) {
        super.init(content: .offeringIdentifier(offeringIdentifier),
                   fonts: DefaultPaywallFontProvider(),
                   displayCloseButton: false,
                   shouldBlockTouchEvents: false,
                   performPurchase: nil,
                   performRestore: nil,
                   dismissRequestedHandler: dismissRequestedHandler)
    }

    /// Initialize a `PaywallFooterViewController` with an `offeringIdentifier` and custom `fontName`.
    /// - Parameter fontName: a custom font name for this paywall. See ``CustomPaywallFontProvider``.
    @objc
    public init(
        offeringIdentifier: String,
        fontName: String,
        dismissRequestedHandler: ((_ controller: PaywallViewController) -> Void)? = nil
    ) {
        super.init(content: .offeringIdentifier(offeringIdentifier),
                   fonts: CustomPaywallFontProvider(fontName: fontName),
                   displayCloseButton: false,
                   shouldBlockTouchEvents: false,
                   performPurchase: nil,
                   performRestore: nil,
                   dismissRequestedHandler: dismissRequestedHandler)
    }

    @available(*, unavailable)
    override init(
        content: PaywallViewConfiguration.Content,
        fonts: PaywallFontProvider,
        displayCloseButton: Bool,
        shouldBlockTouchEvents: Bool,
        performPurchase: PerformPurchase?,
        performRestore: PerformRestore?,
        dismissRequestedHandler: ((_ controller: PaywallViewController) -> Void)?
    ) {
        super.init(content: content,
                   fonts: fonts,
                   displayCloseButton: false,
                   shouldBlockTouchEvents: false,
                   performPurchase: performPurchase,
                   performRestore: performRestore,
                   dismissRequestedHandler: dismissRequestedHandler)
    }

    // swiftlint:disable:next missing_docs
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var mode: PaywallViewMode {
        return .footer
    }

}

#endif
