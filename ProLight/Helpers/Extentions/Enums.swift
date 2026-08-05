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

enum LightStates: String, CaseIterable, Identifiable {
    case on = "On"
    case off = "Off"
    case previous = "Previous"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .on: return "Light On"
        case .off: return "Light Off"
        case .previous: return "Previous State"
        }
    }
}
