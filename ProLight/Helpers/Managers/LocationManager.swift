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
    
    // MARK: - Location & Geocoding
    @Published var lastLocation: CLLocation?
    @Published var currentLocation: CLLocation?
    @Published var cityName: String = ""
    @Published var stateName: String = ""
    @Published var countryCode: String = ""
    @Published var emergencyNumber: String?
    
    // MARK: - Weather
    @Published var currentWeather: CurrentWeather?
    @Published var dailyForecast: Forecast<DayWeather>?
    @Published var hourlyForecast: Forecast<HourWeather>?
    @Published var weatherAlerts: [WeatherAlert] = []
    
    // MARK: - Workout / Route Tracking
    @Published var trackedRoute: [CLLocationCoordinate2D] = []
    @Published var isTrackingRoute: Bool = false
    
    // Distance & time (raw values for your own use)
    @Published var totalDistanceInMeters: Double = 0
    @Published var movingTime: TimeInterval = 0
    
    // Workout stats (formatted / derived)
    @Published var elapsedSeconds: Int = 0
    @Published var pace: Double = 0          // min/mile
    @Published var caloriesBurned: Double = 0
    @Published var steps: Int = 0
    @Published var isPaused: Bool = false
    
    // MARK: - Workout Config (override before starting)
    /// Body weight used for calorie calculation. Wire to HealthKit for a real value.
    var weightKg: Double = 70.0
    /// MET value: ~9.8 running, ~3.8 walking. Swap as needed.
    var activityMET: Double = 9.8
    
    // MARK: - Private
    private var previousLocation: CLLocation?
    private var previousTimestamp: Date?
    private let movementThreshold: CLLocationDistance = 5.0
    private var workoutTimer: Timer?
    
    // MARK: - Computed Formatting
    
    var distanceMiles: Double { totalDistanceInMeters / 1609.34 }
    
    var formattedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return h > 0
        ? String(format: "%d:%02d:%02d", h, m, s)
        : String(format: "%02d:%02d", m, s)
    }
    
    var formattedPace: String {
        guard pace > 0 && pace < 99 else { return "--'--\"" }
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\"", mins, secs)
    }
    
    var formattedDistance: String { String(format: "%.2f mi", distanceMiles) }
    
    var formattedCalories: String {
        caloriesBurned < 1000
        ? String(format: "%.0f", caloriesBurned)
        : String(format: "%.1fk", caloriesBurned / 1000)
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.startUpdatingLocation()
    }
    
    // MARK: - Permissions
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // MARK: - Workout Controls
    
    /// Starts a fresh workout session and begins route tracking.
    func startTracking() {
        resetWorkout()
        isTrackingRoute = true
        isPaused = false
        manager.startUpdatingLocation()
        startWorkoutTimer()
    }
    
    /// Pauses the timer and stops location updates without clearing data.
    func pauseTracking() {
        guard isTrackingRoute && !isPaused else { return }
        isPaused = true
        workoutTimer?.invalidate()
        manager.stopUpdatingLocation()
    }
    
    /// Resumes a paused session.
    func resumeTracking() {
        guard isTrackingRoute && isPaused else { return }
        isPaused = false
        manager.startUpdatingLocation()
        startWorkoutTimer()
    }
    
    /// Stops the session entirely. Stats remain readable for a summary view.
    func stopTracking() {
        isTrackingRoute = false
        isPaused = false
        workoutTimer?.invalidate()
        workoutTimer = nil
        // Keep location updates running for weather/geocoding
        manager.startUpdatingLocation()
    }
    
    /// Clears all workout data back to zero.
    func reset() {
        resetWorkout()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let newLocation = locations.last,
              newLocation.horizontalAccuracy >= 0 else { return }
        
        Task { @MainActor in
            lastLocation = newLocation
            currentLocation = newLocation
            reverseGeocode(location: newLocation)
            saveForWidget(newLocation)
            WidgetCenter.shared.reloadAllTimelines()
            await fetchWeather(for: newLocation)
            
            if isTrackingRoute && !isPaused {
                updateMovement(with: newLocation)
            }
        }
    }
    
    // MARK: - Private: Timer
    
    private func startWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.elapsedSeconds += 1
                // Refresh calorie estimate every second
                let hours = Double(self.elapsedSeconds) / 3600.0
                self.caloriesBurned = self.activityMET * self.weightKg * hours
            }
        }
    }
    
    // MARK: - Private: Movement
    
    private func updateMovement(with newLocation: CLLocation) {
        trackedRoute.append(newLocation.coordinate)
        
        if let previous = previousLocation, let previousTime = previousTimestamp {
            let distance = newLocation.distance(from: previous)
            let timeDelta = newLocation.timestamp.timeIntervalSince(previousTime)
            
            if distance >= movementThreshold {
                totalDistanceInMeters += distance
                movingTime += timeDelta
                
                // Steps: ~2,112 per mile
                steps = Int(distanceMiles * 2112)
                
                // Pace: elapsed minutes ÷ miles
                if distanceMiles > 0 {
                    pace = (Double(elapsedSeconds) / 60.0) / distanceMiles
                }
            }
        }
        
        previousLocation = newLocation
        previousTimestamp = newLocation.timestamp
    }
    
    private func resetWorkout() {
        trackedRoute.removeAll()
        previousLocation = nil
        previousTimestamp = nil
        totalDistanceInMeters = 0
        movingTime = 0
        elapsedSeconds = 0
        pace = 0
        caloriesBurned = 0
        steps = 0
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    // MARK: - Private: Weather
    
    private func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            currentWeather = weather.currentWeather
            dailyForecast = weather.dailyForecast
            hourlyForecast = weather.hourlyForecast
        } catch {
            print("WeatherKit error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private: Geocoding
    
    private func reverseGeocode(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            guard let self, let placemark = placemarks?.first else { return }
            Task { @MainActor in
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
            "US": "911",  "CA": "911",   "GB": "999", "AU": "000", "NZ": "111",
            "FR": "112",  "DE": "112",   "EU": "112", "MX": "911", "BR": "190",
            "JP": "110",  "CN": "110",   "IN": "112", "ZA": "10111","RU": "112",
            "SG": "999",  "MY": "999",   "HK": "999", "KR": "112", "TW": "110",
            "SA": "999",  "AE": "999",   "IL": "100", "EG": "122"
        ][countryCode] ?? "112"
    }
    
    // MARK: - Private: Widget
    
    private func saveForWidget(_ location: CLLocation) {
        let defaults = UserDefaults(suiteName: "group.app.prolight.widget")
        defaults?.set(location.coordinate.latitude,  forKey: "widget_latitude")
        defaults?.set(location.coordinate.longitude, forKey: "widget_longitude")
    }
}
