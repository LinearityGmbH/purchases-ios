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
    let titleTypeProvider: (TemplateViewConfiguration.Package) -> TitleView.TitleType
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        Label {
            TitleView(type: titleTypeProvider(selectedPackage))
        } icon: {
            backButton
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
