//
//  File.swift
//  
//
//  Created by Guillaume LAURES on 12/07/2024.
//

import Foundation
import RevenueCat

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
protocol IntroEligibilityProvider {
    var selectedPackage: TemplateViewConfiguration.Package { get }
    var introEligibilityViewModel: IntroEligibilityViewModel { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
extension IntroEligibilityProvider {
    
    var introEligibility: IntroEligibilityStatus? {
        introEligibilityViewModel.allEligibility[selectedPackage.content]
    }
    
    var isEligibleToIntro: Bool {
        introEligibility == .eligible
    }
}
