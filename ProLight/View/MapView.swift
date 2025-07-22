//
//  MapView.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default SF
                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    )
    
    @State private var flashlightOn = false
    @State private var showSheet = false
    @State private var markedLocations: [CLLocationCoordinate2D] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition, interactionModes: .all, showsUserLocation: true, annotationItems: markedLocations, annotationContent: { coord in
                MapMarker(coordinate: coord, tint: .green)
            })
            .mapStyle(.standard(elevation: .realistic)) // .mutedStandard also works well in dark mode
            .ignoresSafeArea()
            .onAppear {
                locationManager.requestPermission()
                if let location = locationManager.lastLocation {
                    updateCamera(to: location)
                }
            }

            // Flashlight Toggle Button
            HStack {
                Spacer()
                Button(action: toggleFlashlight) {
                    Image(systemName: flashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.title)
                        .padding()
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Expandable Sheet
            VStack(spacing: 12) {
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 6)
                    .padding(.top, 8)

                Button(action: {
                    if let location = locationManager.lastLocation {
                        markedLocations.append(location.coordinate)
                    }
                }) {
                    Label("Mark This Spot", systemImage: "mappin")
                }

                Button(action: {
                    print("Start tracking walk (implement HealthKit here)")
                }) {
                    Label("Start Night Walk", systemImage: "figure.walk")
                }

                Button(action: {
                    print("Share location (optional feature)")
                }) {
                    Label("Share My Location", systemImage: "location")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.bottom)
        }
    }

    func updateCamera(to location: CLLocation) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        )
    }

    func toggleFlashlight() {
        flashlightOn.toggle()
        //FlashlightHelper.setFlashlight(on: flashlightOn)
    }
}
