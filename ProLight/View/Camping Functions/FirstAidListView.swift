//
//  FirstAidListView.swift
//  ProLight
//
//  Created by Paul  on 8/15/25.
//

import Foundation
import SwiftUI

struct FirstAidTip: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let steps: [String]
}

struct FirstAidListView: View {
    @State private var searchText = ""
    
    let tips: [FirstAidTip] = [
        FirstAidTip(
            title: "Burns",
            description: "For minor burns only. Seek medical help for severe burns.",
            steps: [
                "Cool the burn under running water for at least 10 minutes.",
                "Remove any tight items (rings, watches) before swelling.",
                "Cover with a clean, non-stick dressing.",
                "Do not apply ice, butter, or toothpaste."
            ]
        ),
        FirstAidTip(
            title: "Snake Bite",
            description: "Stay calm and seek emergency help immediately.",
            steps: [
                "Keep the person still and calm to slow venom spread.",
                "Immobilize the affected limb and keep it below heart level.",
                "Do not cut the wound or attempt to suck out venom.",
                "Call emergency services with location information."
            ]
        )
    ]
    
    var filteredTips: [FirstAidTip] {
        if searchText.isEmpty { return tips }
        return tips.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List(filteredTips) { tip in
            NavigationLink(destination: FirstAidDetailView(tip: tip)) {
                Text(tip.title)
                    .font(.headline)
            }
        }
        .navigationTitle("First Aid Tips")
        .searchable(text: $searchText, prompt: "Search tips")
    }
}

struct FirstAidDetailView: View {
    let tip: FirstAidTip
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(tip.title)
                    .font(.title)
                    .bold()
                
                Text(tip.description)
                    .foregroundStyle(.secondary)
                
                ForEach(tip.steps, id: \.self) { step in
                    Label(step, systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle(tip.title)
    }
}

