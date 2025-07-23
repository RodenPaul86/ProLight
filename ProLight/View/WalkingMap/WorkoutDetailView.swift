//
//  WorkoutDetailView.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import SwiftUI
import MapKit

struct WorkoutDetailView: View {
    let workout: Workout
    
    @State private var region: MKCoordinateRegion = .init()
    
    let initialPosition: MapCameraPosition = {
        let center = CLLocationCoordinate2D(latitude: 34.011_284, longitude: -116.166_860)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: center, span: span)
        return .region(region)
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Route Map")
                .font(.headline)
            
            Map(initialPosition: initialPosition)
                .onMapCameraChange(frequency: .continuous) { context in
                    region = context.region
                }
                .overlay(
                    MapPolylineOverlay(coordinates: workout.route)
                )
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
            /*
            Map(coordinateRegion: $region, interactionModes: [], annotationItems: workout.route) { coord in
                MapMarker(coordinate: coord, tint: .blue)
            }
            .overlay(
                MapPolylineOverlay(coordinates: workout.route)
            )
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 10))
             */
            
            Text("Date: \(workout.date.formatted(date: .abbreviated, time: .shortened))")
            Text("Distance: \(String(format: "%.2f km", workout.distance / 1000))")
            Text("Duration: \(formattedTime(workout.duration))")
            
            Spacer()
        }
        .padding()
        .navigationTitle("Workout Detail")
        .onAppear {
            if let first = workout.route.first {
                region.center = first
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
        }
    }
    
    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? "-"
    }
}
