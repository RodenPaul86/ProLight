//
//  WeatherManager.swift
//  ProLight
//
//  Created by Paul  on 8/11/25.
//

import Foundation
import WeatherKit
import CoreLocation

class WeatherManager {
    static let shared = WeatherManager()
    let service = WeatherService.shared
    
    func currentWeather(for location: CLLocation) async -> CurrentWeather? {
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(for: location, including: .current)
            return forecast
        }.value
        return currentWeather
    }
    
    func weatherAttribution() async -> WeatherAttribution? {
        let attribution = await Task(priority: .userInitiated) {
            return try? await self.service.attribution
        }.value
        return attribution
    }
    
    func fetchWeatherAlerts(for location: CLLocation) async throws -> [WeatherAlert] {
        let weather = try await service.weather(for: location, including: .alerts)
        return weather ?? []
    }
}
