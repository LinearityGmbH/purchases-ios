//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 14/5/2024.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct CompanyLogosView: View {
    @ViewBuilder
    private func logoIcon(_ resource: ImageResource, spacer: Bool) -> some View {
        Image(resource)
            .renderingMode(.template)
            .foregroundStyle(.primary)
        if spacer {
            Spacer()
        }
    }
    
    var body: some View {
        let items = Array([
            ImageResource.iconAmazon,
            ImageResource.iconApple,
            ImageResource.iconUniversalPictures,
            ImageResource.iconMcdonalds,
            ImageResource.iconNasa,
            ImageResource.iconSpacex,
            ImageResource.iconGoogle
        ]
            .enumerated()
        )
        return HStack {
            ForEach(items, id: \.offset) { (i, resource) in
                logoIcon(resource, spacer: i != items.count - 1)
            }
        }
        .frame(height: 18)
    }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
#Preview {
    CompanyLogosView()
}

#endif
