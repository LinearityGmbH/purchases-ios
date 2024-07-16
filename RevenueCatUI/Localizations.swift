//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 21/5/2024.
//

import Foundation
import UIKit
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public func setupPaywall(
    paywallFirstStepBundle: Bundle,
    paywallSecondStepBundle: Bundle,
    timelineBundle: Bundle,
    testimonialsBundle: Bundle
) {
    LinTemplatesResources.linTemplate5Step1Bundle = paywallFirstStepBundle
    LinTemplatesResources.linTemplate5Step2Bundle = paywallSecondStepBundle
    CTAFooterMessageProvider.bundle = paywallSecondStepBundle
    TimelineView.bundle = timelineBundle
    TestimonialsView.bundle = testimonialsBundle
}
