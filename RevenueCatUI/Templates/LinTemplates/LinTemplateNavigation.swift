//
//  File.swift
//  
//
//  Created by Guillaume LAURES on 05/07/2024.
//

import Foundation
import SwiftUI
import RevenueCat

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinTemplateNavigation: TemplateViewType, IntroEligibilityProvider {
    
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
    
    init(_ configuration: TemplateViewConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        NavigationView {
            LinTemplate5Step1View(configuration) {
                LinNavigationLink(
                    configuration: configuration,
                    label: buttonTitle,
                    destination: LinTemplate5Step2View(configuration, showBackButton: true)
                        .navigationBarHidden(true)
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    var buttonTitle: some View {
        PurchaseButtonLabel(
            package: configuration.packages.single,
            colors: configuration.colors,
            introEligibility: introEligibility
        )
    }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
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
                LinTemplateNavigation($0)
            }
        }
    }
    
}

#endif
