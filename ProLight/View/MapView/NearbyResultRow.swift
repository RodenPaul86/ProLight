//
//  NearbyResultRow.swift
//  ProLight
//
//  Created by Paul  on 4/29/26.
//

import SwiftUI
import MapKit

struct NearbyResultRow: View {
    let item: MKMapItem
    let userLocation: CLLocation?
    let isSelected: Bool
    let action: () -> Void
    
    private var distance: String {
        guard let userLoc = userLocation else { return "" }
        let dest = CLLocation(
            latitude: item.placemark.coordinate.latitude,
            longitude: item.placemark.coordinate.longitude
        )
        let meters = userLoc.distance(from: dest)
        return meters < 1609
        ? String(format: "%.0f m away", meters)
        : String(format: "%.1f mi away", meters / 1609.34)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.mint.opacity(0.2) : Color(.secondarySystemBackground))
                        .frame(width: 42, height: 42)
                    Image(systemName: poiIcon(for: item))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .mint : .secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name ?? "Unknown")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if let address = item.placemark.thoroughfare {
                        Text(address)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if !distance.isEmpty {
                    Text(distance)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.mint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.mint.opacity(0.12)))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.mint.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    private func poiIcon(for item: MKMapItem) -> String {
        switch item.pointOfInterestCategory {
        case .restaurant, .cafe, .bakery, .brewery, .foodMarket: return "fork.knife"
        case .hospital:                                          return "staroflife.fill"
        case .pharmacy:                                          return "cross.case.fill"
        case .gasStation:                                        return "fuelpump.fill"
        case .hotel:                                             return "bed.double.fill"
        case .parking:                                           return "parkingsign.circle.fill"
        case .bank, .atm:                                        return "banknote.fill"
        case .school, .university:                               return "graduationcap.fill"
        case .publicTransport:                                   return "bus.fill"
        case .nightlife, .winery:                                return "wineglass.fill"
        case .fitnessCenter:                                     return "dumbbell.fill"
        case .park:                                              return "leaf.fill"
        case .store:                                             return "bag.fill"
        default:
            let name = (item.name ?? "").lowercased()
            if name.contains("coffee")  { return "cup.and.saucer.fill" }
            if name.contains("park")    { return "leaf.fill" }
            if name.contains("gym")     { return "dumbbell.fill" }
            return "mappin.circle.fill"
        }
    }
}

// MARK: - Nearby Results Sheet

struct NearbyResultsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let results: [MKMapItem]
    let userLocation: CLLocation?
    @Binding var mapSelection: MKMapItem?
    var selectedCategory: String
    
    // Sort results by distance from user
    private var sortedResults: [MKMapItem] {
        guard let userLoc = userLocation else { return results }
        return results.sorted {
            let a = CLLocation(latitude: $0.placemark.coordinate.latitude,
                               longitude: $0.placemark.coordinate.longitude)
            let b = CLLocation(latitude: $1.placemark.coordinate.latitude,
                               longitude: $1.placemark.coordinate.longitude)
            return userLoc.distance(from: a) < userLoc.distance(from: b)
        }
    }
    
    var body: some View {
        NavigationStack {
            if #available(iOS 26.0, *) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedResults, id: \.self) { item in
                            NearbyResultRow(
                                item: item,
                                userLocation: userLocation,
                                isSelected: mapSelection == item
                            ) {
                                mapSelection = item
                            }
                            if item != sortedResults.last {
                                Divider().padding(.leading, 70)
                            }
                        }
                    }
                }
                .background(.regularMaterial)
                .navigationTitle(selectedCategory.isEmpty ? "Nearby" : selectedCategory)
                .toolbarTitleDisplayMode(.inlineLarge)
                .navigationSubtitle("\(results.count) result\(results.count == 1 ? "" : "s")")
            } else {
                VStack(spacing: 0) {
                    // Drag handle + header
                    VStack(spacing: 8) {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Nearby" : selectedCategory)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Spacer()
                            Text("\(results.count) result\(results.count == 1 ? "" : "s")")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                    }
                    
                    Divider()
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sortedResults, id: \.self) { item in
                                NearbyResultRow(
                                    item: item,
                                    userLocation: userLocation,
                                    isSelected: mapSelection == item
                                ) {
                                    mapSelection = item
                                }
                                if item != sortedResults.last {
                                    Divider().padding(.leading, 70)
                                }
                            }
                        }
                    }
                }
                .background(.regularMaterial)
            }
        }
    }
}
