//
//  ContentView.swift
//  ProLight
//
//  Created by Paul  on 5/28/25.
//

import SwiftUI

enum AppTab: String, CaseIterable, FloatingTabProtocol {
    case home = "Home"
    case map = "Map"
    case fitness = "Fitness"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .home: "house"
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
            case .home: Home(tabBarHeight: tabBarHeight)
            case .map: Text("Map")
            case .fitness: Text("Fitness")
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
