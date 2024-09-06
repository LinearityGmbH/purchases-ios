//
//  LinNavigationLink.swift
//  
//
//  Created by Guillaume LAURES on 11/07/2024.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinNavigationLink<Label: View, Destination: View>: View {
    
    let configuration: TemplateViewConfiguration
    var label: Label
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            label
                .frame(maxWidth: .infinity)
                #if targetEnvironment(macCatalyst)
                .contentShape(Rectangle())
                #endif
        }
        .font(configuration.fonts.font(for: .title3).weight(.semibold))
        .background(backgroundView)
        .frame(maxWidth: .infinity)
        .dynamicTypeSize(...Constants.maximumDynamicTypeSize)
        #if targetEnvironment(macCatalyst)
        .buttonStyle(.plain)
        #endif
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous)
            .foregroundStyle(backgroundColor)
            .frame(height: 45)
    }
    
    private var backgroundColor: Color {
        if let (firstTier, _, _) = configuration.packages.multiTier {
            configuration.colors(for: firstTier).callToActionBackgroundColor
        } else {
            configuration.colors.callToActionBackgroundColor
        }
    }
}
