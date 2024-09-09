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
    static var bundle = Foundation.Bundle.module
    private let text = NSLocalizedString(
        "Message",
        bundle: Self.bundle,
        value: "Curve's user-friendly interface provides an amazing user experience, and this is one of the main reasons that made me choose Linearity Curve instead of other alternatives.",
        comment: ""
    )
    private let author = NSLocalizedString(
        "Author",
        bundle: Self.bundle,
        value: "Nastya Kulyabina",
        comment: ""
    )
    private let role = NSLocalizedString(
        "Role",
        bundle: Self.bundle,
        value: "Illustrator and graphic designer",
        comment: ""
    )

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
                Image(ImageResource(name: "Author", bundle: Self.bundle))
                    .resizable(resizingMode: .stretch)
                    .background(content: {
                        Rectangle().fill(
                            Color(red: 214 / 255.0, green: 207 / 255.0, blue: 204 / 255.0)
                        )
                    })
                    .frame(width: 42, height: 42)
                    .cornerRadius(21)
                VStack(alignment: .leading, spacing: 0) {
                    Text(author)
                        .foregroundStyle(
                            .primary
                        )
                        .font(.system(size: 13, weight: .medium))
                    Text(role)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11, weight: .regular))
                }
                Spacer()
            }
        }
    }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
#Preview {
    TestimonialsView().frame(width: 300)
}

#endif