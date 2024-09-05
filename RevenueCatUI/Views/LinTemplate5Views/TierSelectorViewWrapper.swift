//
//  TierSelectorViewWrapper.swift
//  RevenueCat
//
//  Created by Guillaume LAURES on 05/09/2024.
//

import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TierSelectorViewWrapper: View {
    
    @Binding
    var selectedPackage: TemplateViewConfiguration.Package
    let configuration: TemplateViewConfiguration
    let colors: LinColors
    
    @State
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
        selectedPackage: Binding<TemplateViewConfiguration.Package>,
        configuration: TemplateViewConfiguration,
        colors: LinColors
    ) {
        guard let (firstTier, allTiers, tierNames) = configuration.packages.multiTier else {
            fatalError("Attempted to display a multi-tier template with invalid data: \(configuration.packages)")
        }
        self.tiers = allTiers
        self.tierNames = tierNames
        self._selectedTier = .init(initialValue: firstTier)
        self._selectedPackage = selectedPackage
        self.configuration = configuration
        self.colors = colors
    }

    
    var body: some View {
        TierSelectorView(
            tiers: self.displayableTiers,
            tierNames: self.tierNames,
            selectedTier: self.$selectedTier,
            fonts: self.configuration.fonts,
            backgroundColor: self.colors.tierControlBackground,
            textColor: self.colors.tierControlForeground,
            selectedBackgroundColor: self.colors.tierControlSelectedBackground,
            selectedTextColor: self.colors.tierControlSelectedForeground
        )
        .onChangeOf(self.selectedTier) { tier in
            withAnimation(Constants.tierChangeAnimation) {
                self.selectedPackage = self.tiers[tier]!.default
            }
        }
    }
}
