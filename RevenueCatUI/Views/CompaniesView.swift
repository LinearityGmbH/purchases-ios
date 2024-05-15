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
    private func colorise(_ image: Image) -> some View {
        image
            .renderingMode(.template)
            .foregroundStyle(.primary)
    }
    
    var body: some View {
        HStack {
            colorise(Image(.iconAmazon))
            Spacer()
            colorise(Image(.iconApple))
            Spacer()
            colorise(Image(.iconUniversalPictures))
            Spacer()
            colorise(Image(.iconMcdonalds))
            Spacer()
            colorise(Image(.iconNasa))
            Spacer()
            colorise(Image(.iconSpacex))
            Spacer()
            colorise(Image(.iconGoogle))
        }
        .frame(height: 18)
    }
}
