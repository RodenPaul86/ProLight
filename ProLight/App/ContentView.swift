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
        case .home: "flashlight.on.fill"
        case .map: "point.topleft.filled.down.to.point.bottomright.curvepath"
        case .fitness: "chart.line.uptrend.xyaxis"
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
            case .map: NightWalkMapView(tabBarHeight: tabBarHeight)
            case .fitness: UserActivityView()
            case .settings: SettingsView(tabBarHeight: tabBarHeight)
            }
        }
    }
}

#Preview {
    ContentView()
}
