//
//  LinColorsProvider.swift
//  RevenueCat
//
//  Created by Guillaume LAURES on 06/09/2024.
//

import SwiftUI
import RevenueCat

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class LinColorsProvider {
    
    let configuration: TemplateViewConfiguration
    @Binding
    var tier: PaywallData.Tier?
    
    var text1Color: Color { currentColors.text1Color }
    var featureIcon: Color { currentColors.featureIcon }
    var selectedOutline: Color { currentColors.selectedOutline }
    var unselectedOutline: Color { currentColors.unselectedOutline }
    var selectedDiscountText: Color { currentColors.selectedDiscountText }
    var unselectedDiscountText: Color { currentColors.unselectedDiscountText }
    var selectedTier: Color { currentColors.selectedTier }
    var callToAction: Color { currentColors.callToAction }
    var tierControlBackground: Color { currentColors.tierControlBackground }
    var tierControlForeground: Color { currentColors.tierControlForeground }
    var tierControlSelectedBackground: Color { currentColors.tierControlSelectedBackground }
    var tierControlSelectedForeground: Color { currentColors.tierControlSelectedForeground }
    
    private var currentColors: PaywallData.Configuration.Colors {
        if let tier {
            configuration.colors(for: tier)
        } else {
            configuration.colors
        }
    }
    
    init(configuration: TemplateViewConfiguration, tier: Binding<PaywallData.Tier?>) {
        self.configuration = configuration
        self._tier = tier
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.2, *)
private extension PaywallData.Configuration.Colors {
    
    var featureIcon: Color { self.accent1Color }
    var selectedOutline: Color { self.accent2Color }
    var unselectedOutline: Color { self.accent3Color }
    var selectedDiscountText: Color { self.text2Color }
    var unselectedDiscountText: Color { self.text3Color }
    var selectedTier: Color { self.accent1Color }
    var callToAction: Color { self.selectedTier }
    
    var tierControlBackground: Color { self.tierControlBackgroundColor ?? self.accent1Color }
    var tierControlForeground: Color { self.tierControlForegroundColor ?? self.text1Color }
    var tierControlSelectedBackground: Color { self.tierControlSelectedBackgroundColor ?? self.unselectedDiscountText }
    var tierControlSelectedForeground: Color { self.tierControlSelectedForegroundColor ?? self.text1Color }
    
}
