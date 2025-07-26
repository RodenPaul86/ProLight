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
    let pace: Double
    let calories: Double
    let startCoordinate: CLLocationCoordinate2D?
    let endCoordinate: CLLocationCoordinate2D?
    let onDone: () -> Void
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Walking Summary")
                .font(.title2.bold())
            
            Map(position: $cameraPosition, interactionModes: [.pitch]) {
                if let start = startCoordinate {
                    Marker("Start", coordinate: start)
                        .tint(.green)
                }
                
                if let end = endCoordinate {
                    Marker("End", coordinate: end)
                        .tint(.red)
                }
                
                MapPolyline(coordinates: route)
                    .stroke(.blue, lineWidth: 4)
            }
            .mapControls {
                MapPitchToggle()
            }
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
                Text(String(format: "%.2f mi", distance * 0.000621371))
            }
            
            HStack {
                Label("Pace", systemImage: "speedometer")
                Spacer()
                Text(formattedPace(pace))
            }
            
            HStack {
                Label("Calories", systemImage: "flame")
                Spacer()
                Text(String(format: "%.0f Kcal", calories))
            }
            Spacer()
        }
        .padding()
        .overlay (
            HStack {
                Button(action: { onDone() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
            }
                .padding(.leading)
                .padding(.top, 10),
            alignment: .topLeading
        )
        .onAppear {
            let allCoordinates = route + [startCoordinate, endCoordinate].compactMap { $0 }
            if let region = regionThatFitsAllCoordinates(allCoordinates) {
                cameraPosition = .region(region)
            }
        }
    }
    
    private var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "-"
    }
    
    func formattedPace(_ pace: Double) -> String {
        guard pace > 0, pace.isFinite else { return "--:-- min/mi" }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d min/mi", minutes, seconds)
    }
    
    func regionThatFitsAllCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }

        var minLat = coordinates.first!.latitude
        var maxLat = coordinates.first!.latitude
        var minLon = coordinates.first!.longitude
        var maxLon = coordinates.first!.longitude

        for coord in coordinates {
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

        return MKCoordinateRegion(center: center, span: span)
    }
}
