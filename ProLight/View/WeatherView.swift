//
//  WeatherView.swift
//  ProLight
//
//  Created by Paul  on 7/29/25.
//

import SwiftUI
import WeatherKit

private func formattedHour(_ date: Date) -> String {
    let hourFormatter = DateFormatter()
    hourFormatter.dateFormat = "ha" // e.g. "3PM"
    return hourFormatter.string(from: date)
}

struct WeatherView: View {
    @StateObject private var locationManager = LocationManager()
    @AppStorage("preferredTempUnit") private var selectedUnitRaw: String = TemperatureUnit.fahrenheit.rawValue
    
    @Environment(\.colorScheme) var colorScheme
    @State private var attributionLink: URL?
    @State private var attributionLogo: URL?
    
    var selectedUnit: TemperatureUnit {
        TemperatureUnit(rawValue: selectedUnitRaw) ?? .fahrenheit
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
                
                
                VStack(alignment: .leading, spacing: 10) {
                    // MARK: City name + State name
                    if !locationManager.cityName.isEmpty {
                        Text("\(locationManager.cityName), \(locationManager.stateName)")
                            .font(.title3)
                            .foregroundStyle(.white)
                    } else {
                        Text("Loading...")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    // MARK: Today + daily cards
                    HStack(spacing: 12) {
                        TodayWeatherCard(
                            temp: "\(Int(temp.value))°",
                            description: weather.condition.description.capitalized,
                            imageName: "\(weather.symbolName).fill",
                            low: "\(Int(low.value))°",
                            high: "\(Int(high.value))°"
                        )
                        
                        if let daily = locationManager.dailyForecast?.forecast.dropFirst().prefix(6) {
                            ScrollView(.horizontal, showsIndicators: false) {
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
                    }
                    
                    // MARK: Hourly forecast starting with Now
                    if let hourly = locationManager.hourlyForecast?.forecast.filter({ $0.date >= Date() }).prefix(12) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                
                                let nowSymbol = weather.symbolName == "wind" ? "wind" : "\(weather.symbolName).fill"
                                
                                HourlyWeatherCard(
                                    hour: "Now",
                                    temp: "\(Int(temp.value))°",
                                    imageName: nowSymbol
                                )
                                
                                // Next hours from WeatherKit
                                ForEach(Array(hourly), id: \.date) { hourData in
                                    let hourTemp = selectedUnit == .fahrenheit
                                    ? hourData.temperature.converted(to: .fahrenheit)
                                    : hourData.temperature.converted(to: .celsius)
                                    
                                    let symbol = hourData.symbolName == "wind" ? "wind" : "\(hourData.symbolName).fill"
                                    
                                    HourlyWeatherCard(
                                        hour: formattedHour(hourData.date),
                                        temp: "\(Int(hourTemp.value))°",
                                        imageName: symbol
                                    )
                                }
                            }
                        }
                    }
                    
                    // MARK: Attribution
                    AppleWeatherAttributionView()
                }
                .padding(.horizontal)
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
                .symbolRenderingMode(imageName == "wind" ? .monochrome : .multicolor)
                .foregroundStyle(imageName == "wind" ? .white : .primary)
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
                .symbolRenderingMode(imageName == "wind" ? .monochrome : .multicolor)
                .foregroundStyle(imageName == "wind" ? .white : .primary)
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

struct HourlyWeatherCard: View {
    var hour: String
    var temp: String
    var imageName: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(hour)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .symbolRenderingMode(imageName == "wind" ? .monochrome : .multicolor)
                .foregroundStyle(imageName == "wind" ? .white : .primary)
            Text(temp)
                .font(.caption)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 8)
        .frame(width: 50, height: 100)
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }
}

struct AppleWeatherAttributionView: View {
    var body: some View {
        HStack(spacing: 6) {
            // Apple logo
            Image(systemName: "apple.logo")
                .font(.system(size: 10))
                .foregroundStyle(.white)
            
            // Attribution text
            Text("Weather")
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            // Link to Apple Weather
            Link("Other data sources", destination: URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/")!)
                .font(.system(size: 15))
        }
        .padding(.top, 8)
    }
}
