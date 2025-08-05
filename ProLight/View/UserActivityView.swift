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
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ForEach(healthManager.activites.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                    ActivityCard(activity: item.value)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    UserActivityView()
}
