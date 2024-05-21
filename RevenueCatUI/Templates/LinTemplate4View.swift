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
    let configuration: TemplateViewConfiguration
    @Environment(\.userInterfaceIdiom)
    var userInterfaceIdiom
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @EnvironmentObject
    private var introEligibilityViewModel: IntroEligibilityViewModel

    private struct WrapperView<Content: View>: View {
        let content: Content
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        var body: some View {
            content
            .fixedSize(horizontal: false, vertical: true)
            .font(.system(size: 13))
        }
    }
    
    init(_ configuration: TemplateViewConfiguration) {
        self.configuration = configuration
    }
    
    @ViewBuilder
    private func paywallContent(displayTimeline: Bool) -> some View {
        LinConfigurableTemplate5View(
            configuration,
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
                    .padding([.top, .bottom], 40)
                AuxiliaryDetailsView()
            }
        default:
            paywallContent(displayTimeline: true)
        }
    }
    
    private struct AuxiliaryDetailsView: View {
        var body: some View {
            VStack(alignment: .leading) {
                Spacer()
                TimelineView(stepConfigurations: TimelineView.defaultIPad, axis: .vertical)
                Spacer().frame(height: 60)
                TestimonialsView()
                Spacer()
                CompanyLogosView()
                Spacer().frame(height: 24)
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
        bundle: TimelineView.bundle,
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
