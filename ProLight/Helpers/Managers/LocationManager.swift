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
import UserNotifications

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let weatherService = WeatherService.shared
    
    // MARK: - Published properties
    @Published var lastLocation: CLLocation?
    @Published var currentWeather: CurrentWeather?
    @Published var dailyForecast: Forecast<DayWeather>?
    @Published var hourlyForecast: Forecast<HourWeather>?
    @Published var weatherAlerts: [WeatherAlert] = []  // New property!
    @Published var cityName: String = ""
    @Published var stateName: String = ""
    @Published var countryCode: String = ""
    @Published var emergencyNumber: String?
    
    @Published var trackedRoute: [CLLocationCoordinate2D] = []
    @Published var currentLocation: CLLocation?
    
    @Published var movingTime: TimeInterval = 0
    @Published var totalDistanceInMeters: Double = 0
    
    private var previousLocation: CLLocation?
    private var previousTimestamp: Date?
    private let movementThreshold: CLLocationDistance = 5.0 // meters
    
    var isTrackingRoute = false
    
    // MARK: - Initialization
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.startUpdatingLocation()
    }
    
    // MARK: - Permissions & Location Tracking
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
    
    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        
        lastLocation = newLocation
        reverseGeocode(location: newLocation)
        saveForWidget(newLocation)
        WidgetCenter.shared.reloadAllTimelines()
        
        Task { await fetchWeather(for: newLocation) }
        
        if isTrackingRoute {
            updateMovement(with: newLocation)
        }
    }
    
    // MARK: - Weather & Alerts
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
    
    // MARK: - Movement Tracking
    private func updateMovement(with newLocation: CLLocation) {
        trackedRoute.append(newLocation.coordinate)
        
        if let previous = previousLocation, let previousTime = previousTimestamp {
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
    
    // MARK: - Geocoding & Emergency
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
                if let iso = placemark.isoCountryCode {
                    self.countryCode = iso
                    self.emergencyNumber = self.lookupEmergencyNumber(for: iso)
                }
            }
        }
    }
    
    private func lookupEmergencyNumber(for countryCode: String) -> String {
        [
            "US": "911", "CA": "911", "GB": "999", "AU": "000", "NZ": "111",
            "FR": "112", "DE": "112", "EU": "112", "MX": "911", "BR": "190",
            "JP": "110", "CN": "110", "IN": "112", "ZA": "10111", "RU": "112",
            "SG": "999", "MY": "999", "HK": "999", "KR": "112", "TW": "110",
            "SA": "999", "AE": "999", "IL": "100", "EG": "122"
        ][countryCode] ?? "112"
    }
    
    // MARK: - Widget Sharing
    private func saveForWidget(_ location: CLLocation) {
        let defaults = UserDefaults(suiteName: "group.app.prolight.widget")
        defaults?.set(location.coordinate.latitude, forKey: "widget_latitude")
        defaults?.set(location.coordinate.longitude, forKey: "widget_longitude")
    }
}

