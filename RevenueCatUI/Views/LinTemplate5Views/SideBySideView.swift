//
//  File.swift
//  
//
//  Created by Guillaume LAURES on 28/06/2024.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct SideBySideView<LeftView: View, RightView: View>: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @ViewBuilder
    let leftView: LeftView
    @ViewBuilder
    let rightView: RightView
    
    var body: some View {
        switch horizontalSizeClass {
        case .regular:
            HStack(spacing: 0) {
                leftView
                    .padding(EdgeInsets(top: 0, leading: 32, bottom: 6, trailing: 32))
                rightView.frame(maxWidth: 335)
            }
        default:
            leftView
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
    }
}
