//
//  FlashLightLiveActivity.swift
//  ProLight
//
//  Created by Paul  on 7/28/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FlashlightAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isOn: Bool
        var brightness: Double // 0.0 to 1.0
    }

    var mode: String // "Steady", "Blinking", etc.
}

struct FlashlightLiveActivity: View {
    let context: ActivityViewContext<FlashlightAttributes>

    var body: some View {
        VStack {
            Text("Flashlight is \(context.state.isOn ? "On" : "Off")")
            Text("Brightness: \(Int(context.state.brightness * 100))%")
        }
        .padding()
    }
}

struct ProLightLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlashlightAttributes.self) { context in
            FlashlightLiveActivity(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Tap to return to ProLight")
                }
            } compactLeading: {
                currentTemp()
            } compactTrailing: {
                FlashlightRingIndicatorView()
            } minimal: {
                FlashlightRingIndicatorView()
            }
        }
    }
}

struct FlashlightRingIndicatorView: View {
    var body: some View {
        ZStack {
            Image(systemName: "flashlight.on.fill")
                .foregroundColor(.white)
        }
        .frame(width: 20, height: 20)
    }
}

struct currentTemp: View {
    var body: some View {
        Text("80°")
    }
}
