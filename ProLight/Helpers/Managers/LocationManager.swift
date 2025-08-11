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
import WidgetKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var lastLocation: CLLocation?
    @Published var currentWeather: CurrentWeather?
    @Published var dailyForecast: Forecast<DayWeather>?
    @Published var hourlyForecast: Forecast<HourWeather>?
    @Published var cityName: String = ""
    @Published var stateName: String = ""
    
    @Published var trackedRoute: [CLLocationCoordinate2D] = []
    @Published var currentLocation: CLLocation?
    
    @Published var movingTime: TimeInterval = 0
    @Published var totalDistanceInMeters: Double = 0
    
    @Published var emergencyNumber: String?
    @Published var countryCode: String = ""
    
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
        manager.requestLocation()
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
        
        saveForWidget(newLocation)
        WidgetCenter.shared.reloadAllTimelines()
        
        // Fetch weather once, or update when significant change occurs
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
                self.dailyForecast = weather.dailyForecast
                self.hourlyForecast = weather.hourlyForecast
            }
        } catch {
            print("WeatherKit error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Share location with widget
    func saveForWidget(_ location: CLLocation) {
        let defaults = UserDefaults(suiteName: "group.app.prolight.widget")
        defaults?.set(location.coordinate.latitude, forKey: "widget_latitude")
        defaults?.set(location.coordinate.longitude, forKey: "widget_longitude")
        
        //print("Saved lat/lon:", location.coordinate)
    }
}

extension LocationManager {
    private func lookupEmergencyNumber(for countryCode: String) -> String {
        let emergencyNumbers: [String: String] = [
            "US": "911",    // United States
            "CA": "911",    // Canada
            "GB": "999",    // United Kingdom
            "AU": "000",    // Australia
            "NZ": "111",    // New Zealand
            "FR": "112",    // France
            "DE": "112",    // Germany
            "EU": "112",    // European Union
            "MX": "911",    // Mexico
            "BR": "190",    // Brazil (police; 192 for ambulance, 193 for fire)
            "JP": "110",    // Japan (police; 119 for ambulance/fire)
            "CN": "110",    // China (police; 120 for ambulance, 119 for fire)
            "IN": "112",    // India
            "ZA": "10111",  // South Africa (police; 10177 for ambulance)
            "RU": "112",    // Russia
            "SG": "999",    // Singapore
            "MY": "999",    // Malaysia
            "HK": "999",    // Hong Kong
            "KR": "112",    // South Korea (police; 119 ambulance/fire)
            "TW": "110",    // Taiwan (police; 119 ambulance/fire)
            "SA": "999",    // Saudi Arabia
            "AE": "999",    // United Arab Emirates
            "IL": "100",    // Israel (police; 101 ambulance, 102 fire)
            "EG": "122",    // Egypt (police; 123 ambulance)
        ]
        return emergencyNumbers[countryCode] ?? "112" // default to 112
    }
    
    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                self.cityName = placemark.locality ?? ""
                self.stateName = placemark.administrativeArea ?? ""
                
                if let countryCode = placemark.isoCountryCode {
                    self.countryCode = countryCode
                    self.emergencyNumber = self.lookupEmergencyNumber(for: countryCode)
                }
            }
        }
    }
}

