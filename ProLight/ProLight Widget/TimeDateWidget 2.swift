//
//  TimeDateWidget.swift
//  ProLight Widget
//
//  Created by Paul on 9/17/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct TimeProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeDateEntry {
        TimeDateEntry(date: Date(), location: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimeDateEntry) -> ()) {
        let entry = TimeDateEntry(date: Date(), location: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TimeDateEntry] = []
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: Date())!
            let entry = TimeDateEntry(date: entryDate, location: locationManager.location)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .minute, value: 1, to: Date())!))
        completion(timeline)
    }
}

struct TimeDateEntry: TimelineEntry {
    let date: Date
    let location: CLLocation?
}

// MARK: Main View
struct TimeWidget_WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: TimeProvider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
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
    var entry: TimeProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            VStack(alignment: .leading) {
                Text(entry.date.formatted(.dateTime.month().day()))
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                Text(entry.date.formatted(.dateTime.weekday(.wide)))
                    .font(.subheadline).bold()
                    .foregroundColor(.gray)
                Spacer()
                Text(entry.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute()))
                    .font(.system(size: 45, design: .rounded)).bold()
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
    var entry: TimeProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(entry.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute()))
                    .font(.system(size: 110, design: .rounded)).bold()
                    .foregroundColor(.green)
                    .opacity(0.8)
                    .shadow(color: Color(UIColor(displayP3Red: 96/255,green: 252/255, blue: 255/255, alpha: 2)), radius: 5, x: 1, y: 1)
            }
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .leading) {
                Spacer()
                Text(entry.date.formatted(.dateTime.weekday(.wide)))
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                Text(entry.date.displayDateFormat)
                    .font(.subheadline).bold()
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// Large Widget View
struct LargeWidgetView: View {
    var entry: TimeProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(entry.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted))))
                    .font(.system(size: 140, design: .rounded)).bold()
                    .foregroundColor(.green)
                    .opacity(0.8)
                    .shadow(color: Color(UIColor(displayP3Red: 96/255,green: 252/255, blue: 255/255, alpha: 2)), radius: 5, x: 1, y: 1)
                    .padding(.bottom, -15)
                
                Text(entry.date.formatted(.dateTime.minute(.twoDigits)))
                    .font(.system(size: 140, design: .rounded)).bold()
                    .foregroundColor(.green)
                    .opacity(0.8)
                    .shadow(color: Color(UIColor(displayP3Red: 96/255,green: 252/255, blue: 255/255, alpha: 2)), radius: 5, x: 1, y: 1)
                    .padding(.top, -15)
            }
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .leading) {
                Spacer()
                Text(entry.date.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 45)).bold()
                    .foregroundColor(.white)
                Text(entry.date.displayDateFormat)
                    .font(.subheadline).bold()
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TimeDateWidget: Widget {
    let kind: String = "com.ProLight.timeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeProvider()) { entry in
            TimeWidget_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Date + Time")
        .description("Simple widget displaying the current date and time.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TimeDateWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(entry: TimeDateEntry(date: Date(), location: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        MediumWidgetView(entry: TimeDateEntry(date: Date(), location: nil))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        LargeWidgetView(entry: TimeDateEntry(date: Date(), location: nil))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

extension Date {
    var displayDateFormat: String {
        self.formatted(
            .dateTime
                .month(.wide)
                .day()
                .year()
        )
    }
    
    var displayTimeFormat: String {
        self.formatted(
            .dateTime
                .hour(.conversationalDefaultDigits(amPM: .narrow))
                .minute()
        )
    }
}
