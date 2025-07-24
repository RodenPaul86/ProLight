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
    
    init(date: Date, duration: TimeInterval, movingTime: TimeInterval, distance: Double, route: [CLLocationCoordinate2D], notes: String) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.movingTime = movingTime
        self.distance = distance
        self.routeData = try! JSONEncoder().encode(route)
        self.notes = notes
    }
    
    var route: [CLLocationCoordinate2D] {
        (try? JSONDecoder().decode([CLLocationCoordinate2D].self, from: routeData)) ?? []
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let latitude = try container.decode(CLLocationDegrees.self)
        let longitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
