//
//  aboutView.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import SwiftUI

struct aboutView: View {
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        customRow(icon: "app", firstLabel: "Application", secondLabel: Bundle.main.appName)
                        customRow(icon: "curlybraces", firstLabel: "Language", secondLabel: "Swift/SwiftUI")
                        customRow(icon: "square.on.square.dashed", firstLabel: "Version", secondLabel: Bundle.main.appVersion)
                        customRow(icon: "hammer", firstLabel: "Build", secondLabel: Bundle.main.appBuild)
                    }
                    
                    Section(footer: Text("© 2016 - \(Date(), format: .dateTime.year()) Paul Roden Jr. All Rights Reserved, Made in USA 🇺🇸.")) {
                        customRow(icon: "laptopcomputer", firstLabel: "Developer", secondLabel: "Paul Roden Jr.")
                        
                        Text("ProLight was crafted by a single dedicated indie iOS developer, who relies on your support to grow. \n\nTogether, we'll continuously expand and enrich the experience, ensuring you always get the most out of your subscription. \n\nThank you for being a part of this journey!")
                            .font(.subheadline)
                        
                        customRow(icon: "link", firstLabel: "My Website", secondLabel: "", url: "https://paulrodenjr.dev")
                        customRow(icon: "link", firstLabel: "GitHub", secondLabel: "", url: "https://github.com/RodenPaul86")
                    }
                }
            }
            .onAppear {
                hideTabBar = true
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .hideFloatingTabBar(hideTabBar)
        }
    }
}

#Preview {
    aboutView()
}
