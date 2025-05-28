//
//  ProLight_Widget.swift
//  ProLight Widget
//
//  Created by Paul on 9/17/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), location: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), location: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: Date())!
            let entry = SimpleEntry(date: entryDate, location: locationManager.location)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .minute, value: 1, to: Date())!))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let location: CLLocation?
}

// MARK: Main View
struct TimeWidget_WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: SimpleProvider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
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

// Small Widget View
struct SmallWidgetView: View {
    var entry: SimpleProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            VStack(alignment: .leading) {
                Text(entry.date.formatted(.dateTime.month(.wide).day()))
                    .font(.callout).bold()
                    .foregroundColor(.white)
                Text(entry.date.formatted(.dateTime.weekday(.wide)))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(entry.date.displayTimeFormat)
                    .font(.system(size: 38, design: .rounded)).bold()
                    .foregroundColor(.green)
                    .shadow(color: Color(UIColor(displayP3Red: 96/255,green: 252/255, blue: 255/255, alpha: 2)), radius: 3, x: 1, y: 1)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// Medium Widget View
struct MediumWidgetView: View {
    var entry: SimpleProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            VStack(alignment: .leading) {
                Text(entry.date.displayDateFormat)
                    .font(.callout).bold()
                    .foregroundColor(.white)
                Text(entry.date.formatted(.dateTime.weekday(.wide)))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(entry.date.displayTimeFormat)
                    .font(.system(size: 38, design: .rounded)).bold()
                    .foregroundColor(.green)
                    .shadow(color: Color(UIColor(displayP3Red: 96/255,green: 252/255, blue: 255/255, alpha: 2)), radius: 3, x: 1, y: 1)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TimeWidget: Widget {
    let kind: String = "com.ProLight.timeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            TimeWidget_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Time/Date")
        .description("A simple widget displaying the current time and date.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(entry: SimpleEntry(date: Date(), location: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        MediumWidgetView(entry: SimpleEntry(date: Date(), location: nil))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
