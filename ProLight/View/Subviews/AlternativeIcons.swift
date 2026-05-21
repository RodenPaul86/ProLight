//
//  AlternativeIcons.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import SwiftUI
import RevenueCat

enum IconAppearance: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
}

enum AppIcon: String, CaseIterable {
    case defaultIcon = "Default"
    case lowPower = "Low Power"
    case gradient = "Concept"
    case classic = "v1.0"
    case emerald = "Emerald Glow"
    case fusion = "Blue Fusion"
    case blaze = "Crimson Blaze"
    case mystic = "Mystic Shade"
    case ember = "Orange Ember"
    case eclipse = "Golden Eclipse"
    
    var iconValue: String? {
        self == .defaultIcon ? nil : rawValue
    }
    
    var baseImageName: String {
        switch self {
        case .defaultIcon: return "Image 0"
        case .emerald: return "Image 1"
        case .fusion: return "Image 2"
        case .blaze: return "Image 3"
        case .mystic: return "Image 4"
        case .ember: return "Image 5"
        case .eclipse: return "Image 6"
        case .lowPower: return "Image 10"
        case .classic: return "Image 11"
        case .gradient: return "Image 12"
        }
    }
    
    func previewImage(for appearance: IconAppearance) -> String {
        switch appearance {
        case .light:
            return baseImageName
        case .dark:
            return baseImageName + " Dark"
        }
    }
    
    static var mainIcons: [AppIcon] {
        [.defaultIcon, .lowPower]
    }
    
    static var classicIcons: [AppIcon] {
        [.classic]
    }
    
    static var unreleasedIcon: [AppIcon] {
        [.gradient]
    }
    
    static var otherIcons: [AppIcon] {
        [.emerald, .fusion, .blaze, .mystic, .ember, .eclipse]
    }
}

struct AlternativeIcons: View {
    @State private var currentAppIcon: AppIcon = .defaultIcon
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @State private var model: PaywallModel?
    @State private var showDefaultView: Bool = false
    @State private var isPaywallPresented: Bool = false
    @State private var hideTabBar: Bool = false
    @State private var appearance: IconAppearance = .light
    
    var body: some View {
        VStack {
            Picker("Appearance", selection: $appearance) {
                ForEach(IconAppearance.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                Section("Modern") {
                    ForEach(AppIcon.mainIcons, id: \.rawValue) { icon in
                        AppIconRow(icon: icon,
                                   currentAppIcon: $currentAppIcon,
                                   isSubscriptionActive: appSubModel.isSubscriptionActive,
                                   isPaywallPresented: $isPaywallPresented,
                                   appearance: appearance)
                    }
                }
                
                Section("Classic") {
                    ForEach(AppIcon.classicIcons, id: \.rawValue) { icon in
                        AppIconRow(icon: icon,
                                   currentAppIcon: $currentAppIcon,
                                   isSubscriptionActive: appSubModel.isSubscriptionActive,
                                   isPaywallPresented: $isPaywallPresented,
                                   appearance: appearance)
                    }
                }
                
                Section("Unreleased") {
                    ForEach(AppIcon.unreleasedIcon, id: \.rawValue) { icon in
                        AppIconRow(icon: icon,
                                   currentAppIcon: $currentAppIcon,
                                   isSubscriptionActive: appSubModel.isSubscriptionActive,
                                   isPaywallPresented: $isPaywallPresented,
                                   appearance: appearance)
                    }
                }
                
                Section("Other") {
                    ForEach(AppIcon.otherIcons, id: \.rawValue) { icon in
                        AppIconRow(icon: icon,
                                   currentAppIcon: $currentAppIcon,
                                   isSubscriptionActive: appSubModel.isSubscriptionActive,
                                   isPaywallPresented: $isPaywallPresented,
                                   appearance: appearance)
                    }
                }
            }
        }
        .navigationTitle("Alternate Icons")
        .navigationBarTitleDisplayMode(.inline)
        .hideFloatingTabBar(hideTabBar)
        .onAppear {
            hideTabBar = true
            // Check for the current icon on view appearance, and only reset if needed
            if let alternativeAppIcon = UIApplication.shared.alternateIconName,
               let appIcon = AppIcon.allCases.first(where: { $0.rawValue == alternativeAppIcon }) {
                currentAppIcon = appIcon
            } else {
                currentAppIcon = AppIcon.defaultIcon
            }
        }
        .alert(isPresented: $isPaywallPresented) {
            Alert(
                title: Text("Upgrade to Unlock"),
                message: Text("Unlock more app icons by subscribing!"),
                primaryButton: .default(Text("Subscribe")) {
                    isPaywallPresented = true
                },
                secondaryButton: .cancel()
            )
        }
        .fullScreenCover(isPresented: $isPaywallPresented) {
            CustomPaywallView(model: $model, showDefaultView: $showDefaultView)
        }
        .task {
            do {
                try await fetchPaywallData()
            } catch {
                print(error.localizedDescription)
                showDefaultView = true
            }
        }
    }
    
    func fetchPaywallData() async throws {
        guard let jsonDict = try await Purchases.shared.offerings().current?.metadata else {
            showDefaultView = true
            return
        }
        /// Converting into JSON Data
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        let model = try JSONDecoder().decode(PaywallModel.self, from: jsonData)
        self.model = model
        showDefaultView = model.showDefaultView
    }
}

struct AppIconRow: View {
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled: Bool = true
    let icon: AppIcon
    @Binding var currentAppIcon: AppIcon
    let isSubscriptionActive: Bool
    @Binding var isPaywallPresented: Bool
    let appearance: IconAppearance
    
    var body: some View {
        let isLocked = (icon != .defaultIcon && !isSubscriptionActive)
        let isSelected = (currentAppIcon == icon)
        
        HStack(spacing: 15) {
            ZStack {
                Image(icon.previewImage(for: appearance))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.theme.accent : Color(.systemGray6).gradient, lineWidth: 1)
                    )
            }
            
            Text(icon.rawValue)
                .fontWeight(.semibold)
            
            Spacer(minLength: 0)
            
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            } else {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.theme.accent : Color(.systemGray6).gradient)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            if !isLocked {
                currentAppIcon = icon
                UIApplication.shared.setAlternateIconName(icon.iconValue)
            } else {
                isPaywallPresented = true
            }
            if isHapticsEnabled {
                HapticManager.shared.notify(.impact(.light))
            }
        }
    }
}

#Preview {
    AlternativeIcons()
}
