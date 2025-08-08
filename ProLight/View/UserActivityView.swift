//
//  UserActivityView.swift
//  ProLight
//
//  Created by Paul  on 8/5/25.
//

import SwiftUI

struct UserActivityView: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        NavigationStack {
            ScrollView { // Added so content scrolls if needed
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(healthManager.activites.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                        ActivityCard(activity: item.value)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationTitle("Fitness Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    UserActivityView()
        .environmentObject(HealthManager())
}
