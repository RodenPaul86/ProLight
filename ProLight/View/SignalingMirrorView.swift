//
//  SignalingMirrorView.swift
//  ProLight
//
//  Created by Paul  on 3/1/26.
//

import SwiftUI

struct SignalingMirrorInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero illustration
                    HeroImage()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Warning
                        CallFirstWarning()
                        
                        // Steps
                        SectionLabel(text: "How it works")
                        StepsCard()
                        
                        // Tips
                        SectionLabel(text: "Good to know")
                        TipsCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Signaling Mirror")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("Signaling Mirror")
                            .font(.headline)
                        Text("Emergency signaling technique")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Hero

struct HeroImage: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("signalingMirrorDiagram") // your asset name here
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
                .background(Color.black)
            
            // Distress signal badge
            Text("Best Method")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red.opacity(0.85))
                .clipShape(Capsule())
                .padding(14)
        }
    }
}

// MARK: - Steps

private let steps: [(String, String)] = [
    ("Form a ''V'' with your fingers",
     "Hold up your non-dominant hand with index and middle fingers in a ''V'', aimed at the target — plane, boat, or person."),
    
    ("Position the phone",
     "Hold the phone near your face, just beside your eye, with screen or metal back facing the sun."),
    
    ("Catch the light",
     "Angle the phone until sunlight reflects off the surface and produces a bright spot on the skin between your fingers."),
    
    ("Aim through the ''V''",
     "Slowly adjust until the beam of light shines directly through the ''V'' gap toward the target."),
    
    ("Sweep and flash",
     "Move the phone slightly back and forth to create a flashing effect — more noticeable than a steady beam.")
]

struct StepsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {  // ← add alignment here
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                StepRow(number: index + 1, title: step.0, description: step.1)
                if index < steps.count - 1 {
                    Divider().padding(.leading, 50)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)  // ← and this
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StepRow: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 24, height: 24)
                Text("\(number)")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(.top, 1)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline).fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
    }
}

// MARK: - Tips

private let tips: [(String, String)] = [
    ("Target the cockpit.", "When signaling an aircraft, aim for the cockpit — not the fuselage."),
    ("SOS pattern.", "Three short flashes, three long, three short — the universal distress signal."),
    ("Broken phone still works.", "The metallic layer behind a cracked screen is highly reflective."),
    ("Practice now.", "Try this at home so you're confident if you ever need it for real.")
]

struct TipsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 9) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 5, height: 5)
                        .padding(.top, 5)
                    (Text(tip.0 + " ").fontWeight(.semibold) + Text(tip.1))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                if index < tips.count - 1 {
                    Divider().padding(.leading, 27)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Warning Banner

struct BatteryWarning: View {
    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 15))
                .padding(.top, 1)
            
            Text("**Save your battery.** Use airplane mode between signals — preserve power for emergency calls.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(13)
        .background(Color.red.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Warning

struct CallFirstWarning: View {
    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 15))
                .padding(.top, 1)
            Text("**Call first.** If your phone is working, always try calling or texting for help before using it as a mirror.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(13)
        .background(Color.red.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Section Label

struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.caption2).fontWeight(.bold)
            .foregroundStyle(.secondary)
            .tracking(0.8)
            .padding(.horizontal, 4)
            .padding(.bottom, -8)
    }
}

#Preview {
    SignalingMirrorInstructionsView()
        .preferredColorScheme(.dark)
}
