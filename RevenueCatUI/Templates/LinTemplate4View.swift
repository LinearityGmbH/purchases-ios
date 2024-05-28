//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 14/5/2024.
//

import Foundation
import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinTemplate4View: TemplateViewType {
    static var bundle = Foundation.Bundle.module
    let configuration: TemplateViewConfiguration
    @Environment(\.userInterfaceIdiom)
    var userInterfaceIdiom
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @EnvironmentObject
    private var introEligibilityViewModel: IntroEligibilityViewModel
    @State
    private var selectedPackage: TemplateViewConfiguration.Package

    init(_ configuration: TemplateViewConfiguration) {
        self._selectedPackage = .init(initialValue: configuration.packages.default)
        self.configuration = configuration
    }
    
    @ViewBuilder
    private func paywallContent(displayTimeline: Bool) -> some View {
        LinConfigurableTemplate5View(
            configuration, 
            selectedPackage: $selectedPackage,
            displayImage: false,
            titleProvider: { [introEligibilityViewModel] package in
                let eligible = introEligibilityViewModel.allEligibility[package.content] == .eligible
                return eligible
                ? localize("Title.EligibleOffering", value: "Try Linearity Pro for free")
                : localize("Title.NonEligibleOffering", value: "Upgrade to Linearity Pro")
            },
            getDefaultContentWidth: Constants.defaultContentWidth
        ) {
            if displayTimeline {
                TimelineView(stepConfigurations: TimelineView.defaultIPhone, axis: .horizontal)
            }
        } buttonSubtitleBuilder: { selectedPackage, eligibility, locale in
            let msgProvider = CTAFooterMessageProvider(locale: locale)
            IntroEligibilityStateView(
                textWithNoIntroOffer: msgProvider.makeTextWithNoIntroOffer(selectedPackage),
                textWithIntroOffer: msgProvider.makeTextWithIntroOffer(selectedPackage),
                introEligibility: eligibility
            )
        }
    }
    
    var body: some View {
        switch horizontalSizeClass {
        case .regular:
            HStack(spacing: 0) {
                paywallContent(displayTimeline: false)
                AuxiliaryDetailsView(eligible: eligible)
            }
        default:
            paywallContent(displayTimeline: eligible)
        }
    }
    
    var eligible: Bool {
        introEligibilityViewModel.allEligibility[selectedPackage.content] == .eligible
    }
    
    private struct AuxiliaryDetailsView: View {
        let eligible: Bool
        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Spacer()
                    if eligible {
                        TimelineView(stepConfigurations: TimelineView.defaultIPad, axis: .vertical)
                        Spacer().frame(height: 60)
                    }
                    TestimonialsView()
                    Spacer()
                }
                CompanyLogosView()
                Spacer().frame(height: 12)
            }
            .padding([.leading, .trailing], 40)
            .background(Color(
                light: Color(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0),
                dark: Color(red: 44 / 255.0, green: 44 / 255.0, blue: 46 / 255.0)
            ))
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
private func localize(_ key: String, value: String) -> String {
    NSLocalizedString(
        key,
        bundle: LinTemplate4View.bundle,
        value: value,
        comment: ""
    )
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(watchOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct LinTemplate4View_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(PaywallViewMode.allCases, id: \.self) { mode in
            PreviewableTemplate(
                offering: TestData.offeringWithLinTemplate5Paywall,
                mode: mode
            ) {
                LinTemplate4View($0)
            }
        }
    }

}

#endif
