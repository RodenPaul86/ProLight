//
//  WorkoutHistoryView.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @ObservedObject var storage: WorkoutStorage

    var body: some View {
        List {
            ForEach(storage.workouts) { workout in
                NavigationLink {
                    WorkoutDetailView(workout: workout)
                } label: {
                    VStack(alignment: .leading) {
                        Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        Text("Distance: \(String(format: "%.2f km", workout.distance / 1000)) • Time: \(formattedTime(workout.duration))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Past Workouts")
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? "-"
    }
}
