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
    hourFormatter.dateFormat = "ha" /// <-- e.g. "3PM"
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
        ZStack(alignment: .top) {
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
                
                let nowSymbol = weather.symbolName == "wind" ? "wind" : "\(weather.symbolName).fill"
                
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
                    
                    // MARK: Today + daily cards
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("Today")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            TodayWeatherCard(
                                temp: "\(Int(temp.value))°",
                                description: weather.condition.description.capitalized,
                                imageName: nowSymbol,
                                low: "\(Int(low.value))°",
                                high: "\(Int(high.value))°"
                            )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Rest of the Week")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            if let daily = locationManager.dailyForecast?.forecast.dropFirst().prefix(6) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(Array(daily.enumerated()), id: \.offset) { index, day in
                                            let high = selectedUnit == .fahrenheit
                                            ? day.highTemperature.converted(to: .fahrenheit)
                                            : day.highTemperature.converted(to: .celsius)
                                            
                                            let symbol = day.symbolName == "wind" ? "wind" : "\(day.symbolName).fill"
                                            let weekday = Calendar.current.shortWeekdaySymbols[
                                                Calendar.current.component(.weekday, from: day.date) - 1
                                            ]
                                            
                                            DailyWeatherCard(
                                                day: weekday.uppercased(),
                                                temp: "\(Int(high.value))°",
                                                imageName: symbol
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Text("Hourly")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    // MARK: Hourly forecast starting with Now
                    if let hourly = locationManager.hourlyForecast?.forecast.filter({ $0.date >= Date() }).prefix(12),
                       let daily = locationManager.dailyForecast?.forecast {
                        
                        let today = daily.first
                        let tomorrow = daily.dropFirst().first
                        
                        // Sunrise/sunset times
                        let todaySunrise = today?.sun.sunrise
                        let todaySunset = today?.sun.sunset
                        let tomorrowSunrise = tomorrow?.sun.sunrise
                        
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
                                    
                                    // Special case for sunrise/sunset
                                    if let sunrise = todaySunrise, Calendar.current.isDate(hourData.date, equalTo: sunrise, toGranularity: .hour) {
                                        HourlyWeatherCard(
                                            hour: formattedHour(sunrise),
                                            temp: "Sunrise",
                                            imageName: "sunrise.fill"
                                        )
                                    }
                                    else if let sunset = todaySunset, Calendar.current.isDate(hourData.date, equalTo: sunset, toGranularity: .hour) {
                                        HourlyWeatherCard(
                                            hour: formattedHour(sunset),
                                            temp: "Sunset",
                                            imageName: "sunset.fill"
                                        )
                                    }
                                    else if let tomorrowSunrise = tomorrowSunrise, Calendar.current.isDate(hourData.date, equalTo: tomorrowSunrise, toGranularity: .hour) {
                                        HourlyWeatherCard(
                                            hour: formattedHour(tomorrowSunrise),
                                            temp: "Sunrise",
                                            imageName: "sunrise.fill"
                                        )
                                    }
                                    else {
                                        HourlyWeatherCard(
                                            hour: formattedHour(hourData.date),
                                            temp: "\(Int(hourTemp.value))°",
                                            imageName: symbol
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                .overlay(alignment: .bottom) {
                    AttributionView()
                        .padding(.bottom)
                        .ignoresSafeArea(.container, edges: .bottom)
                        .offset(y: 90)
                }
            }
        }
    }
}

// MARK: Today's Card
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

// MARK: Daily Card
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

// MARK: Hourly Card
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

