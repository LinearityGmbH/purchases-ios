//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 14/5/2024.
//

import Foundation
import SwiftUI
import RevenueCat

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TestimonialsView: View {
    private let text = NSLocalizedString("Testimonial.Message", tableName: "Paywall", bundle: Bundle.main, comment: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                ForEach(0..<2) { _ in
                    Image(.testimonialTick)
                        .renderingMode(.template)
                        .foregroundStyle(.secondary)
                }
            }
            Text(text)
                .foregroundStyle(
                    .primary
                )
                .font(.system(size: 13, weight: .regular))
            HStack {
                Image(.nastyaCropped)
                    .resizable(resizingMode: .stretch)
                    .background(content: {
                        Rectangle().fill(
                            Color(red: 214 / 255.0, green: 207 / 255.0, blue: 204 / 255.0)
                        )
                    })
                    .frame(width: 42, height: 42)
                    .cornerRadius(21)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Nastya Kulyabina")
                        .foregroundStyle(
                            .primary
                        )
                        .font(.system(size: 13, weight: .medium))
                    Text("Illustrator and graphic designer")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11, weight: .regular))
                }
            }
        }
    }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
#Preview {
    TestimonialsView()
}

#endif
