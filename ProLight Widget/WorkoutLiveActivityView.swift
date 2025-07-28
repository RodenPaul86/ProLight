//
//  ProLight_WidgetLiveActivity.swift
//  ProLight Widget
//
//  Created by Paul  on 7/28/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedTime: TimeInterval
        var distance: Double // in meters
        var pace: Double // in min/km or min/mi
    }
    
    var workoutType: String // e.g., "Walk", "Run"
}

struct WorkoutLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            // Lock Screen / Banner
            WorkoutLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        metricView("Time", value: formatTime(context.state.elapsedTime), systemImage: "clock")
                        Spacer()
                        metricView("Distance", value: formatDistance(context.state.distance), systemImage: "map")
                        Spacer()
                        metricView("Pace", value: formatPace(context.state.pace), systemImage: "speedometer")
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Image(systemName: "figure.walk")
            } compactTrailing: {
                Text(formatShortTime(context.state.elapsedTime))
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "figure.walk.circle")
            }
        }
    }
}

// MARK: - Shared View

struct WorkoutLiveActivityView: View {
    let context: ActivityViewContext<WorkoutAttributes>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(context.attributes.workoutType) in Progress")
                .font(.headline)
            HStack {
                metricView("Time", value: formatTime(context.state.elapsedTime), systemImage: "clock")
                Spacer()
                metricView("Distance", value: formatDistance(context.state.distance), systemImage: "map")
                Spacer()
                metricView("Pace", value: formatPace(context.state.pace), systemImage: "speedometer")
            }
            .font(.subheadline)
        }
        .padding()
    }
}

// MARK: - Utility Views

func metricView(_ title: String, value: String, systemImage: String) -> some View {
    VStack {
        Label(value, systemImage: systemImage)
            .labelStyle(.iconOnly)
        Text(value)
            .font(.caption)
    }
}

func formatTime(_ interval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: interval) ?? "0:00"
}

func formatShortTime(_ interval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute]
    formatter.unitsStyle = .short
    return formatter.string(from: interval) ?? "0m"
}

func formatDistance(_ meters: Double) -> String {
    let miles = meters / 1609.34
    return String(format: "%.2f mi", miles)
}

func formatPace(_ pace: Double) -> String {
    if pace.isNaN || pace.isInfinite { return "--" }
    return String(format: "%.1f min/km", pace)
}
