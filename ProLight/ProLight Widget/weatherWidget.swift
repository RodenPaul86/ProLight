//
//  weatherWidget.swift
//  ProLight WidgetExtension
//
//  Created by Paul on 7/4/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI
import WeatherKit
import CoreLocation

// WeatherEntry(date: Date(), city: "Chicago", weatherIcon: "sun.max", condition: "MOSTLY CLEAR", temperature: "80°")

struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), weather: WeatherViewModel(temperature: 0, condition: "Loading..."))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(date: Date(), weather: WeatherViewModel(temperature: 20, condition: "Sunny"))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weather: WeatherViewModel
}

struct WeatherViewModel {
    let temperature: Double
    let condition: String
}

struct WeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: WeatherProvider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWeatherView(entry: entry)
        case .systemMedium:
            EmptyView()
        case .systemLarge:
            EmptyView()
        case .systemExtraLarge:
            EmptyView()
        case .accessoryCircular:
            EmptyView()
        case .accessoryRectangular:
            EmptyView()
        case .accessoryInline:
            EmptyView()
        @unknown default:
            EmptyView()
        }
    }
}

struct SmallWeatherView: View {
    var entry: WeatherProvider.Entry
    //@State private var currentCon
    
    var body: some View {
        ZStack {
            Color.black
            VStack {
                Text("entry.city")
                    .font(.caption.bold())
                    .foregroundColor(.green)
                    .padding(1)
                HStack {
                    Image(systemName: "entry.weatherIcon")
                    Text("entry.condition")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                Text("entry.temperature")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(.green)
                    .padding(2)
            }
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "com.ProLight.weatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather")
        .description("A weather widget displaying the current temperature, weather conditions, and city name")
        .supportedFamilies([.systemSmall])
    }
}

struct weatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWeatherView(entry: WeatherEntry(date: Date(), weather: WeatherViewModel(temperature: 20, condition: "Sunny")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
