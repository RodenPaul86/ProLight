//
//  SettingsView.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import WebKit

struct SettingsView: View {
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("resetDatastore") private var resetDatastore: Bool = false
    @AppStorage("showTipsForTesting") private var showTipsForTesting: Bool = false
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled: Bool = true
    @AppStorage("isCampingEnabled") private var isCampingEnabled: Bool = false
    @AppStorage("preferredTempUnit") private var selectedUnitRaw: String = TemperatureUnit.fahrenheit.rawValue
    @AppStorage("selectedButtonSound") private var selectedButtonSound: Bool = true
    @State private var resetOnboarding: Bool = false
    
    @State private var showDebug: Bool = false
    @State private var debugMessage: String = ""
    @State private var isPaywallPresented: Bool = false
    @State private var isPresentedManageSubscription: Bool = false
    @State private var model: PaywallModel?
    @State private var showDefaultView: Bool = false
    @State private var showStoreView = false
    @State private var hideTabBar: Bool = false
    
    var tabBarHeight: CGFloat?
    
    var selectedUnit: TemperatureUnit {
        TemperatureUnit(rawValue: selectedUnitRaw) ?? .fahrenheit
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !appSubModel.isSubscriptionActive {
                    customPremiumBanner {
                        isPaywallPresented = true
                        if isHapticsEnabled {
                            HapticManager.shared.notify(.notification(.success))
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: Text("General")) {
                    customRow(icon: "figure.walk", firstLabel: "Walking History", destination: AnyView(WorkoutHistoryView()))
                    customRow(icon: "tent", firstLabel: "Camping Tools", showToggle: true, toggleValue: $isCampingEnabled)
                }
                
                Section(header: Text("Customization")) {
                    customRow(icon: "questionmark.app.dashed", firstLabel: "Alternate Icons", destination: AnyView(AlternativeIcons()))
                    customRow(icon: "iphone.gen2.radiowaves.left.and.right", firstLabel: "In-App Haptics", showToggle: true, toggleValue: $isHapticsEnabled)
                    customRow(icon: "speaker.wave.2.fill", firstLabel: "Main Button Sound", showToggle: true, toggleValue: $selectedButtonSound)
                    customRow(icon: "thermometer", firstLabel: "Primary Units", showMenu: true, selectedOptionRaw: $selectedUnitRaw)
                }
                
                Section(header: Text("Support Us")) {
                    customRow(icon: "app.badge", firstLabel: "Release Notes", destination: AnyView(releaseNotesView()))
                    
                    if AppReviewRequest.showReviewButton, let url = AppReviewRequest.appURL(id: "id1173567157") {
                        customRow(icon: "star.bubble", firstLabel: "Rate & Review \(Bundle.main.appName)") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    customRow(icon: "point.3.filled.connected.trianglepath.dotted", firstLabel: "Share this App", shareURL: URL(string: "https://apps.apple.com/us/app/prolight/id1173567157"))
                    
                    //customRow(icon: "questionmark.bubble", firstLabel: "Frequently Asked Questions", destination: AnyView(FAQView()))
                    
                    customRow(icon: "envelope", firstLabel: "Contact Support", destination: AnyView(feedbackView()))
                }
                
                Section(header: Text("Info"), footer: Text("Help shape future updates of ProLight. Your feedback makes a difference!")) {
                    customRow(icon: "widget.small", firstLabel: "Install Widget", destination: AnyView(WidgetSetupView()))
                    customRow(icon: "rosette", firstLabel: "Acknowledgments", destination: AnyView(Acknowledgments()))
                    customRow(icon: "square.fill.text.grid.1x2", firstLabel: "More Apps") {
                        showStoreView.toggle()
                    }
                    
                    customRow(icon: "paperplane", firstLabel: "Join TestFlight (Beta)", url: "https://testflight.apple.com/join/8rtJj2JX", showJoinInsteadOfSafari: true)
                }
                
                Section(header: Text("Legal"), footer: Text("© 2016 - \(Date(), format: .dateTime.year()) Paul Roden Jr. All Rights Reserved, Made in USA 🇺🇸.")) {
                    customRow(icon: "hand.raised", firstLabel: "Privacy Policy", url: "https://docmatic.app/privacy.html")
                    customRow(icon: "doc.text", firstLabel: "Terms of Service", url: "https://docmatic.app/terms.html")
                    customRow(icon: "append.page", firstLabel: "EULA", url: "https://docmatic.app/EULA.html")
                }
#if DEBUG
                Section(header: Text("Debuging Tools"), footer: Text(debugMessage)) { /// <-- Display the debug message
                    
                    customRow(icon: "ladybug", firstLabel: "RC Debug Overlay") {
                        showDebug = true
                    }
                    
                    customRow(icon: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", firstLabel: "Reset Onboarding", showToggle: true, toggleValue: $resetOnboarding)
                        .onChange(of: resetOnboarding) { oldValue, newValue in
                            if newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    resetUserDefaults()
                                    resetOnboarding = false
                                    debugMessage = "Success!, Restart App."
                                }
                            }
                        }
                    
                    customRow(icon: "arrow.trianglehead.2.clockwise.rotate.90", firstLabel: "Reset Datastore", showToggle: true, toggleValue: $resetDatastore)
                        .onChange(of: resetDatastore) { oldValue, newValue in
                            if newValue {
                                debugMessage = "Success!, Restart App."
                            }
                        }
                    
                    customRow(icon: "lightbulb.max", firstLabel: "Show Tips For Testing", showToggle: true, toggleValue: $showTipsForTesting)
                        .onChange(of: showTipsForTesting) { oldValue, newValue in
                            if newValue {
                                debugMessage = "Success!, Restart App."
                            }
                        }
                }
#endif
            }
            .onAppear {
                hideTabBar = false
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if appSubModel.isSubscriptionActive {
                        Button(action: { isPresentedManageSubscription = true }) {
                            Image(systemName: "crown")
                        }
                    }
                }
            }
            .safeAreaPadding(.bottom, tabBarHeight)
            .hideFloatingTabBar(hideTabBar)
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
            .background(
                StoreProductPresenter(appStoreID: 693041126, isPresented: $showStoreView)
            )
            .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
            .debugRevenueCatOverlay(isPresented: $showDebug) /// <-- Disable this before sending for review.
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
    
    private func resetUserDefaults() {
        let keys = ["showIntroView"]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

#Preview {
    SettingsView(tabBarHeight: 0)
}

struct customRow: View {
    var icon: String
    var firstLabel: String
    var firstLabelColor: Color = .gray
    var secondLabel: String?
    var action: (() -> Void)? = nil
    var destination: AnyView? = nil
    var url: String? = nil
    var showToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil
    var showMenu: Bool = false
    var menuOptions: [String] = []
    var selectedOption: Binding<String?>? = nil
    var shareURL: URL? = nil
    var showJoinInsteadOfSafari: Bool? = nil
    var selectedOptionRaw: Binding<String>?
    
    @State private var isSharing: Bool = false
    
    // MARK: NEW: Safari sheet state
    @State private var selectedURL: IdentifiableURL?
    private struct IdentifiableURL: Identifiable {
        let id = UUID()
        let url: URL
    }
    
    var body: some View {
        Group {
            // MARK: URL → Present Safari Sheet
            if let urlString = url {
                rowContent(showChevron: true)
                    .onTapGesture {
                        if let link = URL(string: urlString) {
                            selectedURL = IdentifiableURL(url: link)
                        }
                    }
            }
            
            // MARK: Navigation destination (unchanged)
            else if let destination = destination {
                NavigationLink {
                    destination
                } label: {
                    rowContent(showChevron: false)
                }
                .buttonStyle(.plain)
            }
            
            // MARK: Toggle
            else if showToggle {
                rowContent(showChevron: false)
            }
            
            // MARK: Menu
            else if showMenu {
                rowContent(showChevron: false)
            }
            
            // MARK: Action / Share
            else {
                rowContent(showChevron: action != nil || shareURL != nil)
                    .onTapGesture {
                        if shareURL != nil {
                            isSharing = true
                        } else {
                            action?()
                        }
                    }
            }
        }
        
        // MARK: Share Sheet (unchanged)
        .sheet(isPresented: $isSharing) {
            if let shareURL = shareURL {
                ActivityView(activityItems: [shareURL])
                    .presentationDetents([.medium])
            }
        }
        
        // MARK: NEW: Safari Sheet
        .sheet(item: $selectedURL) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }
    
    private func rowContent(showChevron: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(firstLabel)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if showToggle, let binding = toggleValue {
                Toggle("", isOn: binding)
                    .labelsHidden()
            } else if showMenu, let binding = selectedOptionRaw {
                EnumSelectionMenu<TemperatureUnit>(
                    selection: binding,
                    displayName: { $0.displayName }
                )
            } else if showChevron {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .imageScale(.small)
                    .foregroundColor(Color(uiColor: .systemGray3))
            } else {
                Text(secondLabel ?? "")
                    .foregroundStyle(
                        (action == nil && destination == nil && url == nil && shareURL == nil)
                        ? .gray : .primary
                    )
            }
        }
        .contentShape(Rectangle())
    }
}

struct EnumSelectionMenu<T: CaseIterable & RawRepresentable & Identifiable & Equatable>: View where T.RawValue == String {
    var options: [T] = Array(T.allCases)
    @Binding var selection: String
    
    var displayName: (T) -> String
    
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(options) { option in
                Text(displayName(option))
                    .tag(option.rawValue)
            }
        }
        .tint(.gray)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: Custom Banner
struct customPremiumBanner: View {
    var onTap: () -> Void
    
    let features = [
        "Unlock all Features"
    ]
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Bundle.main.appName) Premium")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    ForEach(features, id: \.self) { feature in
                        Text("- \(feature)")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.7)
                    }
                    
                    Text("Subscribe")
                        .font(.footnote.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.theme.accent)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                ZStack {
                    Image(systemName: "power")
                        .font(.system(size: 70)) /// <-- Originally the size was 80
                        .foregroundStyle(.white.opacity(0.1))
                        .rotationEffect(.degrees(-20))
                        .scaleEffect(1.8) /// <-- Make it larger without affecting layout
                        .offset(x: -10, y: 20)
                        .allowsHitTesting(false) /// <-- Avoids affecting taps
                    
                    HStack {
                        Image(systemName: "laurel.leading")
                        Image(systemName: "laurel.trailing")
                    }
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.theme.background, Color.theme.background.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle()) /// <-- Prevents default blue button style
    }
}
