//
//  WorkoutHistoryView.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Group {
            if workouts.isEmpty {
                VStack {
                    /*
                    lottieView(name: "")
                        .frame(width: 120, height: 120)
                        .clipped()
                     */
                    
                    Text("No Walks Recorded yet")
                        .font(.title3.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Start a new walk to see it here.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else {
                List {
                    ForEach(workouts) { workout in
                        NavigationLink {
                            WorkoutDetailView(workout: workout)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.headline)
                                Text("Distance: \(String(format: "%.2f mi", workout.distance / 1609.34)) • Time: \(formattedTime(workout.duration))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkouts) // ← Add this
                }
            }
        }
        .navigationTitle("Past Workouts")
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            let workout = workouts[index]
            context.delete(workout) // ← Remove from model context
        }
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? "-"
    }
}
