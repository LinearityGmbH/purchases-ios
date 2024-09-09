//
//  File.swift
//  
//
//  Created by Guillaume LAURES on 05/07/2024.
//

import Foundation
import SwiftUI
import RevenueCat

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct LinTemplateNavigationView: TemplateViewType, IntroEligibilityProvider {
    
    let configuration: TemplateViewConfiguration
    
    @Environment(\.userInterfaceIdiom)
    var userInterfaceIdiom
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @EnvironmentObject
    var introEligibilityViewModel: IntroEligibilityViewModel
    var selectedPackage: TemplateViewConfiguration.Package {
        configuration.packages.default
    }
    var showAllPackages: Bool
    @Binding
    var hideCloseButton: Bool
    
    init(_ configuration: TemplateViewConfiguration) {
        self.configuration = configuration
        self.showAllPackages = true
        _hideCloseButton = Binding.constant(true)
    }
    
    init(
        _ configuration: TemplateViewConfiguration,
        showAllPackages: Bool,
        hideCloseButton: Binding<Bool>
    ) {
        self.configuration = configuration
        self.showAllPackages = showAllPackages
        _hideCloseButton = hideCloseButton
    }

    var body: some View {
        NavigationStack {
            LinTemplateStep1View(
                configuration: configuration,
                accentColor: accentColor
            ) {
                LinNavigationLink(
                    configuration: configuration,
                    accentColor: accentColor,
                    label: buttonTitle,
                    destination: LinTemplateStep2View(
                        configuration,
                        showBackButton: true,
                        showAllPackages: showAllPackages
                    )
                        .navigationBarHidden(true)
                        .onAppear(perform: {
                            hideCloseButton = false
                        })
                )
            }.onAppear(perform: {
                hideCloseButton = true
            })
        }
    }
    
    @ViewBuilder
    var buttonTitle: some View {
        PurchaseButtonLabel(
            package: configuration.packages.single,
            colors: configuration.colors,
            introEligibility: introEligibility
        )
    }
    
    var accentColor: Color {
        if let (firstTier, _, _) = configuration.packages.multiTier {
            configuration.colors(for: firstTier).callToActionBackgroundColor
        } else {
            configuration.colors.callToActionBackgroundColor
        }
    }
}

#if DEBUG

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@available(watchOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct LinTemplateNavigation_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(PaywallViewMode.allCases, id: \.self) { mode in
            PreviewableTemplate(
                offering: TestData.offeringWithLinTemplate5Paywall,
                mode: mode
            ) {
                LinTemplateNavigationView(
                    $0,
                    showAllPackages: false,
                    hideCloseButton: Binding.constant(true)
                )
            }
        }
    }
    
}

#endif