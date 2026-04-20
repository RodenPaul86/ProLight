//
//  AlternativeIcons.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import SwiftUI
import RevenueCat

enum AppIcon: String, CaseIterable {
    case defaultIcon = "Default"
    case v2 = "v2.0"
    case v1 = "v1.0"
    case fusion = "Fusion"
    case blaze = "Blaze"
    case mystic = "Mystic"
    case ember = "Ember"
    case eclipse = "Eclipse"
    
    var iconValue: String? {
        self == .defaultIcon ? nil : rawValue
    }
    
    var previewImage: String {
        switch self {
        case .defaultIcon: "Image 0"
        case .fusion: "Image 1"
        case .blaze: "Image 2"
        case .mystic: "Image 3"
        case .ember: "Image 4"
        case .eclipse: "Image 5"
        case .v1: ""
        case .v2: ""
        }
    }
    
    static var mainIcons: [AppIcon] {
        [.defaultIcon, .v2, .v1]
    }
    
    static var warmIcons: [AppIcon] {
        [.fusion, .blaze, .mystic, .ember, .eclipse]
    }
}

struct AlternativeIcons: View {
    @State private var currentAppIcon: AppIcon = .defaultIcon
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @State private var model: PaywallModel?
    @State private var showDefaultView: Bool = false
    @State private var isPaywallPresented: Bool = false
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        VStack {
            List {
                Section("") {
                    ForEach(AppIcon.mainIcons, id: \.rawValue) { icon in
                        AppIconRow(
                            icon: icon,
                            currentAppIcon: $currentAppIcon,
                            isSubscriptionActive: appSubModel.isSubscriptionActive,
                            isPaywallPresented: $isPaywallPresented
                        )
                    }
                }
                
                Section("") {
                    ForEach(AppIcon.warmIcons, id: \.rawValue) { icon in
                        AppIconRow(
                            icon: icon,
                            currentAppIcon: $currentAppIcon,
                            isSubscriptionActive: appSubModel.isSubscriptionActive,
                            isPaywallPresented: $isPaywallPresented
                        )
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
    
    var body: some View {
        let isLocked = (icon != .defaultIcon && !isSubscriptionActive)
        let isSelected = (currentAppIcon == icon)
        
        HStack(spacing: 15) {
            ZStack {
                Image(icon.previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
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
