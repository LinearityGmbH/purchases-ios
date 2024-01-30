//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  LinTemplate5View.swift
//
//  Created by Nacho Soto.

import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinTemplate5View: TemplateViewType {

    let configuration: TemplateViewConfiguration

    @State
    private var selectedPackage: TemplateViewConfiguration.Package

    @State
    private var displayingAllPlans: Bool

    @Environment(\.userInterfaceIdiom)
    var userInterfaceIdiom
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @Environment(\.verticalSizeClass)
    var verticalSizeClass

    @Environment(\.locale)
    var locale

    @EnvironmentObject
    private var introEligibilityViewModel: IntroEligibilityViewModel
    @EnvironmentObject
    private var purchaseHandler: PurchaseHandler

    init(_ configuration: TemplateViewConfiguration) {
        self._selectedPackage = .init(initialValue: configuration.packages.default)
        self.configuration = configuration
        self._displayingAllPlans = .init(initialValue: configuration.mode.displayAllPlansByDefault)
    }

    var body: some View {
        self.content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 8) {
            self.scrollableContent
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .scrollableIfNecessary(enabled: self.configuration.mode.isFullScreen)
            
            
            self.subscribeButton
                .frame(maxWidth: self.defaultContentWidth)
                .defaultHorizontalPadding()
            
            FooterView(configuration: self.configuration,
                       purchaseHandler: self.purchaseHandler,
                       displayingAllPlans: self.$displayingAllPlans)
        }
        .foregroundColor(self.configuration.colors.text1Color)
        .edgesIgnoringSafeArea(.top)
        .animation(Constants.fastAnimation, value: self.selectedPackage)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var scrollableContent: some View {
        VStack(spacing: 16) {
            if self.configuration.mode.isFullScreen {
                if let header = self.configuration.headerImageURL {
                    Spacer()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: verticalSizeClass == .regular ? 200 : nil,
                            maxHeight: .infinity
                        )
                        .background {
                            if verticalSizeClass == .regular {
                                RemoteImage(url: header)
                            }
                        }
                        .clipped()
                        .padding(.bottom, 8)
                }
            }

            Group {
                if self.configuration.mode.isFullScreen {
                    Text(.init(self.selectedLocalization.title))
                        .font(self.font(for: .title2).bold())
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    self.features
                        .padding(.bottom, 8)

                    self.packages
                } else {
                    self.packages
                        .hideFooterContent(self.configuration,
                                           hide: !self.displayingAllPlans)
                }
                
                if self.configuration.mode.shouldDisplayInlineOfferDetails(displayingAllPlans: self.displayingAllPlans) {
                    self.offerDetails(package: self.selectedPackage, selected: false)
                }
            }
            .frame(maxWidth: self.defaultContentWidth)
            .defaultHorizontalPadding()
        }
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var features: some View {
        VStack(spacing: 4) {
            ForEach(self.selectedLocalization.features, id: \.title) { feature in
                HStack {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            if let icon = feature.icon {
                                IconView(icon: icon, tint: self.configuration.colors.featureIcon)
                            }
                        }
                        .frame(width: self.iconSize, height: self.iconSize)

                    Text(.init(feature.title))
                        .font(self.font(for: .subheadline))
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    @ViewBuilder
    private var packages: some View {
        VStack(spacing: 16) {
            ForEach(self.configuration.packages.all, id: \.content.id) { package in
                let isSelected = self.selectedPackage.content === package.content

                Button {
                    self.selectedPackage = package
                } label: {
                    self.packageButton(package, selected: isSelected)
                }
                .buttonStyle(PackageButtonStyle())
            }
        }
    }

    @ViewBuilder
    private func packageButton(_ package: TemplateViewConfiguration.Package, selected: Bool) -> some View {
        packageButtonTitle(package, selected: selected)
            .font(self.font(for: .body).weight(.medium))
            .defaultPadding()
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: Self.packageButtonAlignment)
            .overlay {
                self.roundedRectangle
                    .stroke(
                        selected
                        ? self.configuration.colors.selectedOutline
                        : self.configuration.colors.unselectedOutline,
                        lineWidth: Constants.defaultPackageBorderWidth
                    )
            }
            .overlay(alignment: .topTrailing) {
                self.packageDiscountLabel(package, selected: selected)
                    .padding(8)
            }
    }
    
    @ViewBuilder
    private func packageDiscountLabel(
        _ package: TemplateViewConfiguration.Package,
        selected: Bool
    ) -> some View {
        if let discount = package.discountRelativeToMostExpensivePerMonth {
            let colors = self.configuration.colors

            Text(Localization.localized(discount: discount, locale: self.locale))
                .textCase(.uppercase)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(self.roundedRectangle.foregroundColor(
                    selected
                    ? colors.selectedOutline
                    : colors.unselectedOutline
                ))
                .foregroundColor(
                    selected
                    ? colors.selectedDiscountText
                    : colors.unselectedDiscountText
                )
                .font(self.font(for: .caption))
                .dynamicTypeSize(...Constants.maximumDynamicTypeSize)
        }
    }

    private var roundedRectangle: some Shape {
        RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
    }

    @ViewBuilder
    private func packageButtonTitle(
        _ package: TemplateViewConfiguration.Package,
        selected: Bool
    ) -> some View {
        HStack {
            let image = selected
                ? "checkmark.circle.fill"
                : "circle"
            let color = selected
                ? self.configuration.colors.selectedOutline
                : self.configuration.colors.unselectedOutline
            Image(systemName: image)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(color)

            VStack(alignment: Self.packageButtonAlignment.horizontal, spacing: 5) {
                Text(package.localization.offerName ?? package.content.productName)
                self.offerDetails(package: package, selected: selected)
            }
        }
    }

    private func offerDetails(package: TemplateViewConfiguration.Package, selected: Bool) -> some View {
        IntroEligibilityStateView(
            display: .offerDetails,
            localization: package.localization,
            introEligibility: self.introEligibility[package.content],
            foregroundColor: self.configuration.colors.text1Color,
            alignment: Self.packageButtonAlignment
        )
        .fixedSize(horizontal: false, vertical: true)
        .font(self.font(for: .body))
    }

    private var subscribeButton: some View {
        PurchaseButton(
            packages: self.configuration.packages,
            selectedPackage: self.selectedPackage,
            configuration: self.configuration
        )
    }

    // MARK: -

    private var introEligibility: [Package: IntroEligibilityStatus] {
        return self.introEligibilityViewModel.allEligibility
    }

    @ScaledMetric(relativeTo: .body)
    private var iconSize = 25

    private static let cornerRadius: CGFloat = Constants.defaultPackageCornerRadius
    private static let packageButtonAlignment: Alignment = .leading

    private var headerAspectRatio: CGFloat {
        switch self.userInterfaceIdiom {
        case .pad: return 3
        default: return 2
        }
    }

}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.2, *)
private extension PaywallData.Configuration.Colors {

    var featureIcon: Color { self.accent1Color }
    var selectedOutline: Color { self.accent2Color }
    var unselectedOutline: Color { self.accent3Color }
    var selectedDiscountText: Color { self.text2Color }
    var unselectedDiscountText: Color { self.text3Color }

}

// MARK: - Extensions

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension LinTemplate5View {

    var selectedLocalization: ProcessedLocalizedConfiguration {
        return self.selectedPackage.localization
    }

}

// MARK: -

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(watchOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct LinTemplate5View_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(PaywallViewMode.allCases, id: \.self) { mode in
            PreviewableTemplate(
                offering: TestData.offeringWithLinTemplate5Paywall,
                mode: mode
            ) {
                LinTemplate5View($0)
            }
        }
    }

}

#endif
