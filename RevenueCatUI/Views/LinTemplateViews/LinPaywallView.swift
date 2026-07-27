//
//  LinPaywallView.swift
//  RevenueCat
//
//  Created by Guillaume LAURES on 06/09/2024.
//

import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinPaywallView: View {
    
    let configuration: TemplateViewConfiguration
    
    @Binding
    var selectedPackage: TemplateViewConfiguration.Package
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Environment(\.locale)
    private var locale
    @EnvironmentObject
    private var introEligibilityViewModel: IntroEligibilityViewModel
    
    @ScaledMetric(relativeTo: .body)
    private var iconSize = 25
    
    var body: some View {
        features(package: selectedPackage)
        if horizontalSizeClass == .compact {
            Spacer()
        }
        packages(packages: configuration.packages.all)
    }
    
    @ViewBuilder
    private func features(package: TemplateViewConfiguration.Package) -> some View {
        #if targetEnvironment(macCatalyst)
        let spacing: CGFloat = 6
        #else
        let spacing: CGFloat = 8
        #endif
        
        VStack(spacing: spacing) {
            ForEach(package.localization.features, id: \.title) { feature in
                HStack(alignment: .firstTextBaseline) {
                    if let icon = feature.icon {
                        if icon == .tick {
                            Image(.icCheckmark)
                                .foregroundColor(configuration.colors.featureIcon)
                                .font(.system(size: 15))
                        } else {
                            IconView(icon: icon, tint: configuration.colors.featureIcon)
                                .frame(width: iconSize, height: iconSize)
                        }
                    }
                    
                    Text(.init(feature.title))
                        .font(.system(size: 15))
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding([.bottom], 20)
    }
        
    @ViewBuilder
    private func packages(packages: [TemplateViewConfiguration.Package]) -> some View {
        VStack {
            VStack(spacing: 16) {
                ForEach(packages, id: \.content.id) { package in
                    let isSelected = self.selectedPackage.content === package.content
                    
                    Button {
                        withAnimation(.smooth) {
                            self.selectedPackage = package
                        }
                    } label: {
                        self.packageButton(package, selected: isSelected)
                    }
                    .buttonStyle(PackageButtonStyle())
                }
            }
        }
    }
    
    @ViewBuilder
    private func packageButton(
        _ package: TemplateViewConfiguration.Package,
        selected: Bool
    ) -> some View {
        packageButtonTitle(package, selected: selected)
            .font(configuration.fonts.font(for: .body).weight(.medium))
            .defaultPadding()
            .multilineTextAlignment(.leading)
            .frame(
                maxWidth: .infinity,
                alignment: LinTemplateConstants.packageButtonAlignment
            )
            .background {
                self.roundedRectangle(cornerRadius: 12)
                    .stroke(
                        selected
                        ? configuration.colors.selectedOutline
                        : configuration.colors.unselectedOutline,
                        lineWidth: Constants.defaultPackageBorderWidth
                    ).background {
                        self.roundedRectangle(cornerRadius: 12).fill(
                            selected
                            ? Color(
                                red: 0xFF / 255.0,
                                green: 0x96 / 255.0,
                                blue: 0x14 / 255.0,
                                opacity: 0x0D / 255.0
                            )
                            : .clear
                        )
                    }
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
            let colors = configuration.colors
            
            Text(Localization.localized(discount: discount, locale: self.locale))
                .textCase(.uppercase)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(self.roundedRectangle(cornerRadius: 6).foregroundColor(
                    selected
                    ? colors.selectedOutline
                    : colors.unselectedOutline
                ))
                .foregroundColor(
                    selected
                    ? colors.selectedDiscountText
                    : colors.unselectedDiscountText
                )
                .font(configuration.fonts.font(for: .caption))
                .dynamicTypeSize(...Constants.maximumDynamicTypeSize)
        }
    }
    
    private func roundedRectangle(cornerRadius: CGFloat) -> some Shape {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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
            ? configuration.colors.selectedOutline
            : configuration.colors.unselectedOutline
            Image(systemName: image)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(color)
            
            VStack(
                alignment: LinTemplateConstants.packageButtonAlignment.horizontal, spacing: 5
            ) {
                Text(package.localization.offerName ?? package.content.productName)
                    .font(.system(size: 17, weight: .semibold))
                offerDetails(package: package, selected: selected)
            }
        }
    }
    
    private func offerDetails(
        package: TemplateViewConfiguration.Package,
        selected: Bool
    ) -> some View {
        IntroEligibilityStateView(
            display: .offerDetails,
            localization: package.localization,
            introEligibility: introEligibilityViewModel.allEligibility[package.content],
            foregroundColor: configuration.colors.text1Color,
            alignment: LinTemplateConstants.packageButtonAlignment
        )
        .fixedSize(horizontal: false, vertical: true)
        .font(configuration.fonts.font(for: .body))
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.2, *)
private extension PaywallData.Configuration.Colors {
    
    var featureIcon: Color { self.accent1Color }
    var selectedOutline: Color { self.accent2Color }
    var unselectedOutline: Color { self.accent3Color }
    var selectedDiscountText: Color { self.text2Color }
    var unselectedDiscountText: Color { self.text3Color }
    var selectedTier: Color { self.accent1Color }
    var callToAction: Color { self.selectedTier }
    
    var tierControlBackground: Color { self.tierControlBackgroundColor ?? self.accent1Color }
    var tierControlForeground: Color { self.tierControlForegroundColor ?? self.text1Color }
    var tierControlSelectedBackground: Color { self.tierControlSelectedBackgroundColor ?? self.unselectedDiscountText }
    var tierControlSelectedForeground: Color { self.tierControlSelectedForegroundColor ?? self.text1Color }
}
