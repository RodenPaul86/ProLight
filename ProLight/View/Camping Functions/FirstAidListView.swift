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
    var iconName: String = "cross.case.fill"
    var tintColorName: String = "red"
    
    var tintColor: Color {
        switch tintColorName {
        case "orange": return .orange
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "yellow": return .yellow
        case "pink": return .pink
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .red
        }
    }
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
            ],
            iconName: "flame.fill",
            tintColorName: "orange"
        ),
        FirstAidTip(
            title: "Snake Bite",
            description: "Stay calm and seek emergency help immediately.",
            steps: [
                "Keep the person still and calm to slow venom spread.",
                "Immobilize the affected limb and keep it below heart level.",
                "Do not cut the wound or attempt to suck out venom.",
                "Call emergency services with location information."
            ],
            iconName: "bandage.fill",
            tintColorName: "green"
        ),
        FirstAidTip(
            title: "Choking",
            description: "Act quickly. Call emergency services if the person cannot breathe, cough, or speak.",
            steps: [
                "Encourage the person to keep coughing if they can.",
                "Give up to 5 sharp back blows between the shoulder blades.",
                "If that fails, give up to 5 abdominal thrusts (Heimlich maneuver).",
                "Alternate back blows and abdominal thrusts until the object clears or help arrives."
            ],
            iconName: "lungs.fill",
            tintColorName: "red"
        ),
        FirstAidTip(
            title: "Cuts and Scrapes",
            description: "For minor wounds only. Seek help for deep cuts or heavy bleeding.",
            steps: [
                "Wash your hands before treating the wound if possible.",
                "Rinse the cut under clean water and remove debris.",
                "Apply gentle pressure with a clean cloth to stop bleeding.",
                "Cover with a sterile bandage and change it daily."
            ],
            iconName: "bandage.fill",
            tintColorName: "pink"
        ),
        FirstAidTip(
            title: "Severe Bleeding",
            description: "Call emergency services immediately for heavy or uncontrolled bleeding.",
            steps: [
                "Apply firm, direct pressure to the wound with a clean cloth.",
                "Keep pressing without lifting the cloth to check the wound.",
                "Raise the injured area above heart level if possible.",
                "Add more cloth on top if blood soaks through; do not remove the first layer."
            ],
            iconName: "cross.case.fill",
            tintColorName: "red"
        ),
        FirstAidTip(
            title: "Nosebleed",
            description: "Most nosebleeds can be managed at home. Seek help if bleeding lasts over 20 minutes.",
            steps: [
                "Sit upright and lean slightly forward.",
                "Pinch the soft part of the nose for 10 to 15 minutes.",
                "Breathe through your mouth and avoid swallowing blood.",
                "Do not tilt the head back or pack the nose with tissue."
            ],
            iconName: "drop.fill",
            tintColorName: "red"
        ),
        FirstAidTip(
            title: "Sprains and Strains",
            description: "Rest and monitor. See a doctor if there is severe pain or you cannot bear weight.",
            steps: [
                "Rest the injured area and avoid putting weight on it.",
                "Apply an ice pack wrapped in cloth for 15 to 20 minutes.",
                "Compress gently with an elastic bandage.",
                "Elevate the injured limb above heart level when possible."
            ],
            iconName: "figure.walk.motion",
            tintColorName: "blue"
        ),
        FirstAidTip(
            title: "Broken Bone",
            description: "Do not move the person unnecessarily. Call emergency services for suspected fractures.",
            steps: [
                "Keep the injured area still and support it in the position found.",
                "Apply a cold pack wrapped in cloth to reduce swelling.",
                "Do not try to realign the bone or push it back in.",
                "Immobilize with a splint only if trained, then wait for help."
            ],
            iconName: "figure.fall",
            tintColorName: "indigo"
        ),
        FirstAidTip(
            title: "Allergic Reaction",
            description: "Call emergency services immediately for signs of a severe reaction (anaphylaxis).",
            steps: [
                "Help the person use their epinephrine auto-injector if they have one.",
                "Have them lie flat with legs raised, unless breathing is difficult.",
                "Loosen tight clothing and keep them calm and warm.",
                "Be ready to give a second dose of epinephrine after 5 to 15 minutes if symptoms persist."
            ],
            iconName: "allergens",
            tintColorName: "purple"
        ),
        FirstAidTip(
            title: "Insect Sting",
            description: "Watch for signs of allergic reaction such as swelling of the face or difficulty breathing.",
            steps: [
                "Remove the stinger by scraping it out with a card edge.",
                "Wash the area with soap and water.",
                "Apply a cold pack to reduce swelling and pain.",
                "Seek emergency help if signs of a severe allergic reaction appear."
            ],
            iconName: "ant.fill",
            tintColorName: "yellow"
        ),
        FirstAidTip(
            title: "Seizure",
            description: "Most seizures stop on their own. Call emergency services if it lasts over 5 minutes.",
            steps: [
                "Ease the person to the floor and clear the area of hazards.",
                "Place something soft under their head.",
                "Turn them onto their side once shaking stops to keep airway clear.",
                "Do not hold them down or put anything in their mouth."
            ],
            iconName: "waveform.path.ecg",
            tintColorName: "indigo"
        ),
        FirstAidTip(
            title: "Fainting",
            description: "Usually brief and harmless, but seek help if the person doesn't wake quickly.",
            steps: [
                "Lay the person flat and raise their legs above heart level.",
                "Loosen tight clothing around the neck.",
                "Check for breathing and responsiveness.",
                "Once alert, help them sit up slowly and rest."
            ],
            iconName: "person.fill.questionmark",
            tintColorName: "teal"
        ),
        FirstAidTip(
            title: "Heat Stroke",
            description: "A medical emergency. Call emergency services right away.",
            steps: [
                "Move the person to a cool or shaded area immediately.",
                "Remove excess clothing and cool the skin with water or wet cloths.",
                "Fan the person to help lower body temperature.",
                "Do not give fluids if they are not fully alert."
            ],
            iconName: "sun.max.fill",
            tintColorName: "orange"
        ),
        FirstAidTip(
            title: "Hypothermia",
            description: "Seek emergency help for severe shivering, confusion, or slurred speech.",
            steps: [
                "Move the person to a warm, dry area out of the wind.",
                "Remove any wet clothing and wrap them in warm, dry blankets.",
                "Give warm (not hot) sweet drinks if they are fully alert.",
                "Do not apply direct heat or rub the skin vigorously."
            ],
            iconName: "snowflake",
            tintColorName: "blue"
        ),
        FirstAidTip(
            title: "Poisoning",
            description: "Call emergency services or a poison control center right away.",
            steps: [
                "Try to identify what was swallowed, inhaled, or touched.",
                "Do not induce vomiting unless instructed by a professional.",
                "Move the person to fresh air if inhaled poisoning is suspected.",
                "Keep the substance's container to share with emergency responders."
            ],
            iconName: "exclamationmark.triangle.fill",
            tintColorName: "green"
        ),
        FirstAidTip(
            title: "Eye Injury",
            description: "For chemical exposure or embedded objects, seek emergency care immediately.",
            steps: [
                "Flush the eye gently with clean water for 15 to 20 minutes.",
                "Do not rub the eye or try to remove an embedded object.",
                "Cover the eye loosely with a clean cloth or shield.",
                "Seek medical attention right away."
            ],
            iconName: "eye.trianglebadge.exclamationmark.fill",
            tintColorName: "teal"
        ),
        FirstAidTip(
            title: "CPR (Cardiac Arrest)",
            description: "Call emergency services immediately if someone is unresponsive and not breathing normally.",
            steps: [
                "Check responsiveness and breathing; call for emergency help.",
                "Place the heel of your hand on the center of the chest.",
                "Push hard and fast, about 2 inches deep, at 100 to 120 compressions per minute.",
                "Continue compressions until help arrives or the person responds."
            ],
            iconName: "heart.fill",
            tintColorName: "red"
        )
    ]
    
    var filteredTips: [FirstAidTip] {
        if searchText.isEmpty { return tips }
        return tips.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        Group {
            if filteredTips.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List(filteredTips) { tip in
                    NavigationLink(destination: FirstAidDetailView(tip: tip)) {
                        FirstAidRow(tip: tip)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("First Aid Tips")
        .searchable(text: $searchText, prompt: "Search tips")
    }
}

// MARK: - Row

private struct FirstAidRow: View {
    let tip: FirstAidTip
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tip.tintColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: tip.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tip.tintColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(tip.title)
                    .font(.headline)
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Detail

struct FirstAidDetailView: View {
    let tip: FirstAidTip
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                
                warningBanner
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Steps")
                        .font(.title3.bold())
                    
                    VStack(spacing: 10) {
                        ForEach(Array(tip.steps.enumerated()), id: \.offset) { index, step in
                            nextStepRow(number: index + 1, text: step, tint: tip.tintColor)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(tip.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(tip.tintColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: tip.iconName)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(tip.tintColor)
            }
            Text(tip.title)
                .font(.title.bold())
        }
        .frame(maxWidth: .infinity)
    }
    
    private var warningBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(tip.tintColor)
            Text(tip.description)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tip.tintColor.opacity(0.12))
        )
    }
}

private struct nextStepRow: View {
    let number: Int
    let text: String
    let tint: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Circle().fill(tint))
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    NavigationStack {
        FirstAidListView()
    }
}
