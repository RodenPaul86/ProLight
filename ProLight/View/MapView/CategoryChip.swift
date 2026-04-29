//
//  CategoryChip.swift
//  ProLight
//
//  Created by Paul  on 4/29/26.
//

import SwiftUI

// MARK: - Place Category Model

struct PlaceCategory {
    let label: String
    let icon: String
    let query: String
}

let placeCategories: [PlaceCategory] = [
    .init(label: "Restaurants", icon: "fork.knife",              query: "restaurants"),
    .init(label: "Coffee",      icon: "cup.and.saucer.fill",     query: "coffee"),
    .init(label: "Parks",       icon: "leaf.fill",               query: "parks"),
    .init(label: "Gyms",        icon: "dumbbell.fill",           query: "gym"),
    .init(label: "Gas",         icon: "fuelpump.fill",           query: "gas station"),
    .init(label: "Pharmacy",    icon: "cross.case.fill",         query: "pharmacy"),
    .init(label: "Grocery",     icon: "cart.fill",               query: "grocery store"),
    .init(label: "Hospital",    icon: "staroflife.fill",         query: "hospital"),
    .init(label: "Hotels",      icon: "bed.double.fill",         query: "hotel"),
    .init(label: "Parking",     icon: "parkingsign.circle.fill", query: "parking"),
    .init(label: "Banks",       icon: "banknote.fill",           query: "bank"),
    .init(label: "Schools",     icon: "graduationcap.fill",      query: "school"),
    .init(label: "Shopping",    icon: "bag.fill",                query: "shopping mall"),
    .init(label: "Transit",     icon: "bus.fill",                query: "bus station"),
    .init(label: "Bars",        icon: "wineglass.fill",          query: "bar"),
]

// MARK: - Category Chip

struct CategoryChip: View {
    let category: PlaceCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if #available(iOS 26.0, *) {
                HStack(spacing: 5) {
                    Image(systemName: category.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(category.label)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glassEffect(
                    isSelected ? .regular.tint(.mint).interactive() : .regular.interactive(),
                    in: .capsule
                )
                .foregroundColor(isSelected ? .black : .primary)
            } else {
                HStack(spacing: 5) {
                    Image(systemName: category.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(category.label)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.mint : Color(.systemBackground).opacity(0.92))
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                )
                .foregroundColor(isSelected ? .black : .primary)
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
