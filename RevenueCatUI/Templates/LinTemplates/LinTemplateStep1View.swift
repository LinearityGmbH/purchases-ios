//
//  File.swift
//  
//
//  Created by Guillaume LAURES on 28/06/2024.
//

import Foundation
import RevenueCat
import SwiftUI

struct LinTemplateStep1Configuration: Decodable {
    // It has to be snakecase due to the decoder.
    enum CodingKeys: String, CodingKey {
        case titleKey = "titleKey"
        case imageNameMacOS = "imageNameMacos"
        case imageNameIOS = "imageNameIos"
        case backgroundColourName = "backgroundColourName"
    }
    
    let titleKey: String?
    let imageNameMacOS: String
    let imageNameIOS: String
    let backgroundColourName: String
}

extension LinTemplateStep1Configuration {
    static let `default` = LinTemplateStep1Configuration(
        titleKey: "Step1.AuxiliaryDetailsView.Title",
        imageNameMacOS: "paywall-first-step-general-ios",
        imageNameIOS: "paywall-first-step-general-macos",
        backgroundColourName: "paywall-first-step-general-colour"
    )
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension LinTemplateStep1Configuration {
    var title: String? {
        if let titleKey {
            let localizedText = localize(titleKey, value: "")
            if localizedText.isEmpty {
                return nil
            }
            return localizedText
        }
        return nil
    }
    
    var image: ImageResource {
        #if targetEnvironment(macCatalyst)
        let imageName = imageNameMacOS
        #else
        let imageName = imageNameIOS
        #endif
        return ImageResource(
            name: imageName,
            bundle: LinTemplatesResources.linTemplate5Step1Bundle
        )
    }
    
    var backgroundColour: Color {
        Color(backgroundColourName, bundle: LinTemplatesResources.linTemplate5Step1Bundle)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinTemplateStep1View<ButtonView: View>: View, IntroEligibilityProvider {
    
    let configuration: TemplateViewConfiguration
    let auxiliaryConfiguration: LinTemplateStep1Configuration
    
    private let accentColor: Color
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
        configuration: TemplateViewConfiguration,
        auxiliaryConfiguration: LinTemplateStep1Configuration,
        accentColor: Color,
        buttonView: @escaping () -> ButtonView
    ) {
        self.configuration = configuration
        self.auxiliaryConfiguration = auxiliaryConfiguration
        self.accentColor = accentColor
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
            TitleView(type: .dynamic(
                isEligibleToIntro: isEligibleToIntro,
                bundle: LinTemplatesResources.linTemplate5Step1Bundle,
                ineligibleFallback: selectedPackage.localization.title
            ))
            subtitle
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
        VStack(alignment: .leading, spacing: 16) {
            Spacer(minLength: 10)
            ForEach(features, id: \.title) { titleSubtitle in
                featureListItemView(title: titleSubtitle.title, subtitle: titleSubtitle.subtitle)
            }
            Spacer(minLength: 10)
        }
    }
    
    @ViewBuilder
    private func featureListItemView(title: String, subtitle: String) -> some View {
        HStack(alignment: .top) {
            Image(.icCheckmark)
                .foregroundColor(accentColor)
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
        VStack {
            Spacer()
            if let title = auxiliaryConfiguration.title {
                Text(LocalizedStringKey(title))
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20))
                    .foregroundStyle(.black)
                    .padding([.leading, .trailing, .bottom], 20)
            }
            Image(auxiliaryConfiguration.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
        }
        .background(auxiliaryConfiguration.backgroundColour)
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
                LinTemplateStep1View(
                    configuration: configuration,
                    auxiliaryConfiguration: .init(
                        titleKey: "Hi **Paywall**",
                        imageNameMacOS: "paywall-first-step-macOS",
                        imageNameIOS: "paywall-first-step-iOS",
                        backgroundColourName: "paywall-first-step-general-colour"
                    ),
                    accentColor: configuration.colors.accent1Color
                ) {
                    LinNavigationLink(
                        configuration: configuration,
                        accentColor: configuration.colors.accent1Color,
                        label: Text("Continue"),
                        destination: EmptyView()
                    )
                }
            }
        }
    }
    
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension LinTemplateStep1View: TemplateViewType {
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
