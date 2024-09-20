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
struct LinTemplateView: TemplateViewType {
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
    @State
    private var selectedTier: PaywallData.Tier?

    init(_ configuration: TemplateViewConfiguration) {
        self.init(configuration, showBackButton: false)
    }
    
    init(
        _ configuration: TemplateViewConfiguration,
        showBackButton: Bool
    ) {
        self.showBackButton = showBackButton
        self._selectedPackage = .init(initialValue: configuration.packages.default)
        if let (firstTier, _, _) = configuration.packages.multiTier {
            self.selectedTier = firstTier
        } else {
            self.selectedTier = nil
        }
        self.configuration = configuration
    }
    
    var body: some View {
        LinConfigurableTemplateView(
            configuration, 
            selectedPackage: $selectedPackage,
            selectedTier: $selectedTier,
            displayImage: true,
            titleTypeProvider: { package in .fixed(package.localization.title) },
            horizontalPaddingModifier: DefaultHorizontalPaddingModifier(),
            showBackButton: showBackButton,
            showAllPackages: true,
            subtitleView: { EmptyView() },
            subscribeButtonSubtitleView: { (_, _ , _) in EmptyView() }
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinConfigurableTemplateView<SubtitleView: View, SubscribeButtonSubtitleView: View, HorizontalPadding: ViewModifier>: View {
    typealias SubtitleBuilder = () -> SubtitleView
    typealias ButtonSubtitleBuilder = (
            _ selectedPackage: Package,
            _ eligibility: IntroEligibilityStatus?,
            _ locale: Locale
        ) -> SubscribeButtonSubtitleView

    let configuration: TemplateViewConfiguration

    @Binding
    private var selectedPackage: TemplateViewConfiguration.Package
    @Binding
    private var selectedTier: PaywallData.Tier?

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
    private let subscribeButtonSubtitleView: ButtonSubtitleBuilder
    private let subtitleView: SubtitleBuilder
    private let titleTypeProvider: (TemplateViewConfiguration.Package) -> TitleView.TitleType
    private let horizontalPaddingModifier: HorizontalPadding
    private let showBackButton: Bool
    @State
    private var showAllPackages: Bool
    
    private let currentColors: LinColorsProvider

    init(
        _ configuration: TemplateViewConfiguration,
        selectedPackage: Binding<TemplateViewConfiguration.Package>,
        selectedTier: Binding<PaywallData.Tier?>,
        displayImage: Bool,
        titleTypeProvider: @escaping (TemplateViewConfiguration.Package) -> TitleView.TitleType,
        horizontalPaddingModifier: HorizontalPadding,
        showBackButton: Bool = false,
        showAllPackages: Bool = true,
        @ViewBuilder subtitleView: @escaping SubtitleBuilder,
        @ViewBuilder subscribeButtonSubtitleView: @escaping ButtonSubtitleBuilder
    ) {
        self._selectedPackage = selectedPackage
        self._selectedTier = selectedTier
        self.configuration = configuration
        self.displayImage = displayImage
        self.subtitleView = subtitleView
        self.subscribeButtonSubtitleView = subscribeButtonSubtitleView
        self.titleTypeProvider = titleTypeProvider
        self.horizontalPaddingModifier = horizontalPaddingModifier
        self.showBackButton = showBackButton
        self._showAllPackages = .init(initialValue: showAllPackages)
        self._displayingAllPlans = .init(initialValue: configuration.mode.displayAllPlansByDefault)
        self.currentColors = LinColorsProvider(
            configuration: configuration,
            tier: selectedTier.wrappedValue
        )
    }

    var body: some View {
        self.content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 8) {
            ScrollView {
                scrollableContent
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
            }
            .modifier(HideScrollIndicatorModifier())
            

            subscribeButton
                .frame(maxWidth: Constants.defaultContentWidth)
                .modifier(horizontalPaddingModifier)
            
            subscribeButtonSubtitleView(
                selectedPackage.content,
                introEligibility[self.selectedPackage.content],
                locale
            )
            
            FooterView(configuration: self.configuration.configuration,
                       locale: locale,
                       mode: configuration.mode,
                       fonts: configuration.fonts,
                       color: .secondary,
                       purchaseHandler: self.purchaseHandler,
                       displayingAllPlans: self.$displayingAllPlans)
        }
        .foregroundColor(currentColors.text1Color)
        .edgesIgnoringSafeArea(.top, apply: self.displayImage)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var scrollableContent: some View {
        VStack(spacing: 16) {
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

            Group {
                
                LinTitleView(
                    configuration: configuration,
                    showBackButton: showBackButton,
                    selectedPackage: selectedPackage,
                    titleTypeProvider: titleTypeProvider
                )
                
                LinPaywallView(
                    configuration: configuration,
                    currentColors: currentColors,
                    displayImage: displayImage,
                    showAllPackages: showAllPackages,
                    selectedPackage: $selectedPackage,
                    selectedTier: $selectedTier,
                    subtitleView: subtitleView
                )
                
                showAllPackagesButton
            }
            .frame(maxWidth: Constants.defaultContentWidth)
            .modifier(horizontalPaddingModifier)
        }
        .frame(maxHeight: .infinity)
    }

    private var subscribeButton: some View {
        if let selectedTier {
            PurchaseButton(
                packages: configuration.packages,
                selectedPackage: selectedPackage,
                configuration: configuration,
                selectedTier: selectedTier
            )
        } else {
            PurchaseButton(
                packages: configuration.packages,
                selectedPackage: selectedPackage,
                configuration: configuration
            )
        }
        
    }
    
    @ViewBuilder
    private var showAllPackagesButton: some View {
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
    }

    // MARK: -

    private var introEligibility: [Package: IntroEligibilityStatus] {
        return self.introEligibilityViewModel.allEligibility
    }

    private var headerAspectRatio: CGFloat {
        switch self.userInterfaceIdiom {
        case .pad: return 3
        default: return 2
        }
    }
}

struct HideScrollIndicatorModifier: ViewModifier {
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macCatalyst 16.6, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            content.scrollIndicators(.hidden)
        } else {
            content
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum LinTemplateConstants {
    static let packageButtonAlignment: Alignment = .leading
    static let cornerRadius: CGFloat = Constants.defaultPackageCornerRadius
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
private extension LinConfigurableTemplateView {
    
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
struct LinTemplateView_Previews: PreviewProvider {
    
    static let previewsData: [(id: Int, data: Offering, mode: PaywallViewMode)] = [
        (id: 1, data: TestData.offeringWithLinTemplate5Paywall, mode: .fullScreen),
        (id: 2, data: TestData.offeringWithLinTemplate7Paywall, mode: .fullScreen)
    ]

    static var previews: some View {
        ForEach(previewsData, id:\.id) { (_, data, mode) in
            PreviewableTemplate(
                offering: data,
                mode: mode
            ) {
                LinTemplateView($0)
            }
        }
    }
}

#endif
