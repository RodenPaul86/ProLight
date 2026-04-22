//
//  Compass.swift
//  ProLight
//
//  Created by Paul  on 4/22/26.
//

import SwiftUI
import CoreLocation

// MARK: - Compass View

struct Compass: View {
    @StateObject private var manager = CompassManager()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {

                // Top Bar
                HStack {
                    Text(currentTime())
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
/*
                // Compass Scale
                CompassScaleView(heading: manager.heading)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
 */

                // Heading
                Text("\(Int(manager.heading))° \(manager.direction)")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                // Elevation
                Text("Elevation: \(Int(manager.altitude)) m")
                    .foregroundColor(.gray)

                // Coordinates
                if let coord = manager.coordinate {
                    Text(formatCoordinate(coord))
                        .foregroundColor(.white.opacity(0.8))
                        .font(.footnote)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Helpers

    func currentTime() -> String {
        Date().formatted(date: .omitted, time: .shortened)
    }

    func formatCoordinate(_ coord: CLLocationCoordinate2D) -> String {
        func dms(_ decimal: Double, pos: String, neg: String) -> String {
            let d = Int(abs(decimal))
            let m = Int((abs(decimal) - Double(d)) * 60)
            let s = Int(((abs(decimal) - Double(d)) * 60 - Double(m)) * 60)
            let dir = decimal >= 0 ? pos : neg
            return "\(d)°\(m)′\(s)″ \(dir)"
        }
        return "\(dms(coord.latitude, pos: "N", neg: "S"))  \(dms(coord.longitude, pos: "E", neg: "W"))"
    }
}

// MARK: - Compass Scale View

struct CompassScaleView: View {
    let heading: Double

    private let tickSpacing: CGFloat = 12
    private let repeatedCount = 3

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let stripWidth = CGFloat(360) * tickSpacing
            let normalizedHeading = heading.truncatingRemainder(dividingBy: 360)

            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )

                HStack(spacing: 0) {
                    ForEach(0..<(360 * repeatedCount), id: \.self) { index in
                        let degree = index % 360

                        VStack(spacing: 6) {
                            if degree % 30 == 0 {
                                Text(label(for: degree))
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(labelColor(for: degree))
                                    .frame(height: 18)
                            } else {
                                Color.clear.frame(height: 18)
                            }

                            Rectangle()
                                .fill(tickColor(for: degree))
                                .frame(
                                    width: degree % 30 == 0 ? 2 : 1,
                                    height: tickHeight(for: degree)
                                )
                        }
                        .frame(width: tickSpacing)
                    }
                }
                .offset(x: (width / 2) - stripWidth - (normalizedHeading * tickSpacing))
                .clipped()

                Rectangle()
                    .fill(.white)
                    .frame(width: 3, height: 46)
                    .clipShape(Capsule())
                    .shadow(color: .white.opacity(0.35), radius: 4)

                HStack {
                    Text("◀")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.red)

                        Text("N")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Spacer()
                    
                    Text("▶")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .offset(y: -18)
            }
            .frame(width: width, height: 72)   // important
            .clipped()
        }
        .frame(maxWidth: .infinity)            // important
        .frame(height: 72)
    }

    private func tickHeight(for degree: Int) -> CGFloat {
        if degree % 30 == 0 { return 28 }
        if degree % 10 == 0 { return 20 }
        return 12
    }

    private func tickColor(for degree: Int) -> Color {
        if degree % 30 == 0 { return .white }
        if degree % 10 == 0 { return .white.opacity(0.65) }
        return .white.opacity(0.28)
    }

    private func label(for degree: Int) -> String {
        switch degree {
        case 0: return "N"
        case 30: return "30"
        case 60: return "60"
        case 90: return "E"
        case 120: return "120"
        case 150: return "150"
        case 180: return "S"
        case 210: return "210"
        case 240: return "240"
        case 270: return "W"
        case 300: return "300"
        case 330: return "330"
        default: return ""
        }
    }

    private func labelColor(for degree: Int) -> Color {
        degree == 0 ? .red : .white
    }
}
