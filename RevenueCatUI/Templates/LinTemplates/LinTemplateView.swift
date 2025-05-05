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
struct LinTemplateView: TemplateViewType, IntroEligibilityProvider {
    let configuration: TemplateViewConfiguration
    @Environment(\.userInterfaceIdiom)
    var userInterfaceIdiom
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @EnvironmentObject
    var introEligibilityViewModel: IntroEligibilityViewModel
    @State
    var selectedPackage: TemplateViewConfiguration.Package
    
    init(_ configuration: TemplateViewConfiguration) {
        self._selectedPackage = .init(initialValue: configuration.packages.default)
        self.configuration = configuration
    }
    
    var body: some View {
        LinConfigurableTemplateView(
            configuration, 
            selectedPackage: $selectedPackage,
            titleTypeProvider: { [introEligibilityViewModel] package in
                let isEligibleToIntro = introEligibilityViewModel.allEligibility[package.content] == .eligible
                return .dynamic(
                    isEligibleToIntro: isEligibleToIntro,
                    bundle: LinTemplatesResources.linTemplate5Step2Bundle
                )
            },
            horizontalPaddingModifier: DefaultHorizontalPaddingModifier()
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinConfigurableTemplateView<HorizontalPadding: ViewModifier>: View {

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
    
    private let titleTypeProvider: (TemplateViewConfiguration.Package) -> TitleView.TitleType
    private let horizontalPaddingModifier: HorizontalPadding
    
    init(
        _ configuration: TemplateViewConfiguration,
        selectedPackage: Binding<TemplateViewConfiguration.Package>,
        titleTypeProvider: @escaping (TemplateViewConfiguration.Package) -> TitleView.TitleType,
        horizontalPaddingModifier: HorizontalPadding,
    ) {
        self._selectedPackage = selectedPackage
        self.configuration = configuration
        self.titleTypeProvider = titleTypeProvider
        self.horizontalPaddingModifier = horizontalPaddingModifier
        self._displayingAllPlans = .init(initialValue: configuration.mode.displayAllPlansByDefault)
    }

    var body: some View {
        self.content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    var content: some View {
        VStack(spacing: 8) {
            ScrollView(showsIndicators: false) {
                scrollableContent
                    .padding([.leading, .trailing], -1)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
            }

            subscribeButton
                .frame(maxWidth: Constants.defaultContentWidth)
                .modifier(horizontalPaddingModifier)
            
            FooterView(configuration: self.configuration.configuration,
                       locale: locale,
                       mode: configuration.mode,
                       fonts: configuration.fonts,
                       color: .secondary,
                       purchaseHandler: self.purchaseHandler,
                       displayingAllPlans: self.$displayingAllPlans)
        }
        .foregroundColor(configuration.colors.text1Color)
        .edgesIgnoringSafeArea(.top)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var scrollableContent: some View {
        VStack(spacing: 16) {
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
            }

            Group {
                
                TitleView(
                    type: titleTypeProvider(selectedPackage)
                )
                
                LinPaywallView(
                    configuration: configuration,
                    selectedPackage: $selectedPackage
                )
            }
            .frame(maxWidth: Constants.defaultContentWidth)
            .modifier(horizontalPaddingModifier)
        }
        .frame(maxHeight: .infinity)
    }

    private var subscribeButton: some View {
        PurchaseButton(
            packages: configuration.packages,
            selectedPackage: selectedPackage,
            configuration: configuration
        )
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum LinTemplateConstants {
    static let packageButtonAlignment: Alignment = .leading
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
