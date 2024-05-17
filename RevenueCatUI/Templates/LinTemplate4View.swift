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
    var configuration: TemplateViewConfiguration {
        configurableTemplate5.configuration
    }
    var userInterfaceIdiom: UserInterfaceIdiom {
        configurableTemplate5.userInterfaceIdiom
    }
    var verticalSizeClass: UserInterfaceSizeClass? {
        configurableTemplate5.verticalSizeClass
    }
    
    private struct WrapperView<Content: View>: View {
        let content: Content
        var body: some View {
            content
            .fixedSize(horizontal: false, vertical: true)
            .font(.system(size: 13))
        }
    }
    private let configurableTemplate5: LinConfigurableTemplate5View<WrapperView<IntroEligibilityStateView>>
    
    init(_ configuration: TemplateViewConfiguration) {
        configurableTemplate5 = LinConfigurableTemplate5View(
            configuration,
            .init(footer: { (_ selectedPackage: Package, _ eligibility: IntroEligibilityStatus?, locale: Locale) in
                let msgProvider = CTAFooterMessageProvider(locale: locale)
                let view = IntroEligibilityStateView(
                    textWithNoIntroOffer: msgProvider.makeTextWithNoIntroOffer(selectedPackage),
                    textWithIntroOffer: msgProvider.makeTextWithIntroOffer(selectedPackage),
                    introEligibility: eligibility
                )
                return WrapperView(content: view)
            }),
            getDefaultContentWidth: Constants.defaultContentWidth
        )
    }
    
    var body: some View {
        switch configurableTemplate5.horizontalSizeClass {
        case .regular:
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    configurableTemplate5
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
            configurableTemplate5
        }
    }
    
    private struct AuxiliaryDetailsView: View {
        var body: some View {
            HStack {
                Spacer().frame(width: 40)
                VStack {
                    Spacer()
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
