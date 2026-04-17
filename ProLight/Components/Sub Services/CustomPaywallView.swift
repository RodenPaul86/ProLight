//
//  CustomPaywallView.swift
//  ProLight
//
//  Created by Paul  on 4/17/26.
//

import SwiftUI
import RevenueCatUI
import SDWebImageSwiftUI

struct CustomPaywallView: View {
    @Binding var model: PaywallModel?
    @Binding var showDefaultView: Bool
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            VStack {
                if let model, !showDefaultView {
                    /// Custom PaywallView
                    CustomView(model: model, size: size, safeArea: safeArea)
                } else {
                    if model == nil && !showDefaultView {
                        /// Loading State
                        ProgressView()
                            .frame(width: size.width, height: size.height)
                    }
                    
                    /// Ignoring Custom Paywall View and presenting RC default Paywall View
                    if showDefaultView {
                        PaywallView()
                    }
                }
            }
        }
    }
    
    /// Custom View
    @ViewBuilder
    func CustomView(model: PaywallModel, size: CGSize, safeArea: EdgeInsets) -> some View {
        ScrollView {
            VStack {
                GeometryReader {
                    let size = $0.size
                    let isSticky = model.stickyHeader
                    let stretchyHeader = model.stretchyHeader
                    
                    WebImage(url: URL(string: model.headerImage))
                }
            }
        }
        .scrollIndicators(.hidden)
        .originalTemplatePaywallFooter(condensed: true) { info in
            /// Completed
        } restoreCompleted: { info in
            /// Restored
        }
    }
}

#Preview {
    ContentView()
}
