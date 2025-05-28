//
//  weatherKitUI.swift
//  ProLight
//
//  Created by Paul on 1/8/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import WeatherKit
import CoreLocation
import Charts
import SwiftAlertView
import Lottie

struct HourlyForcastView: View {
    let hourWeatherList: [HourWeather]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hourly Forecast")
                .font(.caption)
                .opacity(0.5)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(hourWeatherList, id: \.date) { hourItem in
                        VStack(spacing: 20) {
                            Text(hourItem.date.formatAsAbbreviatedTime())
                                .fontWeight(.medium)
                            Image(systemName: "\(hourItem.symbolName)")
                                .foregroundColor(.green)
                            Text(hourItem.temperature.formatted())
                                .fontWeight(.medium)
                        }.padding()
                    }
                }
            }
        }
        .padding()
        .foregroundColor(Color.white)
        .background(Color(.systemGray5))
        .modifier(CardModifier())
    }
}

struct TenDayForcastView: View {
    let dayWeatherList: [DayWeather]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("10 Day Forecast")
                .font(.caption)
                .opacity(0.5)
            
            List(dayWeatherList, id: \.date) { dailyWeather in
                HStack {
                    Text(dailyWeather.date.formatAsAbbreviatedDay())
                        .frame(maxWidth: 50, alignment: .leading)
                    
                    Image(systemName: "\(dailyWeather.symbolName)")
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("L")
                        .font(.caption)
                        .opacity(0.5)
                    
                    Text(dailyWeather.lowTemperature.formatted())
                        .padding(.trailing)
                    
                    Text("H")
                        .font(.caption)
                        .opacity(0.5)
                    
                    Text(dailyWeather.highTemperature.formatted())
                        
                }.listRowBackground(Color(.systemGray5))
            }.listStyle(.plain)
        }
        .frame(height: 210)
        .padding()
        .foregroundColor(Color.white)
        .background(Color(.systemGray5))
        .modifier(CardModifier())
    }
}

struct weatherKitUI: View {
    var backToMAinVC: HomeVC?
    let service = WeatherService()
    @StateObject private var locationManager = LocationManager()
    @State private var weather: Weather?
    @State private var isRefreahed: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var attributionLink: URL?
    @State private var attributionLogo: URL?
    
    var hourlyWeatherData: [HourWeather] {
        if let weather {
            return Array(weather.hourlyForecast.filter { hourlyWeather in
                return hourlyWeather.date.timeIntervalSince(Date()) >= 0
            }.prefix(13))
        } else {
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    if let weather {
                        CurrentForecastView(currentDate: weather.currentWeather.date.dateFormatted,
                                            conditionImage: weather.currentWeather.symbolName,
                                            currentTemp: weather.currentWeather.temperature.formatted(),
                                            condition: weather.currentWeather.condition.rawValue.uppercased())
                        HourlyForecastChartView(hourlyWeatherData: hourlyWeatherData)
                        HourlyForcastView(hourWeatherList: hourlyWeatherData)
                        TenDayForcastView(dayWeatherList: weather.dailyForecast.forecast)
                        
                        if let logo = attributionLogo, let link = attributionLink {
                            AttributionView(logo: logo, link: link)
                        }
                        
                    } else {
                        LottieView(name: "loadingWheel2", loopMode: .loop, speed: 1.00)
                            .frame(width: 50, height: 50)
                    }
                }
                .padding()
                .task {
                    do {
                        let attribution = try await WeatherService.shared.attribution
                        attributionLink = attribution.legalPageURL
                        attributionLogo = colorScheme == .light ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL
                    } catch {
                        print(error)
                    }
                }
                .task(id: locationManager.currentLocation) {
                    do {
                        if let location = locationManager.currentLocation {
                            self.weather = try await service.weather(for: location)
                        }
                    } catch {
                        print(error)
                    }
                }
                
            }
            .navigationBarTitle("Local Weather", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.backToMAinVC?.presentedViewController?.dismiss(animated: true)
                    } label: {
                        Text("Cancel")
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        SwiftAlertView.show(title: "Change °F to °C",
                                            message: "1. Open Settings.\n2. Swipe down and tap General.\n3. Tap Language & Region, then Temperature Unit.",
                                            buttonTitles: "OK") { alert in
                            alert.style = .auto
                            alert.buttonTitleColor = .systemBlue
                            alert.cancelButtonIndex = 0
                            alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                            alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
                        }
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.green)
                    }
                }
            })
        }
        .interactiveDismissDisabled() // Prevent a sheet from being dismissed with swipe.
    }
}

struct weatherKitUI_Previews: PreviewProvider {
    static var previews: some View {
        weatherKitUI()
    }
}

extension Date {
    func formatAsAbbreviatedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    func formatAsAbbreviatedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: self)
    }
}
