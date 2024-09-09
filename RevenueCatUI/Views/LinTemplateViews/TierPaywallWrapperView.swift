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
    
    let configuration: TemplateViewConfiguration
    let currentColors: LinColorsProvider
    
    @Binding
    var selectedPackage: TemplateViewConfiguration.Package
    
    let subtitle: () -> SubtitleView
    @ViewBuilder
    let features: (_ package: TemplateViewConfiguration.Package) -> FeaturesView
    @ViewBuilder
    let packages: (_ packages: [TemplateViewConfiguration.Package]) -> PackagesView
    
    @Binding
    private var selectedTier: PaywallData.Tier
    private var displayableTiers: [PaywallData.Tier] {
        // Filter out to display tiers only
        // Tiers may not exist in self.tiers if there are no products available
        return self.configuration.configuration.tiers.filter({ tier in
            return self.tiers[tier] != nil
        })
    }
    private let tiers: [PaywallData.Tier: TemplateViewConfiguration.PackageConfiguration.MultiPackage]
    private let tierNames: [PaywallData.Tier: String]
    
    init(
        selectedTier: Binding<PaywallData.Tier?>,
        selectedPackage: Binding<TemplateViewConfiguration.Package>,
        configuration: TemplateViewConfiguration,
        currentColors: LinColorsProvider,
        subtitle: @escaping () -> SubtitleView,
        features: @escaping (_ package: TemplateViewConfiguration.Package) -> FeaturesView,
        packages: @escaping (_ packages: [TemplateViewConfiguration.Package]) -> PackagesView
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
        self.subtitle = subtitle
        self.features = features
        self.packages = packages
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TierSelectorViewWrapper(
                tiers: tiers,
                tierNames: tierNames,
                configuration: configuration,
                currentColors: currentColors,
                selectedPackage: $selectedPackage,
                selectedTier: $selectedTier
            )
            subtitle()
            TierFeatureAndPackageView(
                tiers: tiers,
                allPackages: configuration.packages.all,
                selectedPackage: $selectedPackage,
                selectedTier: $selectedTier,
                features: features,
                packages: packages
            )
        }
    }
}
