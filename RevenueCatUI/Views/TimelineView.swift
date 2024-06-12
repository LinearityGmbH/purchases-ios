//
//  File.swift
//
//
//  Created by Guillaume LAURES on 15/05/2024.
//

import SwiftUI
import UIKit
import RevenueCat

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct TimelineView: View {
    static var bundle = Foundation.Bundle.module
    
    enum Colors {
        static let green = Color(red: 8.0 / 255.0, green: 195.0 / 255.0, blue: 130.0 / 255.0)
        static let linearityOrange = Color(red: 253.0 / 255.0, green: 122.0 / 255.0, blue: 15.0 / 255.0)
        static let link = Color(
            light: Color(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 225.0 / 255.0),
            dark: Color(red: 174.0 / 255.0, green: 174.0 / 255.0, blue: 178.0 / 255.0)
        )
        static let bell = Color(light: .black, dark: Self.link)
        static let iconBackground = Color(light: .white, dark: .secondarySystemBackground)
    }
    
    struct StepConfiguration: Identifiable {
        enum LinkPosition {
            case leading
            case trailing
            case both
            
            var alignmentGuide: Alignment {
                switch self {
                case .leading:
                    return .trailing
                case .both:
                    return .center
                case .trailing:
                    return .leading
                }
            }
        }
        
        let title: String
        let icon: String
        let iconBackgroundColor: Color
        let iconForegroundColor: Color
        let subtitle: String
        let linkColor: Color
        let linkPosition: LinkPosition
        
        init(
            title: String,
            icon: String,
            iconBackgroundColor: Color = TimelineView.Colors.iconBackground,
            iconForegroundColor: Color = .primary,
            subtitle: String,
            linkColor: Color,
            linkPosition: LinkPosition
        ) {
            self.title = title
            self.icon = icon
            self.iconBackgroundColor = iconBackgroundColor
            self.iconForegroundColor = iconForegroundColor
            self.subtitle = subtitle
            self.linkColor = linkColor
            self.linkPosition = linkPosition
        }
        
        var id: String {
            title + subtitle
        }
    }
    
    let stepConfigurations: [StepConfiguration]
    let axis: NSLayoutConstraint.Axis
    
    var body: some View {
        if axis == .horizontal {
            HStack(spacing: 0) {
                content
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        ForEach(stepConfigurations) {
            TimelineStepView(configuration: $0, axis: axis.opposite)
        }
    }
    
    private struct TimelineStepView: View {
        
        let configuration: StepConfiguration
        let axis: NSLayoutConstraint.Axis
        let iconSize: CGFloat = 32
        @State var iconFrame: CGRect = .zero
        
        var body: some View {
            if axis == .vertical {
                GeometryReader { geometry in
                    content
                        .background(alignment: .init(horizontal: .iconAlignment, vertical: .center)) {
                            link
                                .frame(
                                    width: geometry.size.width
                                    + iconFrame.origin.x
                                    - geometry.frame(in: .global).origin.x
                                )
                        }
                }
            } else {
                content
                    .background(alignment: .init(horizontal: .iconAlignment, vertical: .center)) {
                        linkSegment(configuration.linkColor)
                    }
            }
        }
        
        @ViewBuilder
        var link: some View {
            if axis == .vertical {
                HStack {
                    linkSegments
                }
            } else {
                VStack(spacing: 0) {
                    linkSegments
                }
            }
        }
        
        @ViewBuilder
        var linkSegments: some View {
            switch configuration.linkPosition {
            case .leading:
                linkSegment(configuration.linkColor)
                linkSegment(.clear)
            case .trailing:
                linkSegment(.clear)
                linkSegment(configuration.linkColor)
            case .both:
                linkSegment(configuration.linkColor)
                linkSegment(configuration.linkColor)
            }
        }
        
        @ViewBuilder
        func linkSegment(_ color: Color = .clear) -> some View {
            if axis == .vertical {
                Rectangle()
                    .fill(color)
                    .frame(height: 2)
            } else {
                Rectangle()
                    .fill(color)
                    .frame(width: 2)
            }
        }
        
        @ViewBuilder
        var content: some View {
            if axis == .vertical {
                VStack(spacing: 12) {
                    Text(configuration.title)
                        .font(.system(size: 13))
                        .bold()
                    iconWithBackground
                        .alignmentGuide(.iconAlignment) {
                            $0[HorizontalAlignment.center]
                        }
                    Text(configuration.subtitle)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11))
                }
                .frame(maxWidth: .infinity, alignment: configuration.linkPosition.alignmentGuide)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    iconWithBackground
                        .alignmentGuide(.iconAlignment) {
                            $0[HorizontalAlignment.center]
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(configuration.title)
                            .font(.system(size: 17, weight: .semibold))
                        Text(configuration.subtitle)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                            .frame(minHeight: 30, alignment: .top)
                        Spacer()
                            .frame(height: 8)
                    }
                }
            }
        }
        
        @ViewBuilder
        var iconWithBackground: some View {
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(configuration.iconBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: iconSize / 2)
                                .stroke(TimelineView.Colors.link, lineWidth: 1)
                        )
                        .onAppear {
                            iconFrame = geometry.frame(in: .global)
                        }
                    Image(systemName: configuration.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize / 2, height: iconSize / 2)
                        .foregroundColor(configuration.iconForegroundColor)
                }
            }
            .frame(width: iconSize, height: iconSize)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
private func localize(_ key: String, value: String) -> String {
    NSLocalizedString(
        key,
        bundle: TimelineView.bundle,
        value: value,
        comment: ""
    )
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension TimelineView {
    
    static var defaultIPad: [StepConfiguration] {[
        StepConfiguration(
            title: localize("iPad.step1.title", value: "Today: Free trial for 7 days"),
            icon: "gift",
            iconBackgroundColor: TimelineView.Colors.green,
            iconForegroundColor: .black,
            subtitle: localize("iPad.step1.subtitle", value: "Get full access to design and animation tools"),
            linkColor: TimelineView.Colors.green,
            linkPosition: .trailing
        ),
        StepConfiguration(
            title: localize("iPad.step2.title", value: "Day 5: Reminder"),
            icon: "bell",
            iconForegroundColor: TimelineView.Colors.bell,
            subtitle: localize(
                "iPad.step2.subtitle",
                value: "We’ll send you a reminder 2 days before your free trial ends."
            ),
            linkColor: TimelineView.Colors.link,
            linkPosition: .both
        ),
        StepConfiguration(
            title: localize("iPad.step3.title", value: "Day 7: Trial ends"),
            icon: "crown.fill",
            iconForegroundColor: TimelineView.Colors.linearityOrange,
            subtitle: localize(
                "iPad.step3.subtitle",
                value: "Your Pro subscription starts, unless you’ve canceled during the trial."
            ),
            linkColor: .clear,
            linkPosition: .leading
        )
    ]}
    
    static var defaultIPhone: [StepConfiguration] {[
        StepConfiguration(
            title: localize("iPhone.step1.title", value: "Start free trial"),
            icon: "gift",
            iconBackgroundColor: TimelineView.Colors.green,
            iconForegroundColor: .black,
            subtitle: localize("iPhone.step1.subtitle", value: "Today"),
            linkColor: TimelineView.Colors.green,
            linkPosition: .trailing
        ),
        StepConfiguration(
            title: localize("iPhone.step2.title", value: "Reminder"),
            icon: "bell",
            subtitle: localize("iPhone.step2.subtitle", value: "Day 5"),
            linkColor: TimelineView.Colors.link,
            linkPosition: .both
        ),
        StepConfiguration(
            title: localize("iPhone.step3.title", value: "Trial ends"),
            icon: "crown.fill",
            iconForegroundColor: TimelineView.Colors.linearityOrange,
            subtitle: localize("iPhone.step3.subtitle", value: "Day 7"),
            linkColor: TimelineView.Colors.link,
            linkPosition: .leading
        )
    ]}
}

private extension NSLayoutConstraint.Axis {
    var opposite: NSLayoutConstraint.Axis {
        switch self {
        case .vertical:
            return .horizontal
        case .horizontal:
            return .vertical
        @unknown default:
            return self
        }
    }
}

@available(iOS 13.0, *)
private extension HorizontalAlignment {
    private enum IconAlignment: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            return dimensions[HorizontalAlignment.center]
        }
    }
    static let iconAlignment = HorizontalAlignment(IconAlignment.self)
}

#if DEBUG
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(
            stepConfigurations: TimelineView.defaultIPhone,
            axis: .horizontal
        )
        .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
        .previewDisplayName("iPhone")
        
        TimelineView(
            stepConfigurations: TimelineView.defaultIPad,
            axis: .vertical
        )
        .previewDevice(PreviewDevice(rawValue: "iPad Pro 11-inch (M4)"))
        .previewDisplayName("iPad")
    }
}
#endif
