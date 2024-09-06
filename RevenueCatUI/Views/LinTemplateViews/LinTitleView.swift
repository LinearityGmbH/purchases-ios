//
//  LinTitleView.swift
//  RevenueCat
//
//  Created by Guillaume LAURES on 06/09/2024.
//

import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinTitleView: View {
    
    let configuration: TemplateViewConfiguration
    let showBackButton: Bool
    @Binding
    var selectedPackage: TemplateViewConfiguration.Package
    @Binding
    var selectedTier: PaywallData.Tier?
    let titleTypeProvider: (TemplateViewConfiguration.Package) -> TitleView.TitleType
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        if let selectedTier {
            ConsistentPackageContentView(
                packages: self.configuration.packages.all,
                selected: self.selectedPackage
            ) { package in
                title(package: package)
            }
        } else {
            title(package: selectedPackage)
        }
    }
    
    @ViewBuilder
    private func title(package: TemplateViewConfiguration.Package) -> some View {
        HStack {
            backButton
            TitleView(type: titleTypeProvider(package))
        }
    }
    
    @ViewBuilder
    private var backButton: some View {
        if showBackButton {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "chevron.backward")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    #if targetEnvironment(macCatalyst)
                    .padding([.trailing], 4)
                    .contentShape(Rectangle())
                    #endif
            })
            #if targetEnvironment(macCatalyst)
            .buttonStyle(.plain)
            #endif
        }
    }
}
