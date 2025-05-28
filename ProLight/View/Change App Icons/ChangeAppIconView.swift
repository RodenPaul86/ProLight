//
//  ChangeAppIconView.swift
//  ProLight
//
//  Created by Paul on 6/23/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct ChangeAppIconView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("active_icon") var activeAppIcon: String = "AppIcon"
    @State private var isPresentingPaywall = false
    
    var backToMAinVC: HomeVC?
    
    private let iconMappings: [String: String] = [
        "Altericon0": "Emerald Glow",
        "Altericon1": "Blue Fusion",
        "Altericon2": "Crimson Blaze",
        "Altericon3": "Mystic Shade",
        "Altericon4": "Orange Ember",
        "Altericon5": "Golden Eclipse"
    ]
    
    private let unlockedIcons: [String] = ["Altericon0", "Altericon1"]
    
    private let customIconOrder: [String] = ["Altericon0", "Altericon1", "Altericon2", "Altericon3", "Altericon4", "Altericon5"]
    // Customize the order of icons based on your preference
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationView {
                List {
                    Section(header: Text("ProLight Icons")) {
                        ForEach(customIconOrder, id: \.self) { iconName in
                            if let customName = iconMappings[iconName] {
                                iconRow(iconName: iconName, customName: customName)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("App Icons", displayMode: .inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .foregroundColor(.green)
                                .bold()
                        }
                    }
                })
                .onChange(of: activeAppIcon) { newValue in
                    UIApplication.shared.setAlternateIconName(newValue)
                }
            }
        } else {
            // Fallback on earlier versions
            Text("App Icon customization is only available on iOS 16.0")
        }
    }
    
    private func iconRow(iconName: String, customName: String) -> some View {
        let isCurrentIcon = iconName == activeAppIcon
        let isUnlocked = unlockedIcons.contains(iconName) || IAPManager.shared.isPremium()
        
        return HStack {
            iconImage(for: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .cornerRadius(15)
            
            Text(customName)
                .font(.body)
                .padding(.leading, 10)
            
            Spacer()
            
            if isCurrentIcon {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            } else if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.red)
            }
        }
        .tag(iconName)
        .contentShape(Rectangle())
        .onTapGesture {
            if isUnlocked || isCurrentIcon {
                activeAppIcon = iconName
            } else {
                isPresentingPaywall = true
            }
        }
        .sheet(isPresented: $isPresentingPaywall) {
            payWall().preferredColorScheme(.dark)
        }
    }
    
    private func iconImage(for iconName: String) -> Image {
        switch iconName {
        case "Altericon0":
            return Image("App_00")
        case "Altericon1":
            return Image("App_01")
        case "Altericon2":
            return Image("App_02")
        case "Altericon3":
            return Image("App_03")
        case "Altericon4":
            return Image("App_04")
        case "Altericon5":
            return Image("App_05")
        default:
            return Image(systemName: "questionmark")
        }
    }
}

struct ChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAppIconView()
    }
}
