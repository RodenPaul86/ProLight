//
//  WorkoutDetailView.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import SwiftUI
import MapKit
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var textBody: String = ""
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showingShareSheet: Bool = false
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(icon: "map",              label: "Distance", value: workout.formattedDistance,  color: .cyan)
                    StatCard(icon: "timer",             label: "Duration", value: workout.duration.formattedDuration, color: .mint)
                    StatCard(icon: "figure.walk",       label: "Pace",     value: workout.formattedPace + "/mi", color: .mint)
                    StatCard(icon: "flame.fill",         label: "Calories", value: workout.formattedCalories, color: .orange)
                    StatCard(icon: "shoeprints.fill",    label: "Steps",    value: workout.formattedSteps,    color: .yellow)
                    StatCard(icon: "calendar",           label: "Date",     value: workout.date.formatted(date: .abbreviated, time: .omitted), color: .purple)
                }
                
                // MARK: - Map
                Map(position: $cameraPosition, interactionModes: []) {
                    MapPolyline(coordinates: workout.route)
                        .stroke(.blue, lineWidth: 4)
                    
                    if let start = workout.route.first {
                        Marker("Start", coordinate: start)
                            .tint(.green)
                    }
                    if let end = workout.route.last {
                        Marker("End", coordinate: end)
                            .tint(.red)
                    }
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onAppear {
                    zoomToFitRoute()
                    textBody = workout.notes
                }
                
                // MARK: - Notes
                VStack(spacing: 0) {
                    HStack {
                        Text("Note")
                            .font(.headline)
                        Spacer()
                    }
                    
                    TextField("Enter text here...", text: $textBody, axis: .vertical)
                        .padding(.vertical, 8)
                        .frame(minHeight: 200, alignment: .top)
                }
                .padding()
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle("Walking Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [workoutSummary])
        }
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete", systemImage: "trash") {
                        deleteWorkout()
                    }
                    .tint(.red)
                }
            } else {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", systemImage: "trash") {
                        deleteWorkout()
                    }
                    .tint(.red)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Share", systemImage: "square.and.arrow.up") {
                    showingShareSheet = true
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    saveNote()
                }
            }
        }
    }
    
    // MARK: - Share summary
    
    private var workoutSummary: String {
        var lines: [String] = []
        lines.append("🚶 Walking Workout")
        lines.append("📅 \(workout.date.formatted(date: .long, time: .omitted))")
        lines.append("")
        lines.append("📍 Distance:  \(workout.formattedDistance)")
        lines.append("⏱️ Duration:  \(workout.duration.formattedDuration)")
        lines.append("⚡️ Pace:      \(workout.formattedPace)/mi")
        lines.append("🔥 Calories:  \(workout.formattedCalories)")
        lines.append("👟 Steps:     \(workout.formattedSteps)")
        if !workout.notes.isEmpty {
            lines.append("")
            lines.append("📝 \(workout.notes)")
        }
        return lines.joined(separator: "\n")
    }
    
    // MARK: - Zoom to fit route
    
    private func zoomToFitRoute() {
        guard !workout.route.isEmpty else { return }
        
        var minLat = workout.route[0].latitude
        var maxLat = workout.route[0].latitude
        var minLon = workout.route[0].longitude
        var maxLon = workout.route[0].longitude
        
        for coord in workout.route {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
    
    // MARK: - Actions
    
    private func deleteWorkout() {
        modelContext.delete(workout)
        try? modelContext.save()
        dismiss()
    }
    
    private func saveNote() {
        workout.notes = textBody
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Stat Card

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .symbolRenderingMode(.hierarchical)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .multilineTextAlignment(.center)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .kerning(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
