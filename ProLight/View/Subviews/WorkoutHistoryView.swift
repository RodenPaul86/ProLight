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
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        Group {
            if workouts.isEmpty {
                VStack {
                    lottieView(name: "Traveler")
                        .frame(width: 120, height: 120)
                        .clipped()
                    
                    Text("No Walks Recorded yet")
                        .font(.title3.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Start a new walk to see it here.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
            } else {
                List {
                    ForEach(workouts) { workout in
                        NavigationLink {
                            WorkoutDetailView(workout: workout)
                        } label: {
                            WorkoutRowView(workout: workout)
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            }
        }
        .onAppear { hideTabBar = true }
        .navigationTitle("Walking History")
        .navigationBarTitleDisplayMode(.inline)
        .hideFloatingTabBar(hideTabBar)
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            context.delete(workouts[index])
        }
    }
}

// MARK: - Row View

private struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // Date headline
            Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
            
            // Distance + Duration
            HStack(spacing: 4) {
                Image(systemName: "map")
                    .foregroundColor(.cyan)
                Text(workout.formattedDistance)
                
                Text("•").foregroundColor(.secondary)
                
                Image(systemName: "timer")
                    .foregroundColor(.mint)
                Text(formattedTime(workout.duration))
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            // Pace · Calories · Steps
            HStack(spacing: 12) {
                StatBadge(icon: "figure.walk",      value: workout.formattedPace,     color: .mint)
                StatBadge(icon: "flame.fill",        value: workout.formattedCalories, color: .orange)
                StatBadge(icon: "shoeprints.fill",   value: workout.formattedSteps,    color: .yellow)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? "-"
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}
