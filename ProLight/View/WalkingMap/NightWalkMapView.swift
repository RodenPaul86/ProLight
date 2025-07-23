//
//  NightWalkMapView.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import SwiftUI
import MapKit
import CoreLocation
import AVFoundation

struct MarkedLocation: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: MarkedLocation, rhs: MarkedLocation) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

struct NightWalkMapView: View {
    var tabBarHeight: CGFloat
    @State private var hideTabBar: Bool = false
    
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var flashlightOn: Bool = false
    @State private var startLocation: MarkedLocation?
    @State private var endLocation: MarkedLocation?
    @State private var isTracking: Bool = false
    
    @State private var showSummary: Bool = false
    @State private var walkStartTime: Date?
    @StateObject var workoutStorage = WorkoutStorage()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapRouteOverlay(coordinates: locationManager.trackedRoute)
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Map(position: $cameraPosition, interactionModes: .all) {
                MapPolyline(coordinates: locationManager.trackedRoute)
                    .stroke(.blue, lineWidth: 4)
                
                UserAnnotation()
                if let start = startLocation {
                    Marker("Started", coordinate: start.coordinate)
                        .tint(.green)
                }
                
                if let end = endLocation {
                    Marker("Ended", coordinate: end.coordinate)
                        .tint(.red)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            .onAppear {
                locationManager.requestPermission()
                
                // Wait a moment to get location and then zoom
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let location = locationManager.lastLocation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            )
                        )
                    }
                }
            }
            .onReceive(locationManager.$lastLocation.compactMap { $0 }) { location in
                if isTracking {
                    updateCamera(to: location)
                }
            }
            
            // Expandable Sheet (Bottom Panel)
            HStack(spacing: 10) {
                
                Button(action: { hideTabBar.toggle() }) {
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.title2)
                        .foregroundStyle(Color("lightGreen"))
                        .padding()
                        .background(Color("darkGreen"), in: Circle())
                }
                
                /*
                 Button {
                 if let location = locationManager.lastLocation {
                 markedLocations.append(MarkedLocation(coordinate: location.coordinate))
                 }
                 } label: {
                 Label("Add", systemImage: "mappin")
                 .foregroundStyle(Color("lightGreen"))
                 .frame(maxWidth: .infinity)
                 .padding(.vertical, 12)
                 .background(Color("darkGreen"), in: .rect(cornerRadius: 15))
                 }
                 */
                
                Button(action: {
                    if isTracking {
                        // Stop
                        if let location = locationManager.lastLocation {
                            endLocation = MarkedLocation(coordinate: location.coordinate)
                        }
                        locationManager.stopTracking()
                        HealthKitManager.shared.endWorkoutSession()
                        isTracking.toggle()
                        showSummary = true
                        
                        // Center the map on the route
                        let allCoords = locationManager.trackedRoute
                        if let region = regionThatFitsAllCoordinates(allCoords) {
                            withAnimation {
                                cameraPosition = .region(region)
                            }
                        }
                    } else {
                        // Start
                        if let location = locationManager.lastLocation {
                            startLocation = MarkedLocation(coordinate: location.coordinate)
                            endLocation = nil // reset end location in case user restarts
                            
                            // Lock the camera to user's location
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                )
                            )
                        }
                        locationManager.startTracking()
                        walkStartTime = Date()
                        HealthKitManager.shared.startWorkoutSession()
                        isTracking.toggle()
                    }
                }) {
                    Label(isTracking ? "Stop" : "Start Walking", systemImage: isTracking ? "stop.circle.fill" : "figure.walk")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isTracking ? .red : .green, in: .rect(cornerRadius: 15))
                }
                
                Button(action: toggleFlashlight) {
                    Image(systemName: flashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.title2)
                        .foregroundStyle(Color("lightGreen"))
                        .padding()
                        .background(Color("darkGreen"), in: Circle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("darkGray"))
            .cornerRadius(20)
            .padding()
        }
        .sheet(isPresented: $showSummary) {
            WorkoutSummaryView(
                route: locationManager.trackedRoute,
                duration: Date().timeIntervalSince(walkStartTime ?? Date()),
                distance: calculateDistance(from: locationManager.trackedRoute)
            ) {
                let workout = Workout(
                    date: walkStartTime ?? Date(),
                    duration: Date().timeIntervalSince(walkStartTime ?? Date()),
                    distance: calculateDistance(from: locationManager.trackedRoute),
                    route: locationManager.trackedRoute
                )
                workoutStorage.addWorkout(workout)
                showSummary = false
            }
        }
        .safeAreaPadding(.bottom, hideTabBar ? 0 : tabBarHeight)
        .hideFloatingTabBar(hideTabBar)
    }
    
    private func toggleFlashlight() {
        flashlightOn.toggle()
        FlashlightHelper.setFlashlight(on: flashlightOn)
    }
    
    private func updateCamera(to location: CLLocation) {
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )
        }
    }
    
    func calculateDistance(from coordinates: [CLLocationCoordinate2D]) -> Double {
        guard coordinates.count > 1 else { return 0 }
        
        var distance: Double = 0
        for i in 1..<coordinates.count {
            let start = CLLocation(latitude: coordinates[i-1].latitude, longitude: coordinates[i-1].longitude)
            let end = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
            distance += start.distance(from: end)
        }
        return distance
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
            latitudeDelta: (maxLat - minLat) * 1.4,  // Add padding
            longitudeDelta: (maxLon - minLon) * 1.4
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
/*
 #Preview {
 NightWalkMapView(tabBarHeight: 0)
 }
 */

struct FlashlightHelper {
    static func setFlashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            try device.setTorchModeOn(level: 1.0)
            device.unlockForConfiguration()
        } catch {
            print("Flashlight could not be used.")
        }
    }
}
