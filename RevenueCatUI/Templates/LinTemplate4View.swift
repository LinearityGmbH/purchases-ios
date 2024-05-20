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
    private func paywallContent(_ includeTimeline: Bool) -> some View {
        LinConfigurableTemplate5View(
            configuration,
            getDefaultContentWidth: Constants.defaultContentWidth
        ) {
            if includeTimeline {
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
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    paywallContent(false)
                    .frame(
                        width: geometry.size.width * 0.5,
                        height: geometry.size.height
                    )
                    AuxiliaryDetailsView()
                        .frame(
                            width: geometry.size.width * 0.5,
                            height: geometry.size.height
                        )
                }
            }
        default:
            paywallContent(true)
        }
    }
    
    private struct AuxiliaryDetailsView: View {
        var body: some View {
            HStack {
                Spacer().frame(width: 40)
                VStack {
                    Spacer()
                    TimelineView(stepConfigurations: TimelineView.defaultIPad, axis: .vertical)
                    Spacer().frame(height: 60)
                    TestimonialsView()
                    Spacer()
                    CompanyLogosView()
                    Spacer().frame(height: 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                Spacer().frame(width: 40)
            }
            .background {
                Rectangle()
                    .fill(
                        Color(
                            light: Color(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0),
                            dark: Color(red: 44 / 255.0, green: 44 / 255.0, blue: 46 / 255.0)
                        )
                    )
            }
        }
    }
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
