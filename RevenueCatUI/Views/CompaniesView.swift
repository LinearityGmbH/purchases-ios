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
    var body: some View {
        HStack {
            Image(.iconAmazon)
            Spacer()
            Image(.iconApple)
            Spacer()
            Image(.iconUniversalPictures)
            Spacer()
            Image(.iconMcdonalds)
            Spacer()
            Image(.iconNasa)
            Spacer()
            Image(.iconSpacex)
            Spacer()
            Image(.iconGoogle)
        }
        .frame(height: 18)
    }
}
