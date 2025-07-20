//
//  ContentView.swift
//  ProLight
//
//  Created by Paul  on 5/28/25.
//

import SwiftUI

enum AppTab: String, CaseIterable, FloatingTabProtocol {
    case home = "Home"
    case morseCode = "Code"
    case map = "Map"
    case fitness = "Fitness"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .home: "flashlight.on.fill"
        case .morseCode: "dot.radiowaves.left.and.right"
        case .map: "map"
        case .fitness: "figure.run"
        case .settings: "gear"
        }
    }
}

struct ContentView: View {
    @State private var activeTab: AppTab = .home
    
    var body: some View {
        FloatingTabView(selection: $activeTab) { tab, tabBarHeight in
            switch tab {
            case .home: HomeView(tabBarHeight: tabBarHeight)
            case .map: WalkingMapView(tabBarHeight: tabBarHeight)
            case .fitness: Text("Fitness")
            case .morseCode: Text("Morse Code")
            case .settings: LibraryView(tabBarHeight: tabBarHeight)
            }
        }
    }
}

#Preview {
    ContentView()
}

struct LibraryView: View {
    var tabBarHeight: CGFloat
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 0)
                
                Button("Hide Tab Bar") {
                    hideTabBar.toggle()
                }
            }
            .padding()
            .navigationTitle("Library")
            .safeAreaPadding(.bottom, tabBarHeight)
        }
        .hideFloatingTabBar(hideTabBar)
    }
}
