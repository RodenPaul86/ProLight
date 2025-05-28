//
//  calenderWidget.swift
//  ProLight
//
//  Created by Paul on 7/13/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI

struct CalenderProvider: TimelineProvider {
    typealias Entry = CalenderEntry

    func placeholder(in context: Context) -> CalenderEntry {
        CalenderEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalenderEntry) -> ()) {
        let entry = CalenderEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [CalenderEntry] = []
        
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = CalenderEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CalenderEntry: TimelineEntry {
    let date: Date
}

struct CalenderWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: CalenderProvider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallCalender(entry: entry)
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

// Small Widget View
struct smallCalender: View {
    var entry: CalenderProvider.Entry
    
    var body: some View {
        ZStack {
            Color.black
            VStack {
                Text(entry.date.formatted(.dateTime.day()))
                    .font(.system(size: 80, design: .rounded)).bold()
                    .foregroundColor(.green)
                    .shadow(color: Color(UIColor(displayP3Red: 96/255,green: 252/255, blue: 255/255, alpha: 2)), radius: 3, x: 1, y: 1)
                Text(entry.date.formatted(.dateTime.month(.wide)))
                    .font(.system(size: 20, design: .rounded)).bold()
                    .foregroundColor(.white)
                Text(entry.date.formatted(.dateTime.weekday(.wide)))
                    .font(.system(.caption, design: .rounded)).bold()
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct CalenderWidget: Widget {
    let kind: String = "com.ProLight.calenderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalenderProvider()) { entry in
            CalenderWidgetView(entry: entry)
        }
        .configurationDisplayName("Minimal Date")
        .description("Stay up-to-date with a modern date design.")
        .supportedFamilies([.systemSmall])
    }
}

struct CalenderWidget_Previews: PreviewProvider {
    static var previews: some View {
        smallCalender(entry: CalenderEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
