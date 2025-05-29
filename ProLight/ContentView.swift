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
                    Image(systemName: "house")
                    Text("Home")
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
