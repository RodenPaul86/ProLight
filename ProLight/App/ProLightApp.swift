//
//  ProLightApp.swift
//  ProLight
//
//  Created by Paul  on 5/28/25.
//

import SwiftUI
import RevenueCat
import ConfidentialKit

@main
struct ProLightApp: App {
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "\(Secrets.$apiKey)")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
