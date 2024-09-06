//
//  FeatureAndPackageViewWrapper.swift
//  RevenueCat
//
//  Created by Guillaume LAURES on 05/09/2024.
//

import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TierFeatureAndPackageView<FeaturesView: View, PackagesView: View>: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    let tiers: [PaywallData.Tier: TemplateViewConfiguration.PackageConfiguration.MultiPackage]
    let allPackages: [TemplateViewConfiguration.Package]
    
    @Binding
    var selectedPackage: TemplateViewConfiguration.Package
    @Binding
    var selectedTier: PaywallData.Tier
    
    @ViewBuilder
    let features: (_ package: TemplateViewConfiguration.Package) -> FeaturesView
    @ViewBuilder
    let packages: (_ packages: [TemplateViewConfiguration.Package]) -> PackagesView
    
    var body: some View {
        ConsistentTierContentView(
            tiers: tiers,
            selected: selectedTier
        ) { _, packagesConfiguration in
            VStack {
                ConsistentPackageContentView(
                    packages: allPackages,
                    selected: selectedPackage
                ) { package in
                    features(package)
                }
                if horizontalSizeClass == .compact {
                    Spacer()
                }
                ConsistentTierContentView(
                    tiers: tiers,
                    selected: selectedTier
                ) { _, packages in
                    self.packages(packages.all)
                }
            }
        }
    }
}
