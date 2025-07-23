//
//  WorkoutSummaryView.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import SwiftUI
import MapKit

struct WorkoutSummaryView: View {
    let route: [CLLocationCoordinate2D]
    let duration: TimeInterval
    let distance: Double
    let onDone: () -> Void
    
    @State private var region: MKCoordinateRegion = .init()
    
    let initialPosition: MapCameraPosition = {
        let center = CLLocationCoordinate2D(latitude: 34.011_284, longitude: -116.166_860)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: center, span: span)
        return .region(region)
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Workout Summary")
                .font(.title2)
                .bold()
            
            Map(initialPosition: initialPosition)
                .onMapCameraChange(frequency: .continuous) { context in
                    region = context.region
                }
                .overlay(
                    MapPolylineOverlay(coordinates: route)
                )
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack {
                Label("Duration", systemImage: "clock")
                Spacer()
                Text(formattedTime)
            }
            
            HStack {
                Label("Distance", systemImage: "figure.walk")
                Spacer()
                Text(String(format: "%.2f km", distance / 1000))
            }
            
            Spacer()
            
            Button("Done") {
                onDone()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            if let first = route.first {
                region.center = first
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
        }
    }
    
    private var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "-"
    }
}
