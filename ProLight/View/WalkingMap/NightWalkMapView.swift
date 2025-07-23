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
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var flashlightOn: Bool = false
    @State private var startLocation: MarkedLocation?
    @State private var endLocation: MarkedLocation?
    @State private var isTracking: Bool = false
    
    @State private var showSummary: Bool = false
    @State private var walkStartTime: Date?
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var caloriesBurned: Double = 0
    
    @State private var finalDuration: TimeInterval = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            MapRouteOverlay(coordinates: locationManager.trackedRoute)
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Map(position: $cameraPosition, interactionModes: .all) {
                MapPolyline(coordinates: locationManager.trackedRoute)
                    .stroke(.blue, lineWidth: 4)
                
                UserAnnotation()
                if let start = startLocation {
                    Marker("Start", coordinate: start.coordinate)
                        .tint(.green)
                }
                
                if let end = endLocation {
                    Marker("End", coordinate: end.coordinate)
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
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("\(formatTime(elapsedTime))", systemImage: "clock")
                    Spacer()
                    Label(String(format: "%.2f mi", distanceInMiles), systemImage: "map")
                }
                
                HStack {
                    Label(String(format: "%.1f min/mi", paceInMinutesPerMile), systemImage: "speedometer")
                    Spacer()
                    Label(String(format: "%.0f cal", caloriesBurned), systemImage: "flame")
                }
            }
            .foregroundColor(.black)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    // Hide Tab Bar Button
                    Button(action: { hideTabBar.toggle() }) {
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    
                    // Start/Stop Button
                    Button(action: {
                        if isTracking {
                            if let location = locationManager.lastLocation {
                                endLocation = MarkedLocation(coordinate: location.coordinate)
                            }
                            locationManager.stopTracking()
                            HealthKitManager.shared.endWorkoutSession()
                            stopTimer()
                            if let start = walkStartTime {
                                finalDuration = Date().timeIntervalSince(start)
                            }
                            isTracking.toggle()
                            showSummary = true
                            
                            let allCoords = locationManager.trackedRoute
                            if let region = regionThatFitsAllCoordinates(allCoords) {
                                withAnimation {
                                    cameraPosition = .region(region)
                                }
                            }
                        } else {
                            if let location = locationManager.lastLocation {
                                startLocation = MarkedLocation(coordinate: location.coordinate)
                                endLocation = nil
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
                            walkStartTime = Date()
                            elapsedTime = 0
                            startTimer()
                            isTracking.toggle()
                        }
                    }) {
                        Label(isTracking ? "Stop" : "Start Walking", systemImage: isTracking ? "stop.circle.fill" : "figure.walk")
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isTracking ? .red : .green, in: .rect(cornerRadius: 15))
                    }
                    
                    // Location + Flashlight Buttons
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            if let location = locationManager.lastLocation {
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    )
                                )
                            }
                        }) {
                            if !isTracking {
                                Image(systemName: "location.fill")
                                    .font(.title2)
                                    .foregroundStyle(.black)
                                    .frame(width: 50, height: 50)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                        }
                        
                        Button(action: toggleFlashlight) {
                            Image(systemName: flashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundStyle(.black)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showSummary) {
            let distance = calculateDistance(from: locationManager.trackedRoute)
            let miles = distance * 0.000621371
            let pace = miles > 0 ? (finalDuration / 60) / miles : 0
            let calories = miles * 100
            
            WorkoutSummaryView(
                route: locationManager.trackedRoute,
                duration: finalDuration,
                distance: distance,
                pace: pace,
                calories: calories,
                startCoordinate: startLocation?.coordinate,
                endCoordinate: endLocation?.coordinate
            ) {
                let workout = Workout(
                    date: walkStartTime ?? Date(),
                    duration: finalDuration,
                    distance: distance,
                    route: locationManager.trackedRoute
                )
                saveWorkout()
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
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let start = walkStartTime {
                elapsedTime = Date().timeIntervalSince(start)
                caloriesBurned = estimateCalories(from: elapsedTime)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    var distanceInMiles: Double {
        calculateDistance(from: locationManager.trackedRoute) * 0.000621371
    }
    
    var paceInMinutesPerMile: Double {
        guard distanceInMiles > 0 else { return 0 }
        return (elapsedTime / 60) / distanceInMiles
    }
    
    func estimateCalories(from duration: TimeInterval) -> Double {
        // Simple estimation: ~100 calories per mile walked
        return distanceInMiles * 100
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval) ?? "00:00:00"
    }
    
    func saveWorkout() {
        let workout = Workout(
            date: walkStartTime ?? Date(),
            duration: Date().timeIntervalSince(walkStartTime ?? Date()),
            distance: calculateDistance(from: locationManager.trackedRoute),
            route: locationManager.trackedRoute
        )
        modelContext.insert(workout)
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
