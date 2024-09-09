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
struct LinTemplateStep2View: TemplateViewType, IntroEligibilityProvider {
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
    @State
    var selectedTier: PaywallData.Tier?
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
        if let (firstTier, _, _) = configuration.packages.multiTier {
            self.selectedTier = firstTier
        } else {
            self.selectedTier = nil
        }
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
        LinConfigurableTemplateView(
            configuration, 
            selectedPackage: $selectedPackage,
            selectedTier: $selectedTier,
            displayImage: false,
            titleTypeProvider: { [introEligibilityViewModel] package in
                let isEligibleToIntro = introEligibilityViewModel.allEligibility[package.content] == .eligible
                return .dynamic(
                    isEligibleToIntro: isEligibleToIntro,
                    bundle: LinTemplatesResources.linTemplate5Step2Bundle,
                    ineligibleFallback: selectedPackage.localization.title
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
struct LinTemplateStep2View_Previews: PreviewProvider {
    
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
                LinTemplateStep2View($0, showBackButton: false, showAllPackages: false)
            }
        }
    }
}

#endif
