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
    @Environment(\.userInterfaceIdiom)
    var userInterfaceIdiom
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    private let showBackButton: Bool
    @State
    private var selectedPackage: TemplateViewConfiguration.Package

    init(_ configuration: TemplateViewConfiguration) {
        self.init(configuration, showBackButton: false)
    }
    
    init(
        _ configuration: TemplateViewConfiguration,
        showBackButton: Bool
    ) {
        self.showBackButton = showBackButton
        self._selectedPackage = .init(initialValue: configuration.packages.default)
        self.configuration = configuration
    }
    
    var body: some View {
        LinConfigurableTemplate5View(
            configuration, 
            selectedPackage: $selectedPackage,
            displayImage: true,
            titleTypeProvider: { package in .fixed(package.localization.title) },
            horizontalPaddingModifier: DefaultHorizontalPaddingModifier(),
            showBackButton: showBackButton,
            showAllPackages: true,
            subtitleBuilder: { EmptyView() },
            buttonSubtitleBuilder: { (_, _ , _) in EmptyView() }
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinConfigurableTemplate5View<SubtitleView: View, ButtonSubtitleView: View, HorizontalPadding: ViewModifier>: View {
    typealias SubtitleBuilder = () -> SubtitleView
    typealias ButtonSubtitleBuilder = (
            _ selectedPackage: Package,
            _ eligibility: IntroEligibilityStatus?,
            _ locale: Locale
        ) -> ButtonSubtitleView

    let configuration: TemplateViewConfiguration

    @Binding
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
    @Environment(\.dismiss)
    private var dismiss
    
    private let displayImage: Bool
    private let buttonSubtitleBuilder: ButtonSubtitleBuilder
    private let subtitleBuilder: SubtitleBuilder
    private let titleTypeProvider: (TemplateViewConfiguration.Package) -> TitleView.TitleType
    private let horizontalPaddingModifier: HorizontalPadding
    private let showBackButton: Bool
    @State
    private var showAllPackages: Bool

    init(
        _ configuration: TemplateViewConfiguration,
        selectedPackage: Binding<TemplateViewConfiguration.Package>,
        displayImage: Bool,
        titleTypeProvider: @escaping (TemplateViewConfiguration.Package) -> TitleView.TitleType,
        horizontalPaddingModifier: HorizontalPadding,
        showBackButton: Bool = false,
        showAllPackages: Bool = true,
        @ViewBuilder subtitleBuilder: @escaping SubtitleBuilder,
        @ViewBuilder buttonSubtitleBuilder: @escaping ButtonSubtitleBuilder
    ) {
        self._selectedPackage = selectedPackage
        self.configuration = configuration
        self.displayImage = displayImage
        self.subtitleBuilder = subtitleBuilder
        self.buttonSubtitleBuilder = buttonSubtitleBuilder
        self.titleTypeProvider = titleTypeProvider
        self.horizontalPaddingModifier = horizontalPaddingModifier
        self.showBackButton = showBackButton
        self._showAllPackages = .init(initialValue: showAllPackages)
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
                .scrollableIfNecessaryWhenAvailable(enabled: self.configuration.mode.isFullScreen)

            self.subscribeButton
                .frame(maxWidth: Constants.defaultContentWidth)
                .modifier(horizontalPaddingModifier)
            
            buttonSubtitleBuilder(
                selectedPackage.content,
                introEligibility[self.selectedPackage.content],
                locale
            )
            
            FooterView(configuration: self.configuration.configuration,
                       mode: configuration.mode,
                       fonts: configuration.fonts,
                       color: .secondary,
                       purchaseHandler: self.purchaseHandler,
                       displayingAllPlans: self.$displayingAllPlans)
        }
        .foregroundColor(self.configuration.colors.text1Color)
        .edgesIgnoringSafeArea(.top, apply: self.displayImage)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var scrollableContent: some View {
        VStack(spacing: 16) {
            if self.configuration.mode.isFullScreen {
                if let header = self.configuration.headerImageURL, self.displayImage {
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
                }
            }

            Group {
                if self.configuration.mode.isFullScreen {
                    HStack {
                        if showBackButton {
                            Button(action: {
                                dismiss()
                            }, label: {
                                Image(systemName: "chevron.backward")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                    #if targetEnvironment(macCatalyst)
                                    .padding([.trailing], 4)
                                    .contentShape(Rectangle())
                                    #endif
                            })
                            #if targetEnvironment(macCatalyst)
                            .buttonStyle(.plain)
                            #endif
                        }
                        TitleView(type: titleTypeProvider(selectedPackage))
                    }
                    
                    self.subtitleBuilder()

                    self.features
                        .padding([.bottom], 20)
                    if horizontalSizeClass == .compact {
                        Spacer()
                    }
                    self.packages
                    if horizontalSizeClass == .regular && !self.displayImage {
                        Spacer(minLength: 20)
                    }
                } else {
                    self.packages
                        .hideFooterContent(self.configuration,
                                           hide: !self.displayingAllPlans)
                }
                
                if !showAllPackages {
                    Button {
                        withAnimation(Constants.toggleAllPlansAnimation) {
                            showAllPackages = true
                        }
                    } label: {
                        Text(localize("Template5.see_all_plans", value: "See All Plans"))
                            .foregroundStyle(
                                Color(
                                    uiColor: UIColor(red: 1.0, green: 150.0 / 255, blue: 20.0 / 255, alpha: 1)
                                )
                            )
                            .font(self.font(for: .callout).weight(.medium))
                    }
                    #if targetEnvironment(macCatalyst)
                    .buttonStyle(.plain)
                    #endif
                }
                
                if self.configuration.mode.shouldDisplayInlineOfferDetails(displayingAllPlans: self.displayingAllPlans) {
                    self.offerDetails(package: self.selectedPackage, selected: false)
                }
            }
            .frame(maxWidth: Constants.defaultContentWidth)
            .modifier(horizontalPaddingModifier)
        }
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var features: some View {
        #if targetEnvironment(macCatalyst)
        let spacing: CGFloat = 6
        #else
        let spacing: CGFloat = 8
        #endif

        VStack(spacing: spacing) {
            ForEach(self.selectedLocalization.features, id: \.title) { feature in
                HStack(alignment: .firstTextBaseline) {
                    if let icon = feature.icon {
                        if icon == .tick {
                            Image(.icCheckmark)
                                .foregroundColor(self.configuration.colors.featureIcon)
                                .font(.system(size: 15))
                        } else {
                            IconView(icon: icon, tint: self.configuration.colors.featureIcon)
                                .frame(width: self.iconSize, height: self.iconSize)
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
    }

    @ViewBuilder
    private var packages: some View {
        let packages = showAllPackages
        ? self.configuration.packages.all
        : Array(self.configuration.packages.all.prefix(upTo: 1))

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

    @ViewBuilder
    private func packageButton(_ package: TemplateViewConfiguration.Package, selected: Bool) -> some View {
        packageButtonTitle(package, selected: selected)
            .font(self.font(for: .body).weight(.medium))
            .defaultPadding()
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: Template5Constants.packageButtonAlignment)
            .background {
                self.roundedRectangle(cornerRadius: 12)
                    .stroke(
                        selected
                        ? self.configuration.colors.selectedOutline
                        : self.configuration.colors.unselectedOutline,
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
            let colors = self.configuration.colors

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
                .font(self.font(for: .caption))
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
                ? self.configuration.colors.selectedOutline
                : self.configuration.colors.unselectedOutline
            Image(systemName: image)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(color)

            VStack(alignment: Template5Constants.packageButtonAlignment.horizontal, spacing: 5) {
                Text(package.localization.offerName ?? package.content.productName)
                    .font(.system(size: 17, weight: .semibold))
                self.offerDetails(package: package, selected: selected)
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
            introEligibility: self.introEligibility[package.content],
            foregroundColor: self.configuration.colors.text1Color,
            alignment: Template5Constants.packageButtonAlignment
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


    private var headerAspectRatio: CGFloat {
        switch self.userInterfaceIdiom {
        case .pad: return 3
        default: return 2
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum Template5Constants {
    static let packageButtonAlignment: Alignment = .leading
    static let cornerRadius: CGFloat = Constants.defaultPackageCornerRadius
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.2, *)
private extension PaywallData.Configuration.Colors {

    var featureIcon: Color { self.accent1Color }
    var selectedOutline: Color { self.accent2Color }
    var unselectedOutline: Color { self.accent3Color }
    var selectedDiscountText: Color { self.text2Color }
    var unselectedDiscountText: Color { self.text3Color }

}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.2, *)
struct IgnoreSafeAreaConditionally: ViewModifier {
    
    let edges: Edge.Set
    let ignoreSafeArea: Bool
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if ignoreSafeArea {
            content
                .edgesIgnoringSafeArea(edges)
        } else {
            content
        }
    }
}

// MARK: - Extensions

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension LinConfigurableTemplate5View {

    var selectedLocalization: ProcessedLocalizedConfiguration {
        return self.selectedPackage.localization
    }
    
    func font(for textStyle: Font.TextStyle) -> Font {
        return self.configuration.fonts.font(for: textStyle)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension View {
    func edgesIgnoringSafeArea(_ edges: Edge.Set, apply: Bool) -> some View {
        modifier(IgnoreSafeAreaConditionally(edges: edges, ignoreSafeArea: apply))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
private func localize(_ key: String, value: String) -> String {
    NSLocalizedString(
        key,
        bundle: LinTemplatesResources.linTemplate5Bundle,
        value: value,
        comment: ""
    )
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
