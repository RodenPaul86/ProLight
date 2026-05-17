//
//  WorkoutSummarySheet.swift
//  ProLight
//
//  Created by Paul  on 4/29/26.
//

import SwiftUI

struct WorkoutSummarySheet: View {
    let workout: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var isSaved: Bool = false
    @State private var saveError: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.mint)
                    .symbolRenderingMode(.hierarchical)
                Text("Workout Complete")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(workout.formattedTime)
                    .font(.system(size: 38, weight: .black, design: .monospaced))
                    .foregroundColor(.mint)
            }
            .padding(.top, 28)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                SummaryTile(icon: "map",             label: "Distance", value: workout.formattedDistance,           color: .cyan)
                SummaryTile(icon: "flame.fill",      label: "Calories", value: workout.formattedCalories + " kcal", color: .orange)
                SummaryTile(icon: "figure.run",      label: "Avg Pace", value: workout.formattedPace + "/mi",       color: .mint)
                SummaryTile(icon: "shoeprints.fill", label: "Steps",    value: "\(workout.steps)",                  color: .yellow)
            }
            .padding(.horizontal, 20)
            
            if saveError {
                Label("Could not save workout.", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
            
            Button { saveWorkout() } label: {
                if #available(iOS 26.0, *) {
                    HStack(spacing: 8) {
                        if isSaved {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        Text(isSaved ? "Saved!" : "Done")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.black)
                    .glassEffect(
                        .regular.interactive()
                        .tint(isSaved ? .green : .mint),
                        in: .capsule
                    )
                    .animation(.spring(response: 0.3), value: isSaved)
                } else {
                    HStack(spacing: 8) {
                        if isSaved {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        Text(isSaved ? "Saved!" : "Done")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(isSaved ? Color.green : Color.mint)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .animation(.spring(response: 0.3), value: isSaved)
                }
            }
            .disabled(isSaved)
            .padding(.horizontal, 20)
        }
    }
    
    private func saveWorkout() {
        let entry = Workout(
            date: .now,
            duration: TimeInterval(workout.elapsedSeconds),
            movingTime: TimeInterval(workout.elapsedSeconds),
            distance: workout.distanceMiles * 1609.34,
            route: workout.routeCoordinates,
            notes: "",
            pace: workout.pace,
            caloriesBurned: workout.caloriesBurned,
            steps: workout.steps
        )
        context.insert(entry)
        do {
            try context.save()
            isSaved = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { dismiss() }
        } catch {
            print("SwiftData save error: \(error)")
            saveError = true
        }
    }
}

private struct SummaryTile: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .symbolRenderingMode(.hierarchical)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .kerning(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
