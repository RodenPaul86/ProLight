//
//  ContentView.swift
//  ProLight
//
//  Created by Paul  on 5/28/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            Home()
                .tabItem {
                    Image(systemName: "power")
                    Text("Main")
                }
            
            Text("Map View")
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            Text("Fitness View")
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Fitness")
                }
            
            Text("Settings View")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
}
