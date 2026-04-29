//
//  WorkoutManager.swift
//  ProLight
//
//  Created by Paul  on 4/29/26.
//

import SwiftUI
import CoreLocation

class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: Location
    private let locationManager = CLLocationManager()
    
    // MARK: Workout State
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    // MARK: Stats
    @Published var elapsedSeconds: Int = 0
    @Published var distanceMiles: Double = 0
    @Published var caloriesBurned: Double = 0
    @Published var steps: Int = 0
    @Published var pace: Double = 0 /// <-- min/mile
    
    private var timer: Timer?
    private var lastLocation: CLLocation?
    private let metValue: Double = 9.8
    private let weightKg: Double = 70.0
    
    // MARK: Formatted Helpers
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
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: Controls
    
    func start() {
        reset()
        isActive = true
        isPaused = false
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    func pause() {
        isPaused = true
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func resume() {
        isPaused = false
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    func stop() {
        isActive = false
        isPaused = false
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    private func reset() {
        routeCoordinates.removeAll()
        lastLocation = nil
        elapsedSeconds = 0
        distanceMiles = 0
        caloriesBurned = 0
        steps = 0
        pace = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 1
            let hours = Double(self.elapsedSeconds) / 3600
            self.caloriesBurned = self.metValue * self.weightKg * hours
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isActive, !isPaused, let loc = locations.last else { return }
        routeCoordinates.append(loc.coordinate)
        if let last = lastLocation {
            let deltaMiles = loc.distance(from: last) / 1609.34
            distanceMiles += deltaMiles
            steps = Int(distanceMiles * 2112)
            if distanceMiles > 0 {
                pace = (Double(elapsedSeconds) / 60.0) / distanceMiles
            }
        }
        lastLocation = loc
    }
}
