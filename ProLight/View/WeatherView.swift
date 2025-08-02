//
//  WeatherView.swift
//  ProLight
//
//  Created by Paul  on 7/29/25.
//

import SwiftUI
import WeatherKit

struct WeatherView: View {
    @StateObject private var locationManager = LocationManager()
    @AppStorage("useFahrenheit") private var useFahrenheit: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    @State private var attributionLink: URL?
    @State private var attributionLogo: URL?
    
    var selectedUnit: TemperatureUnit {
        useFahrenheit ? .fahrenheit : .celsius
    }
    
    var body: some View {
        ZStack {
            Color("darkGray").ignoresSafeArea()
            
            if let weather = locationManager.currentWeather,
               let today = locationManager.dailyForecast?.forecast.first {
                
                let temp = selectedUnit == .fahrenheit
                ? weather.temperature.converted(to: .fahrenheit)
                : weather.temperature.converted(to: .celsius)
                
                let low = selectedUnit == .fahrenheit
                ? today.lowTemperature.converted(to: .fahrenheit)
                : today.lowTemperature.converted(to: .celsius)
                
                let high = selectedUnit == .fahrenheit
                ? today.highTemperature.converted(to: .fahrenheit)
                : today.highTemperature.converted(to: .celsius)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(locationManager.cityName)")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 12) {
                        // Big "Today" weather card
                        TodayWeatherCard(
                            temp: "\(Int(temp.value))°",
                            description: weather.condition.description.capitalized,
                            imageName: "\(weather.symbolName).fill",
                            low: "\(Int(low.value))°",
                            high: "\(Int(high.value))°"
                        )
                        
                        // Small daily cards (can be made dynamic too)
                        if let daily = locationManager.dailyForecast?.forecast.dropFirst().prefix(2) {
                            HStack(spacing: 8) {
                                ForEach(Array(daily.enumerated()), id: \.offset) { index, day in
                                    let high = selectedUnit == .fahrenheit
                                    ? day.highTemperature.converted(to: .fahrenheit)
                                    : day.highTemperature.converted(to: .celsius)
                                    
                                    let symbol = day.symbolName
                                    let weekday = Calendar.current.shortWeekdaySymbols[
                                        Calendar.current.component(.weekday, from: day.date) - 1
                                    ]
                                    
                                    DailyWeatherCard(
                                        day: weekday.uppercased(),
                                        temp: "\(Int(high.value))°",
                                        imageName: "\(symbol).fill"
                                    )
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 0) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                        
                        Text("Weather")
                            .font(.system(size: 17))
                            .foregroundStyle(.white)
                        
                        Button("Other data sources") {
                            
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding()
            }
        }
    }
}

struct TodayWeatherCard: View {
    var temp: String
    var description: String
    var imageName: String
    var low: String
    var high: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(temp)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                HStack {
                    Text("L: \(low)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("H: \(high)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .symbolRenderingMode(.multicolor)
        }
        .padding()
        .frame(width: 220, height: 100)
        .background(Color.black.opacity(0.3))
        .cornerRadius(24)
    }
}

struct DailyWeatherCard: View {
    var day: String
    var temp: String
    var imageName: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .symbolRenderingMode(.multicolor)
            Text(temp)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 60, height: 100)
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }
}

struct AppleWeatherAttributionView: View {
    var body: some View {
        HStack(spacing: 6) {
            // Apple logo
            Image(systemName: "apple.logo")
                .font(.caption)
            
            // Attribution text
            Text("Weather data from ")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Link to Apple Weather
            Link("Apple Weather", destination: URL(string: "https://weather.apple.com")!)
                .font(.caption2)
        }
        .padding(.top, 8)
    }
}
