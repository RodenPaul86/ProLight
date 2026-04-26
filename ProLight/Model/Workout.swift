//
//  Workout.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
class Workout {
    @Attribute(.unique) var id: UUID
    var date: Date
    var duration: TimeInterval
    var movingTime: TimeInterval
    var distance: Double
    var routeData: Data
    var notes: String
    
    // MARK: - New Stats
    var pace: Double          // minutes per mile
    var caloriesBurned: Double
    var steps: Int
    
    init(
        date: Date,
        duration: TimeInterval,
        movingTime: TimeInterval,
        distance: Double,
        route: [CLLocationCoordinate2D],
        notes: String,
        pace: Double = 0,
        caloriesBurned: Double = 0,
        steps: Int = 0
    ) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.movingTime = movingTime
        self.distance = distance
        self.routeData = (try? JSONEncoder().encode(route)) ?? Data()
        self.notes = notes
        self.pace = pace
        self.caloriesBurned = caloriesBurned
        self.steps = steps
    }
    
    // MARK: - Computed Route
    var route: [CLLocationCoordinate2D] {
        (try? JSONDecoder().decode([CLLocationCoordinate2D].self, from: routeData)) ?? []
    }
    
    // MARK: - Formatting Helpers
    var distanceMiles: Double { distance / 1609.34 }
    
    var formattedDistance: String { String(format: "%.2f mi", distanceMiles) }
    
    var formattedPace: String {
        guard pace > 0 && pace < 99 else { return "--'--\"" }
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\"", mins, secs)
    }
    
    var formattedCalories: String {
        caloriesBurned < 1000
        ? String(format: "%.0f kcal", caloriesBurned)
        : String(format: "%.1fk kcal", caloriesBurned / 1000)
    }
    
    var formattedSteps: String { "\(steps) steps" }
}

// MARK: - CLLocationCoordinate2D Codable
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let lat = try container.decode(CLLocationDegrees.self)
        let lon = try container.decode(CLLocationDegrees.self)
        self.init(latitude: lat, longitude: lon)
    }
}
