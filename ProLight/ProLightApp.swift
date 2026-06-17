//
//  ProLightApp.swift
//  ProLight
//
//  Created by Paul  on 5/28/25.
//

import SwiftUI
import RevenueCat
import ConfidentialKit
import SwiftData

@main
struct ProLightApp: App {
    @StateObject var appSubModel = appSubscriptionModel()
    @StateObject var healthManager = HealthManager()
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "\(Secrets.$apiKey)")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(appSubModel)
                .environmentObject(healthManager)
                .task {
                    appSubModel.refreshSubscriptionStatus()
                }
        }
        .modelContainer(for: Workout.self) /// <-- registers Workout as a SwiftData model
    }
}
