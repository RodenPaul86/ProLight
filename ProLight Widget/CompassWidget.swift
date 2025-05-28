//
//  CompassWidgetView.swift
//  ProLight
//
//  Created by Paul on 7/10/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct CompassEntry: TimelineEntry {
    let date: Date
    let heading: CLHeading
}

struct CompassProvider: TimelineProvider {
    func placeholder(in context: Context) -> CompassEntry {
        CompassEntry(date: Date(), heading: CLHeading())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CompassEntry) -> Void) {
        let entry = CompassEntry(date: Date(), heading: CLHeading())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CompassEntry>) -> Void) {
        let entry = CompassEntry(date: Date(), heading: CLHeading())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CompassView: View {
    var entry: CompassProvider.Entry
    @Environment(\.widgetFamily) private var widgetFamily
    @State private var currentHeading: CLHeading?
    private let locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            if let heading = currentHeading {
                Text("Heading: \(heading.trueHeading)")
                    .font(.title2)
                    .padding()
            } else {
                Text("Compass unavailable")
                    .font(.title2)
                    .padding()
            }
        }
        .onAppear {
            //locationManager.delegate = self
            locationManager.startUpdatingHeading()
        }
        .onDisappear {
            locationManager.stopUpdatingHeading()
        }
    }
}

struct CompassWidget: Widget {
    private let kind = "CompassWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CompassProvider()) { entry in
            CompassView(entry: entry)
        }
        .configurationDisplayName("Compass Widget")
        .description("Display the current heading.")
        .supportedFamilies([.systemSmall])
    }
}
