//
//  Workout.swift
//  ProLight
//
//  Created by Paul  on 7/22/25.
//

import Foundation
import CoreLocation

struct Workout: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let distance: Double
    let route: [CLLocationCoordinate2D]
    
    init(date: Date, duration: TimeInterval, distance: Double, route: [CLLocationCoordinate2D]) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.distance = distance
        self.route = route
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, duration, distance, route
    }
    
    struct CodableCoordinate: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    // Custom Encoding & Decoding for CLLocationCoordinate2D
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        distance = try container.decode(Double.self, forKey: .distance)
        
        let codableCoords = try container.decode([CodableCoordinate].self, forKey: .route)
        route = codableCoords.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(duration, forKey: .duration)
        try container.encode(distance, forKey: .distance)
        
        let codableCoords = route.map { CodableCoordinate(latitude: $0.latitude, longitude: $0.longitude) }
        try container.encode(codableCoords, forKey: .route)
    }
}
