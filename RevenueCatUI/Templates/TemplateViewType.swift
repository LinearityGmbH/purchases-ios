//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  TemplateViewType.swift
//
//  Created by Nacho Soto.

import RevenueCat
import SwiftUI

/*
 This file is the entry point to all templates.
 
 For future developers implementing new templates, here are a few recommended principles to follow:
 - Avoid magic numbers as much as possible. Use `@ScaledMetric` if necessary.
 - Prefer reusable views over custom implementations:
    - `FooterView`
    - `PurchaseButton`
    - `RemoteImage`
    - `IntroEligibilityStateView`
    - `IconView`
 - Consider everything beyond the "basic"s:
    - iPad
    - VoiceOver / A11y
    - Dynamic Type
    - All `PaywallViewMode`s
 - Fonts: use `PaywallFontProvider` to derive fonts
 - Colors: avoid hardcoded colors
*/

/// A `SwiftUI` view that can display a paywall with `TemplateViewConfiguration`.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
protocol TemplateViewType: SwiftUI.View {

    var configuration: TemplateViewConfiguration { get }
    var userInterfaceIdiom: UserInterfaceIdiom { get }

    /// `UserInterfaceSizeClass` is only available for macOS/watchOS/tvOS with Xcode 15
    #if swift(>=5.9) || (!os(macOS) && !os(watchOS) && !os(tvOS))
    var verticalSizeClass: UserInterfaceSizeClass? { get }
    #endif

    init(_ configuration: TemplateViewConfiguration)

}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension TemplateViewType {

    func font(for textStyle: Font.TextStyle) -> Font {
        return self.configuration.fonts.font(for: textStyle)
    }

}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension PaywallData {

    @ViewBuilder
    func createView(for offering: Offering,
                    template: PaywallTemplate,
                    configuration: Result<TemplateViewConfiguration, Error>,
                    introEligibility: IntroEligibilityViewModel,
                    hideCloseButton: Binding<Bool>) -> some View {
        switch configuration {
        case let .success(configuration):
            Self.createView(offering: offering, template: template, configuration: configuration, hideCloseButton: hideCloseButton)
                .adaptTemplateView(with: configuration)
                .task(id: offering) {
                    await introEligibility.computeEligibility(for: configuration.packages)
                }

        case let .failure(error):
            DebugErrorView(error, releaseBehavior: .emptyView)
        }
    }

    // swiftlint:disable:next function_parameter_count
    func configuration(
        for offering: Offering,
        activelySubscribedProductIdentifiers: Set<String>,
        template: PaywallTemplate,
        mode: PaywallViewMode,
        fonts: PaywallFontProvider,
        locale: Locale,
        showZeroDecimalPlacePrices: Bool
    ) -> Result<TemplateViewConfiguration, Error> {
        return Result {
            TemplateViewConfiguration(
                mode: mode,
                packages: try .create(with: offering.availablePackages,
                                      activelySubscribedProductIdentifiers: activelySubscribedProductIdentifiers,
                                      filter: self.config.packages,
                                      default: self.config.defaultPackage,
                                      localization: self.localizedConfiguration,
                                      localizationByTier: self.localizedConfigurationByTier,
                                      tiers: self.config.tiers,
                                      setting: template.packageSetting,
                                      locale: locale,
                                      showZeroDecimalPlacePrices: showZeroDecimalPlacePrices),
                configuration: self.config,
                colors: self.config.colors.multiScheme,
                colorsByTier: self.config.multiSchemeColorsByTier,
                fonts: fonts,
                assetBaseURL: self.assetBaseURL,
                showZeroDecimalPlacePrices: showZeroDecimalPlacePrices
            )
        }
    }
    
    enum LinPaywall: Int {
        case defaultRC
        case canvaStyleOneStep
        case canvaStyleTwoSteps
        case canvaStyleOneStepMonthlyHidden
        case canvaStyleTwoStepsMonthlyHidden
        case canvaStyleTwoStepsMonthlyHiddenCloseHiddenOnFirstStep
    }

    @ViewBuilder
    private static func createView(
        offering: Offering,
        template: PaywallTemplate,
        configuration: TemplateViewConfiguration,
        hideCloseButton: Binding<Bool>
    ) -> some View {
        #if os(watchOS)
        WatchTemplateView(configuration)
        #else
        switch template {
        case .template1:
            Template1View(configuration)
        case .template2:
            Template2View(configuration)
        case .template3:
            Template3View(configuration)
        case .template4:
            Template4View(configuration)
        case .template5:
            // In case the offering was not updated yet, keep reading the previous selection value.
            let oldSelectionFallback: LinPaywall = offering.getMetadataValue(for: "show_new_paywall", default: false) ? .canvaStyleOneStep : .defaultRC
            let paywallVersion = LinPaywall(rawValue: offering.getMetadataValue(for: "paywall_version", default: oldSelectionFallback.rawValue)) ?? oldSelectionFallback
            switch paywallVersion {
            case .defaultRC:
                LinTemplate5View(configuration)
            case .canvaStyleOneStep:
                LinTemplate5Step2View(configuration)
            case .canvaStyleTwoSteps:
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                    LinTemplateNavigationView(configuration)
                } else {
                    LinTemplate5Step2View(configuration)
                }
            case .canvaStyleOneStepMonthlyHidden:
                LinTemplate5Step2View(configuration, showBackButton: false, showAllPackages: false)
            case .canvaStyleTwoStepsMonthlyHidden:
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                    LinTemplateNavigationView(configuration, showAllPackages: false, hideCloseButton: Binding.constant(true))
                } else {
                    LinTemplate5Step2View(configuration, showBackButton: false, showAllPackages: false)
                }
            case .canvaStyleTwoStepsMonthlyHiddenCloseHiddenOnFirstStep:
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                    LinTemplateNavigationView(configuration, showAllPackages: false, hideCloseButton: hideCloseButton)
                } else {
                    LinTemplate5Step2View(configuration, showBackButton: false, showAllPackages: false)
                }
            }
        case .template7:
            Template7View(configuration)
        }
        #endif
    }

}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension View {

    func adaptTemplateView(with configuration: TemplateViewConfiguration) -> some View {
        self
            .background(configuration.backgroundView)
            .adjustColorScheme(with: configuration)
            .adjustSize(with: configuration.mode)
    }

    @ViewBuilder
    private func adjustColorScheme(with configuration: TemplateViewConfiguration) -> some View {
        if configuration.hasDarkMode {
            self
        } else {
            // If paywall has no dark mode configured, prevent materials
            // and other SwiftUI elements from automatically taking a dark appearance.
            self.environment(\.colorScheme, .light)
        }
    }

    @ViewBuilder
    private func adjustSize(with mode: PaywallViewMode) -> some View {
        switch mode {
        case .fullScreen:
            self

        case .footer, .condensedFooter:
            self
                .fixedSize(horizontal: false, vertical: true)
                .edgesIgnoringSafeArea(.bottom)
        }
    }

}

// MARK: - Private

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension TemplateViewConfiguration {

    @ViewBuilder
    var backgroundView: some View {
        switch self.mode {
        case .fullScreen:
            self.backgroundContent

        #if !os(watchOS)
        case .footer, .condensedFooter:
            self.backgroundContent
            #if canImport(UIKit)
                .roundedCorner(
                    Constants.defaultCornerRadius,
                    corners: [.topLeft, .topRight],
                    edgesIgnoringSafeArea: .all
                )
            #endif
        #endif
        }
    }

    @ViewBuilder
    var backgroundContent: some View {
        let view = Rectangle()
            .edgesIgnoringSafeArea(.all)

        if self.configuration.blurredBackgroundImage {
            #if os(watchOS)
                #if swift(>=5.9)
                if #available(watchOS 10.0, *) {
                    view.foregroundStyle(.thinMaterial)
                } else {
                    // Blur is done by `TemplateBackgroundImageView`
                    view
                }
                #else
                view
                #endif
            #else
            // Blur background if there is a background image.
            view.foregroundStyle(.thinMaterial)
            #endif
        } else {
            view.foregroundStyle(self.colors.backgroundColor)
        }
    }

}
