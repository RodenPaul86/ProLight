//
//  AttributionView.swift
//  ProLight
//
//  Created by Paul  on 7/29/25.
//

import SwiftUI
import WeatherKit

struct AttributionView: View {
    @Environment(\.colorScheme) private var colorScheme
    let weatherManager = WeatherManager.shared
    @State private var attribution: WeatherAttribution?
    
    var body: some View {
        HStack {
            if let attribution {
                AsyncImage(url: attribution.combinedMarkDarkURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                } placeholder: {
                    ProgressView()
                }
                Text(.init("[\(attribution.serviceName)](\(attribution.legalPageURL))"))
            }
        }
        .task {
            Task.detached { @MainActor in
                attribution = await weatherManager.weatherAttribution()
            }
        }
    }
}

#Preview {
    AttributionView()
}
