//
//  AppIconWidgetView.swift
//  ProLight WidgetExtension
//
//  Created by Paul on 7/5/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AppIconEntry {
        AppIconEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AppIconEntry) -> ()) {
        let entry = AppIconEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = AppIconEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct AppIconEntry: TimelineEntry {
    let date: Date
}

struct appIconWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            small_Icon()
        case .systemMedium:
            EmptyView()
        case .systemLarge:
            EmptyView()
        case .systemExtraLarge:
            EmptyView()
        case .accessoryCircular:
            accessoryCircular_Icon()
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
struct small_Icon: View {
    var body: some View {
        ZStack {
            Color.black
            VStack {
                Button(action: {}) {
                    Image(systemName: "power")
                        .resizable()
                        .font(.title.weight(.semibold))
                        .foregroundColor(.green)
                        .shadow(color: Color(UIColor(displayP3Red: 96/255, green: 252/255, blue: 255/255, alpha: 2)), radius: 5, x: 0, y: 0)
                }
            }
            .padding(30)
        }
    }
}

// Accessory Circular View
struct accessoryCircular_Icon: View {
    var body: some View {
        VStack {
            Image(systemName: "power")
                .resizable()
                .font(.title.weight(.semibold))
        }
    }
}

struct appIconWidget: Widget {
    let kind: String = "com.ProLight.appIconWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            appIconWidgetView()
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("ProLight")
        .description("")
        .supportedFamilies([.systemSmall, .accessoryCircular])
        .contentMarginsDisabled()
    }
}

struct appIconWidget_Previews: PreviewProvider {
    static var previews: some View {
        small_Icon()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
