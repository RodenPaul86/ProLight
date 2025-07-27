//
//  LocationManager.swift
//  ProLight
//
//  Created by Paul  on 7/19/25.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI
import WeatherKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var lastLocation: CLLocation?
    @Published var currentWeather: CurrentWeather?
    @Published var cityName: String = "Loading..."
    
    @Published var trackedRoute: [CLLocationCoordinate2D] = []
    @Published var currentLocation: CLLocation?
    
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
        manager.startUpdatingLocation()
        manager.distanceFilter = kCLDistanceFilterNone
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
        previousLocation = nil
        previousTimestamp = nil
        totalDistanceInMeters = 0
        movingTime = 0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        
        lastLocation = newLocation
        reverseGeocode(location: newLocation)
        
        // ✅ Fetch weather once, or update when significant change occurs
        Task {
            await fetchWeather(for: newLocation)
        }
        
        if isTrackingRoute {
            trackedRoute.append(newLocation.coordinate)
            
            if let previous = previousLocation,
               let previousTime = previousTimestamp {
                
                let distance = newLocation.distance(from: previous)
                let timeDelta = newLocation.timestamp.timeIntervalSince(previousTime)
                
                if distance >= movementThreshold {
                    totalDistanceInMeters += distance
                    movingTime += timeDelta
                }
            }
            
            previousLocation = newLocation
            previousTimestamp = newLocation.timestamp
        }
    }
    
    private func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            DispatchQueue.main.async {
                self.currentWeather = weather.currentWeather
            }
        } catch {
            print("WeatherKit error: \(error.localizedDescription)")
        }
    }
}

extension LocationManager {
    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
            } else if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.cityName = placemark.locality ?? "Unknown"
                }
            }
        }
    }
}
