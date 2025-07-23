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
        guard let location = locations.last else { return }
        lastLocation = location
        
        if isTrackingRoute {
            trackedRoute.append(location.coordinate)
        }
    }
}
