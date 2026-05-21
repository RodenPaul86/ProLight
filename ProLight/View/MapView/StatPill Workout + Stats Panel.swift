//
//  StatPill.swift
//  ProLight
//
//  Created by Paul  on 4/29/26.
//

import SwiftUI

// MARK: - StatPill

struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    var accent: Color = .green
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(accent)
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .kerning(0.8)
            }
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(accent.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - Workout Stats Panel

struct WorkoutStatsPanel: View {
    @ObservedObject var workout: WorkoutManager
    
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
    
    var body: some View {
        if #available(iOS 26.0, *) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.mint)
                    Text(workout.formattedTime)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(Color.mint.opacity(0.3), lineWidth: 1))
                )
                
                LazyVGrid(columns: columns, spacing: 8) {
                    StatPill(icon: "figure.run",     label: "Pace",     value: workout.formattedPace,               accent: .mint)
                    StatPill(icon: "map",             label: "Distance", value: workout.formattedDistance,           accent: .cyan)
                    StatPill(icon: "flame.fill",      label: "Calories", value: workout.formattedCalories + " kcal", accent: .orange)
                    StatPill(icon: "shoeprints.fill", label: "Steps",    value: "\(workout.steps)",                  accent: .yellow)
                }
            }
            .padding(11)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 0.5)
            )
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.mint)
                    Text(workout.formattedTime)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(Color.mint.opacity(0.3), lineWidth: 1))
                )
                
                LazyVGrid(columns: columns, spacing: 8) {
                    StatPill(icon: "figure.run",     label: "Pace",     value: workout.formattedPace,               accent: .mint)
                    StatPill(icon: "map",             label: "Distance", value: workout.formattedDistance,           accent: .cyan)
                    StatPill(icon: "flame.fill",      label: "Calories", value: workout.formattedCalories + " kcal", accent: .orange)
                    StatPill(icon: "shoeprints.fill", label: "Steps",    value: "\(workout.steps)",                  accent: .yellow)
                }
            }
            .padding(11)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.black.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}
