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
struct LinTemplate5Step2View: TemplateViewType, IntroEligibilityProvider {
    let configuration: TemplateViewConfiguration
    let showBackButton: Bool
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
    var showAllPackages: Bool
    
    init(_ configuration: TemplateViewConfiguration) {
        self.init(configuration, showBackButton: false, showAllPackages: true)
    }

    init(
        _ configuration: TemplateViewConfiguration,
        showBackButton: Bool,
        showAllPackages: Bool
    ) {
        self._selectedPackage = .init(initialValue: configuration.packages.default)
        self.configuration = configuration
        self.showBackButton = showBackButton
        self.showAllPackages = showAllPackages
    }

    var body: some View {
        SideBySideView {
            paywallContent(displayTimeline: horizontalSizeClass != .regular && isEligibleToIntro)
        } rightView: {
            auxiliaryDetailsView(isEligibleToIntro: isEligibleToIntro)
        }
    }
    
    @ViewBuilder
    private func paywallContent(displayTimeline: Bool) -> some View {
        LinConfigurableTemplate5View(
            configuration, 
            selectedPackage: $selectedPackage,
            displayImage: false,
            titleTypeProvider: { [introEligibilityViewModel] package in
                let isEligibleToIntro = introEligibilityViewModel.allEligibility[package.content] == .eligible
                return .dynamic(
                    isEligibleToIntro: isEligibleToIntro,
                    bundle: LinTemplatesResources.linTemplate5Step2Bundle
                )
            },
            horizontalPaddingModifier: NoPaddingModifier(),
            showBackButton: showBackButton,
            showAllPackages: showAllPackages
        ) {
            if displayTimeline {
                TimelineView(stepConfigurations: TimelineView.defaultIPhone(introductoryOfferDaysDuration: configuration.packages.introductoryOfferDaysDuration), axis: .horizontal)
            }
        } buttonSubtitleBuilder: { selectedPackage, eligibility, locale in
            let msgProvider = CTAFooterMessageProvider(locale: locale)
            IntroEligibilityStateView(
                textWithNoIntroOffer: msgProvider.makeTextWithNoIntroOffer(selectedPackage),
                textWithIntroOffer: msgProvider.makeTextWithIntroOffer(selectedPackage),
                introEligibility: eligibility
            )
        }.font(.system(size: 13))
    }
    
    @ViewBuilder
    private func auxiliaryDetailsView(isEligibleToIntro: Bool) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Spacer()
                if isEligibleToIntro {
                    TimelineView(stepConfigurations: TimelineView.defaultIPad(introductoryOfferDaysDuration: configuration.packages.introductoryOfferDaysDuration), axis: .vertical)
                    Spacer().frame(height: 60)
                }
                TestimonialsView()
                Spacer()
            }
            CompanyLogosView()
            Spacer().frame(height: 18)
        }
        .padding([.leading, .trailing], 40)
        .background(Color(
            light: Color(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0),
            dark: Color(red: 44 / 255.0, green: 44 / 255.0, blue: 46 / 255.0)
        ))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
private func localize(_ key: String, value: String) -> String {
    NSLocalizedString(
        key,
        bundle: LinTemplatesResources.linTemplate5Step2Bundle,
        value: value,
        comment: ""
    )
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(watchOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct LinTemplate5Step2View_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(PaywallViewMode.allCases, id: \.self) { mode in
            PreviewableTemplate(
                offering: TestData.offeringWithLinTemplate5Paywall,
                mode: mode
            ) {
                LinTemplate5Step2View($0, showBackButton: false, showAllPackages: false)
            }
        }
    }

}

#endif
