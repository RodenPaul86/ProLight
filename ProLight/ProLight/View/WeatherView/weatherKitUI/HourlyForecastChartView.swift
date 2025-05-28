//
//  HourlyForecastChartView.swift
//  ProLight
//
//  Created by Paul on 1/10/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import WeatherKit
import Charts

struct HourlyForecastChartView: View {
    let hourlyWeatherData: [HourWeather]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hourly Temperature Chart")
                .font(.caption)
                .opacity(0.5)
            
            Chart {
                ForEach(hourlyWeatherData.prefix(6), id: \.date) { hourlyWeather in
                    LineMark(x: .value("Hour", hourlyWeather.date.formatAsAbbreviatedTime()),
                             y: .value("Temperature", hourlyWeather.temperature.converted(to: .fahrenheit).value))
                }
            }
            .foregroundColor(.green)
        }
        .padding()
        .foregroundColor(Color.white)
        .background(Color(.systemGray5))
        .modifier(CardModifier())
    }
}
