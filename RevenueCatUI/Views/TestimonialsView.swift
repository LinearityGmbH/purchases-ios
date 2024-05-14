//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 14/5/2024.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct TestimonialsView: View {
    
    private let text = NSLocalizedString("Testimonial.Message", tableName: "Paywall", bundle: Bundle.main, comment: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                ForEach(0..<2) { _ in
                    Image(.testimonialTick)
                }
            }
            Text(text)
                .foregroundStyle(Color(red: 32 / 255.0, green: 32 / 255.0, blue: 32 / 255.0))
                .font(.system(size: 13, weight: .regular))
            HStack {
                Image(.nastyaCropped)
                    .resizable(resizingMode: .stretch)
                    .background(content: {
                        Rectangle().fill(Color(red: 214 / 255.0, green: 207 / 255.0, blue: 204 / 255.0))
                    })
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Nastya Kulyabina")
                        .foregroundStyle(Color(red: 28 / 255.0, green: 28 / 255.0, blue: 30 / 255.0))
                        .font(.system(size: 13, weight: .medium))
                    Text("Illustrator and graphic designer")
                        .foregroundStyle(Color(red: 0, green: 0, blue: 0, opacity: 0.48))
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
struct TestimonialsView_Previews: PreviewProvider {

    static var previews: some View {
        TestimonialsView()
    }

}

#endif
