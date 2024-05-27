//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 21/5/2024.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public func installLocalizations(
    paywallBundle: Bundle,
    timelineBundle: Bundle,
    testimonialsBundle: Bundle
) {
    LinTemplate4View.bundle = paywallBundle
    CTAFooterMessageProvider.bundle = paywallBundle
    TimelineView.bundle = timelineBundle
    TestimonialsView.bundle = testimonialsBundle
}
