//
//  TitleView.swift
//  
//
//  Created by Guillaume LAURES on 28/06/2024.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct TitleView: View {
    
    enum TitleType {
        case dynamic(isEligibleToIntro: Bool, bundle: Bundle, ineligibleFallback: String)
        case fixed(String)
        
        var value: String {
            switch self {
            case let .dynamic(isEligibleToIntro, bundle, ineligibleFallback):
                if isEligibleToIntro {
                    localize("Title.EligibleOffering", value: "Try Linearity Pro for free", bundle: bundle)
                } else {
                    ineligibleFallback
                }
            case .fixed(let string):
                string
            }
        }
        
        private func localize(_ key: String, value: String, bundle: Bundle) -> String {
            NSLocalizedString(
                key,
                bundle: bundle,
                value: value,
                comment: ""
            )
        }
    }
    
    let type: TitleType
    
    var body: some View {
        Text(type.value)
            .font(.system(size: 21, weight: .bold))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
