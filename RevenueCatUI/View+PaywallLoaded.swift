//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 26/6/2024.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct PaywallDidLoadPreferenceKey: PreferenceKey {

    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
    
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct OnPaywallDidLoadModifier: ViewModifier {
    
    let handler: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(PaywallDidLoadPreferenceKey.self) { value in
                if value {
                    handler()
                }
            }
    }
    
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable, message: "RevenueCatUI does not support macOS yet")
extension View {
    
    public func onPaywallDidLoad(
        _ handler: @escaping () -> Void
    ) -> some View {
        return self.modifier(OnPaywallDidLoadModifier(handler: handler))
    }
    
}
