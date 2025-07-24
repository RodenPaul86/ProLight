//
//  LocationManager.swift
//  ProLight
//
//  Created by Paul  on 7/19/25.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var lastLocation: CLLocation?
    @Published var trackedRoute: [CLLocationCoordinate2D] = []
    
    @Published var movingTime: TimeInterval = 0
    @Published var totalDistanceInMeters: Double = 0
    
    private var previousLocation: CLLocation?
    private var previousTimestamp: Date?
    private let movementThreshold: CLLocationDistance = 5.0 // meters
    
    var isTrackingRoute = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func startTracking() {
        isTrackingRoute = true
        trackedRoute = []
    }
    
    func stopTracking() {
        isTrackingRoute = false
    }
    
    func reset() {
        trackedRoute.removeAll()
        lastLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        
        lastLocation = newLocation
        
        if isTrackingRoute {
            trackedRoute.append(newLocation.coordinate)
            
            if let previous = previousLocation,
               let previousTime = previousTimestamp {
                
                let distance = newLocation.distance(from: previous)
                let timeDelta = newLocation.timestamp.timeIntervalSince(previousTime)
                
                // Only count time and distance if user moved significantly
                if distance >= movementThreshold {
                    totalDistanceInMeters += distance
                    movingTime += timeDelta
                }
            }
            
            previousLocation = newLocation
            previousTimestamp = newLocation.timestamp
        }
    }
}
