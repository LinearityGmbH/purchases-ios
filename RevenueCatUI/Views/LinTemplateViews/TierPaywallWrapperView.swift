//
//  TierPaywallWrapperView.swift
//  RevenueCat
//
//  Created by Guillaume LAURES on 06/09/2024.
//

import SwiftUI
import RevenueCat

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TierPaywallWrapperView<FeaturesView: View, PackagesView: View, SubtitleView: View>: View {
    
    private let configuration: TemplateViewConfiguration
    private let currentColors: LinColorsProvider
    private let subtitleView: () -> SubtitleView
    private let featuresView: (_ package: TemplateViewConfiguration.Package) -> FeaturesView
    private let packagesView: (_ packages: [TemplateViewConfiguration.Package]) -> PackagesView
    private let tiers: [PaywallData.Tier: TemplateViewConfiguration.PackageConfiguration.MultiPackage]
    private let tierNames: [PaywallData.Tier: String]
    
    @Binding
    private var selectedTier: PaywallData.Tier
    @Binding
    private var selectedPackage: TemplateViewConfiguration.Package
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    init(
        selectedTier: Binding<PaywallData.Tier?>,
        selectedPackage: Binding<TemplateViewConfiguration.Package>,
        configuration: TemplateViewConfiguration,
        currentColors: LinColorsProvider,
        subtitleView: @escaping () -> SubtitleView,
        featuresView: @escaping (_ package: TemplateViewConfiguration.Package) -> FeaturesView,
        packagesView: @escaping (_ packages: [TemplateViewConfiguration.Package]) -> PackagesView
    ) {
        guard let (_, allTiers, tierNames) = configuration.packages.multiTier else {
            fatalError("Attempted to display a multi-tier template with invalid data: \(configuration.packages)")
        }
        self.tiers = allTiers
        self.tierNames = tierNames
        self._selectedTier = Binding(get: {
            selectedTier.wrappedValue!
        }, set: { value in
            selectedTier.wrappedValue = value
        })
        self._selectedPackage = selectedPackage
        self.configuration = configuration
        self.currentColors = currentColors
        self.subtitleView = subtitleView
        self.featuresView = featuresView
        self.packagesView = packagesView
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TierSelectorView(
                tiers: Array(tiers.keys),
                tierNames: tierNames,
                selectedTier: $selectedTier,
                fonts: configuration.fonts,
                backgroundColor: currentColors.tierControlBackground,
                textColor: currentColors.tierControlForeground,
                selectedBackgroundColor: currentColors.tierControlSelectedBackground,
                selectedTextColor: currentColors.tierControlSelectedForeground
            )
            .onChangeOf(selectedTier) { tier in
                withAnimation(Constants.tierChangeAnimation) {
                    selectedPackage = tiers[tier]!.default
                }
            }
            subtitleView()
            ConsistentTierContentView(
                tiers: tiers,
                selected: selectedTier
            ) { _, packagesConfiguration in
                VStack {
                    featuresView(selectedPackage)
                    if horizontalSizeClass == .compact {
                        Spacer()
                    }
                    ConsistentTierContentView(
                        tiers: tiers,
                        selected: selectedTier
                    ) { _, packages in
                        packagesView(packages.all)
                    }
                }
            }
        }
    }
}
