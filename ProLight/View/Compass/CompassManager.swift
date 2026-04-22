//
//  CompassManager.swift
//  ProLight
//
//  Created by Paul  on 4/22/26.
//

import Foundation
import CoreLocation
import CoreMotion
import SwiftUI

class CompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0
    @Published var direction: String = "N"
    @Published var altitude: Double = 0
    @Published var coordinate: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
        direction = Self.cardinalDirection(for: heading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
        altitude = locations.last?.altitude ?? 0
    }
    
    static func cardinalDirection(for degrees: Double) -> String {
        let dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return dirs[Int((degrees + 22.5) / 45) % 8]
    }
}
