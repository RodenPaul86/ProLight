//
//  Enums.swift
//  ProLight
//
//  Created by Paul  on 7/27/25.
//

import SwiftUI

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case fahrenheit = "°F"
    case celsius = "°C"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .fahrenheit: return "Fahrenheit (°F)"
        case .celsius: return "Celsius (°C)"
        }
    }
}

enum DateRangeOption: String, CaseIterable, Identifiable {
    case day = "Today"
    case week = "This Week"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .day: return "Start Of Day"
        case .week: return "Start Of Week"
        }
    }
}
