//
//  adBannerView.swift
//  ProLight
//
//  Created by Paul  on 5/27/26.
//

import SwiftUI
import RevenueCat

struct adBannerView: View {
    private let images = ["banner1"]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled: Bool = true
    @State private var isPaywallPresented: Bool = false
    @State private var showDefaultView: Bool = false
    @State private var model: PaywallModel?
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .clipped()
                    .tag(index)
                    .onTapGesture {
                        isPaywallPresented = true
                        if isHapticsEnabled {
                            HapticManager.shared.notify(.impact(.light))
                        }
                    }
            }
        }
        .frame(height: 50)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % images.count
            }
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
