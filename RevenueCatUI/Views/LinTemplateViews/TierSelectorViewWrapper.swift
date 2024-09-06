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
    
    let tiers: [PaywallData.Tier: TemplateViewConfiguration.PackageConfiguration.MultiPackage]
    let tierNames: [PaywallData.Tier: String]
    let configuration: TemplateViewConfiguration
    let currentColors: LinColorsProvider
    
    @Binding
    var selectedPackage: TemplateViewConfiguration.Package
    @Binding
    var selectedTier: PaywallData.Tier
    
    private var displayableTiers: [PaywallData.Tier] {
        // Filter out to display tiers only
        // Tiers may not exist in self.tiers if there are no products available
        configuration.configuration.tiers.filter { tier in
            tiers[tier] != nil
        }
    }
    
    var body: some View {
        TierSelectorView(
            tiers: displayableTiers,
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
    }
}
