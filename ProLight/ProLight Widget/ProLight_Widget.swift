//
//  ProLight_Widget.swift
//  ProLight Widget
//
//  Created by Paul on 9/17/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI

// MARK: Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        
        for offset in 0 ..< 60 * 24 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: offset, to: midnight)!
            entries.append(SimpleEntry(date: entryDate))
        }

        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

// MARK: Simple Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
}

// MARK: Main View
struct ProLight_WidgetEntryView : View {
    var entry: Provider.Entry
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Color(.black)
            
            VStack {
                HStack {
                    Spacer()
                    Image("power")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                }
                
                Text("\(entry.date, formatter: Self.timeFormatter)")
                    .font(.system(size: 25))
                    .foregroundColor(.green)
                    .padding()
                
                Text("\(entry.date, formatter: Self.dateFormatter)")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
        }
    }
}

@main
struct SimpleWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ProLight_Widget()
    }
}

struct ProLight_Widget: Widget {
    let kind: String = "ProLight_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ProLight_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Clock")
        .description("Simple clock that displays the current time and date.")
        .supportedFamilies([.systemSmall])
    }
}

struct ProLight_Widget_Previews: PreviewProvider {
    static var previews: some View {
        ProLight_WidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
