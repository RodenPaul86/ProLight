//
//  UserActivityView.swift
//  ProLight
//
//  Created by Paul  on 8/5/25.
//

import SwiftUI

struct UserActivityView: View {
    @EnvironmentObject var healthManager: HealthManager
    @State private var activitiesArray: [cardElements] = []
    @State private var draggingItem: cardElements?
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(activitiesArray) { activity in
                        ActivityCard(activity: activity)
                            .onDrag {
                                draggingItem = activity
                                return NSItemProvider(object: String(activity.id) as NSString)
                            }
                            .onDrop(of: [.text],
                                    delegate: DropViewDelegate(
                                        item: activity,
                                        activities: $activitiesArray,
                                        draggingItem: $draggingItem,
                                        onReorder: {
                                            saveOrder()
                                        }))
                    }
                }
                .padding()
            }
            .navigationTitle("Fitness Stats")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadArrayFromDict()
            }
        }
    }
    
    // MARK: - Save to UserDefaults + Sync back to dictionary
    private func saveOrder() {
        // Save key order to UserDefaults
        var newKeyOrder: [String] = []
        var newDict: [String: cardElements] = [:]
        
        for element in activitiesArray {
            if let key = healthManager.activities.first(where: { $0.value.id == element.id })?.key {
                newKeyOrder.append(key)
                newDict[key] = element
            }
        }
        healthManager.activities = newDict
        UserDefaults.standard.set(newKeyOrder, forKey: "activityKeyOrder")
    }
    
    // MARK: - Load from dictionary
    private func loadArrayFromDict() {
        let dict = healthManager.activities
        if let keyOrder = UserDefaults.standard.array(forKey: "activityKeyOrder") as? [String] {
            activitiesArray = keyOrder.compactMap { dict[$0] }
        } else {
            activitiesArray = dict.sorted(by: { $0.value.id < $1.value.id }).map { $0.value }
        }
    }
}

#Preview {
    UserActivityView()
        .environmentObject(HealthManager())
}
