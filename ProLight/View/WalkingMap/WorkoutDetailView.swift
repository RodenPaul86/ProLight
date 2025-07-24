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
    let workout: Workout
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Metrics Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f mi", workout.distance / 1609.34))
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(workout.duration.formattedDuration)
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Pace")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(paceFormatted())
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(workout.distance.formattedCaloriesFromMeters())
                        .font(.headline)
                }
            }
            .padding(.bottom, 8)
            
            // Map
            Map(position: $cameraPosition, interactionModes: [.pitch]) {
                // Polyline
                MapPolyline(coordinates: workout.route)
                    .stroke(.blue, lineWidth: 4)
                
                // Start & End markers
                if let start = workout.route.first {
                    Marker("Start", coordinate: start)
                        .tint(.green)
                }
                if let end = workout.route.last {
                    Marker("End", coordinate: end)
                        .tint(.red)
                }
            }
            .mapControls {
                MapPitchToggle()
            }
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                zoomToFitRoute()
            }
            
            // Date
            Text("Date: \(workout.date.formatted(date: .abbreviated, time: .shortened))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Workout Detail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    deleteWorkout()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    // MARK: - Zoom to fit route
    private func zoomToFitRoute() {
        guard !workout.route.isEmpty else { return }
        
        var minLat = workout.route.first!.latitude
        var maxLat = workout.route.first!.latitude
        var minLon = workout.route.first!.longitude
        var maxLon = workout.route.first!.longitude
        
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
        
        let region = MKCoordinateRegion(center: center, span: span)
        cameraPosition = .region(region)
    }
    
    // MARK: - Formatter Helpers
    private func paceFormatted() -> String {
        let distanceMiles = workout.distance / 1609.34
        guard distanceMiles > 0 else { return "--:-- min/mi" }
        
        let secondsPerMile = workout.movingTime / distanceMiles
        return secondsPerMile.formattedPace
    }
    
    private func deleteWorkout() {
        modelContext.delete(workout)
        try? modelContext.save()
        dismiss()
    }
}
