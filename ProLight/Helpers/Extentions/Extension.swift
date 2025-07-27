//
//  TimeInterval.swift
//  ProLight
//
//  Created by Paul  on 7/24/25.
//

import Foundation
import SwiftUI

extension TimeInterval {
    var formattedPace: String {
        guard self.isFinite && self > 0 else { return "--:-- min/mi" }
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d min/mi", minutes, seconds)
    }
}

extension Double {
    func formattedCaloriesFromMeters() -> String {
        let miles = self / 1609.34
        let calories = miles * 100
        return String(format: "%.0f kcal", calories)
    }
}

extension TimeInterval {
    var formattedDuration: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
