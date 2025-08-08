//
//  SettingsView.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import SwiftUI
import RevenueCat
import WebKit

struct SettingsView: View {
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("resetDatastore") private var resetDatastore: Bool = false
    @AppStorage("showTipsForTesting") private var showTipsForTesting: Bool = false
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled: Bool = true
    @AppStorage("preferredTempUnit") private var selectedUnitRaw: String = TemperatureUnit.fahrenheit.rawValue
    @AppStorage("dateRangeOption") private var dateRangeOptionRaw: String = DateRangeOption.day.rawValue
    @State private var resetOnboarding: Bool = false
    
    @State private var showDebug: Bool = false
    @State private var debugMessage: String = ""
    @State private var isPaywallPresented: Bool = false
    @State private var isPresentedManageSubscription: Bool = false
    @State private var showStoreView = false
    @State private var hideTabBar: Bool = false
    
    var tabBarHeight: CGFloat
    
    var selectedUnit: TemperatureUnit {
        TemperatureUnit(rawValue: selectedUnitRaw) ?? .fahrenheit
    }
    
    var dateRangeOption: DateRangeOption {
        DateRangeOption(rawValue: dateRangeOptionRaw) ?? .day
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
                }
                
                Section(header: Text("Customization")) {
                    customRow(icon: "questionmark.app.dashed", firstLabel: "Alternate Icons", destination: AnyView(AlternativeIcons()))
                    customRow(icon: "iphone.gen2.radiowaves.left.and.right", firstLabel: "In-App Haptics", showToggle: true, toggleValue: $isHapticsEnabled)
                    customRow(icon: "thermometer", firstLabel: "Primary Units", showMenu: true, selectedOptionRaw: $selectedUnitRaw)
                    customRow(icon: "calendar", firstLabel: "Data Range", showMenu: true, selectedOptionRaw: $dateRangeOptionRaw)
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
                
                Section(header: Text("Info"), footer: Text("Help shape future updates of DocMatic. Your feedback makes a difference!")) {
                    customRow(icon: "list.clipboard", firstLabel: "About", destination: AnyView(aboutView()))
                    if appSubModel.isSubscriptionActive {
                        customRow(icon: "crown", firstLabel: "Manage Subscription") {
                            isPresentedManageSubscription = true
                        }
                    }
                    customRow(icon: "widget.small", firstLabel: "Install Widget", destination: AnyView(WidgetSetupView()))
                    customRow(icon: "square.fill.text.grid.1x2", firstLabel: "More Apps") {
                        showStoreView.toggle()
                    }
                    
                    customRow(icon: "paperplane", firstLabel: "Join TestFlight (Beta)", url: "https://testflight.apple.com/join/8rtJj2JX", showJoinInsteadOfSafari: true)
                }
                
                Section(header: Text("Legal")) {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        Button(action: { dismiss() }) {
                            Text("Done")
                                .foregroundStyle(Color.theme.accent)
                        }
                    }
                }
            }
            .safeAreaPadding(.bottom, tabBarHeight)
            .hideFloatingTabBar(hideTabBar)
            .fullScreenCover(isPresented: $isPaywallPresented) {
                SubscriptionView(isPaywallPresented: $isPaywallPresented)
                    .preferredColorScheme(.dark)
            }
            .background(
                StoreProductPresenter(appStoreID: 693041126, isPresented: $showStoreView)
            )
            .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
            .debugRevenueCatOverlay(isPresented: $showDebug) /// <-- Disable this before sending for review.
        }
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
    var action: (() -> Void)? = nil  /// <-- Optional action
    var destination: AnyView? = nil  /// <-- Optional navigation
    var url: String? = nil           /// <-- Optional URL
    var showToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil /// <-- Optional toggle switch
    var showMenu: Bool = false
    var menuOptions: [String] = []
    var selectedOption: Binding<String?>? = nil
    var shareURL: URL? = nil             /// <-- Optional share link
    var showJoinInsteadOfSafari: Bool? = nil
    //@EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    var selectedOptionRaw: Binding<String>?
    
    
    @State private var isNavigating: Bool = false
    @State private var isSharing: Bool = false
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        Group {
            if let urlString = url {
                NavigationLink {
                    webView(url: urlString)
                        .onAppear {
                            hideTabBar = true
                        }
                        .hideFloatingTabBar(hideTabBar)
                        .edgesIgnoringSafeArea(.all)
                        .navigationTitle(firstLabel)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if let link = URL(string: urlString) {
                                    Link(destination: link) {
                                        if showJoinInsteadOfSafari ?? false {
                                            Text("Join")
                                                .fontWeight(.bold)
                                        } else {
                                            Image(systemName: "safari")
                                        }
                                    }
                                }
                            }
                        }
                } label: {
                    rowContent(showChevron: false)
                }
                .buttonStyle(.plain)
            } else if let destination = destination {
                NavigationLink {
                    destination
                } label: {
                    rowContent(showChevron: false)
                }
                .buttonStyle(.plain)
            } else if showToggle {
                rowContent(showChevron: false)
            } else if showMenu {
                rowContent(showChevron: false)
            } else {
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
        .sheet(isPresented: $isSharing) {
            if let shareURL = shareURL {
                ActivityView(activityItems: [shareURL])
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func rowContent(showChevron: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18)) /// <-- Fixed size, unaffected by user settings
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
                EnumSelectionMenu<DateRangeOption>(
                    selection: binding, displayName: { $0.displayName }
                )
            } else if showChevron {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .imageScale(.small)
                    .foregroundColor(Color.init(uiColor: .systemGray3))
            } else {
                Text(secondLabel ?? "")
                    .foregroundStyle((action == nil && destination == nil && url == nil && shareURL == nil) ? .gray : .primary)
            }
        }
        .contentShape(Rectangle())
    }
    
    private func isWebsite(_ urlString: String) -> Bool {
        return urlString.hasPrefix("http")
    }
}

struct EnumSelectionMenu<T: CaseIterable & RawRepresentable & Identifiable & Equatable>: View where T.RawValue == String {
    var options: [T] = Array(T.allCases)
    @Binding var selection: String
    
    var displayName: (T) -> String
    
    var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    selection = option.rawValue
                } label: {
                    HStack {
                        Text(displayName(option))
                        if selection == option.rawValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            if let selectedEnum = options.first(where: { $0.rawValue == selection }) {
                HStack {
                    Text(displayName(selectedEnum))
                    Image(systemName: "chevron.up.chevron.down") /// <-- Chevron next to text
                }
                .foregroundColor(.secondary)
            }
        }
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

// MARK: WebView
struct webView: UIViewRepresentable {
    var url: String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
    }
}

// MARK: Custom Banner
struct customPremiumBanner: View {
    var onTap: () -> Void
    
    let features = [
        "Unlimited Scans",
        "Remove Watermark"
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
