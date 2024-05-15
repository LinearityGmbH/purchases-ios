//
//  File.swift
//  
//
//  Created by Max Stobetskyi on 14/5/2024.
//

import Foundation
import RevenueCat
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LinTemplate4View: TemplateViewType {
    
    let configuration: TemplateViewConfiguration
    
    @State
    private var selectedPackage: TemplateViewConfiguration.Package
    
    @State
    private var displayingAllPlans: Bool
    
    @Environment(\.userInterfaceIdiom)
    var userInterfaceIdiom
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    
    @Environment(\.locale)
    var locale
    
    @EnvironmentObject
    private var introEligibilityViewModel: IntroEligibilityViewModel
    @EnvironmentObject
    private var purchaseHandler: PurchaseHandler
    
    init(_ configuration: TemplateViewConfiguration) {
        self._selectedPackage = .init(initialValue: configuration.packages.default)
        self.configuration = configuration
        self._displayingAllPlans = .init(initialValue: configuration.mode.displayAllPlansByDefault)
    }
    
    var body: some View {
        switch horizontalSizeClass {
        case .regular:
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    LinTemplate5View(configuration)
                        .frame(
                            width: geometry.size.width * 0.5,
                            height: geometry.size.height
                        )
                    AuxiliaryDetailsView()
                        .frame(
                            width: geometry.size.width * 0.5,
                            height: geometry.size.height
                        )
                }
            }
        default:
            LinTemplate5View(configuration)
        }
    }
    
    private struct AuxiliaryDetailsView: View {
        var body: some View {
            HStack {
                Spacer().frame(width: 40)
                VStack {
                    Spacer()
                    TestimonialsView()
                    Spacer()
                    CompanyLogosView()
                    Spacer().frame(height: 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                Spacer().frame(width: 40)
            }
            .background {
                Rectangle()
                    .fill(
                        Color(
                            light: Color(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0),
                            dark: Color(red: 44 / 255.0, green: 44 / 255.0, blue: 46 / 255.0)
                        )
                    )
            }
        }
    }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(watchOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct LinTemplate4View_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(PaywallViewMode.allCases, id: \.self) { mode in
            PreviewableTemplate(
                offering: TestData.offeringWithLinTemplate5Paywall,
                mode: mode
            ) {
                LinTemplate4View($0)
            }
        }
    }

}

#endif
