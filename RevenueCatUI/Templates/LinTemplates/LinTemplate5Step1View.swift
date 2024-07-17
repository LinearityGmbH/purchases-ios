//
//  File.swift
//  
//
//  Created by Guillaume LAURES on 28/06/2024.
//

import Foundation
import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinTemplate5Step1View<ButtonView: View>: View, IntroEligibilityProvider {
    
    let configuration: TemplateViewConfiguration
    
    private let buttonView: () -> ButtonView
    
    @EnvironmentObject
    var introEligibilityViewModel: IntroEligibilityViewModel
    var selectedPackage: TemplateViewConfiguration.Package {
        configuration.packages.default
    }
    
    let features = [
        (title: localize("Step1.Feature1.Title", value: "No limits to your creativity"),
         subtitle: localize("Step1.Feature1.Subtitle", value: "Export to vector formats and with any resolutions.")),
        (title: localize("Step1.Feature2.Title", value: "Transform your photos instantly"),
         subtitle: localize("Step1.Feature2.Subtitle", value: "Unlimited background removal usage and up to 50 AI Background generations")),
        (title: localize("Step1.Feature3.Title", value: "Images to vector in seconds"),
         subtitle: localize("Step1.Feature3.Subtitle", value: "Unlimited Auto-trace uses")),
        (title: localize("Step1.Feature4.Title", value: "Unlimited files & artboards"),
         subtitle: localize("Step1.Feature4.Subtitle", value: "Extend your design space"))
    ]
    
    init(
        _ configuration: TemplateViewConfiguration,
        buttonView: @escaping () -> ButtonView
    ) {
        self.configuration = configuration
        self.buttonView = buttonView
    }
    
    var body: some View {
        SideBySideView {
            titleFeaturesView
        } rightView: {
            auxiliaryDetailsView
        }
    }
    
    @ViewBuilder
    private var titleFeaturesView: some View {
        VStack {
            contentView
                .frame(maxWidth: .infinity)
                .scrollableIfNecessaryWhenAvailable(enabled: configuration.mode.isFullScreen)
            Spacer()
            buttonView()
            .frame(maxWidth: Constants.defaultContentWidth)
            .padding([.bottom], 40)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 10) {
            TitleView(type: .dynamic(isEligibleToIntro: isEligibleToIntro, bundle: LinTemplatesResources.linTemplate5Step1Bundle))
            subtitle
                .padding([.bottom], 10)
            featureList
        }
    }
    
    private var subtitle: some View {
        let text: String
        if let introductoryOfferDaysDuration = configuration.packages.introductoryOfferDaysDuration, isEligibleToIntro {
            let translation = localize(
                "Step1.SubtitleWithOffer",
                value: "Get unlimited access to all Linearity features for free for %d days. We will remind you before cancellation date."
            )
            text = String(format: translation, introductoryOfferDaysDuration)
        } else {
            text = localize("Step1.SubtitleNoOffer", value: "Get unlimited access to all Linearity features.")
        }
        return Text(text)
            .font(.system(size: 15))
    }
    
    @ViewBuilder
    private var featureList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(features, id: \.title) { titleSubtitle in
                featureListItemView(title: titleSubtitle.title, subtitle: titleSubtitle.subtitle)
            }
        }
    }
    
    @ViewBuilder
    private func featureListItemView(title: String, subtitle: String) -> some View {
        HStack(alignment: .top) {
            Image(.icCheckmark)
                .foregroundColor(configuration.colors.accent1Color)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    @ViewBuilder
    private var auxiliaryDetailsView: some View {
        #if targetEnvironment(macCatalyst)
        let imageName = "paywall-first-step-macOS"
        #else
        let imageName = "paywall-first-step-iOS"
        #endif
        let imageResource = ImageResource(name: imageName, bundle: LinTemplatesResources.linTemplate5Step1Bundle)
        VStack() {
            Spacer()
            // wrap around LocalizedStringKey to have Markdown support
            Text(LocalizedStringKey(localize("Step1.AuxiliaryDetailsView.Title", value: "Boost your productivity **with AI-powered tools**")))
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .padding([.leading, .trailing, .bottom], 20)
            Image(imageResource)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
        }
        .background(Color("paywall-first-step-imageBackgroundColor", bundle: LinTemplatesResources.linTemplate5Step1Bundle))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
private func localize(_ key: String, value: String) -> String {
    NSLocalizedString(
        key,
        bundle: LinTemplatesResources.linTemplate5Step1Bundle,
        value: value,
        comment: ""
    )
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(watchOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct LinTemplate5Step1View_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(PaywallViewMode.allCases, id: \.self) { mode in
            PreviewableTemplate(
                offering: TestData.offeringWithLinTemplate5Paywall,
                mode: mode
            ) { configuration in
                LinTemplate5Step1View(configuration) {
                    LinNavigationLink(
                        configuration: configuration,
                        label: Text("Continue"),
                        destination: EmptyView()
                    )
                }
            }
        }
    }
    
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension LinTemplate5Step1View: TemplateViewType {
    var userInterfaceIdiom: UserInterfaceIdiom {
        .unknown
    }
    
    var verticalSizeClass: UserInterfaceSizeClass? {
        .compact
    }
    
    init(_ configuration: TemplateViewConfiguration) {
        fatalError("Used only for preview")
    }
}

#endif
