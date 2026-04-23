//
//  ScreenRedLightView.swift
//  ProLight
//
//  Created by Paul  on 4/22/26.
//

import SwiftUI

enum ScreenLightStyle {
    case red
    case white
}

struct ScreenLightView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var compassViewModel = CompassViewModel()
    
    @State private var isStrobing: Bool = false
    @State private var strobeVisible: Bool = true
    @State private var strobeTimer: Timer?
    
    let style: ScreenLightStyle
    @State private var useSolidColor: Bool = false
    @State private var savedBrightness: CGFloat?
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            VStack {
                Spacer()
                bottomContent
                    .ignoresSafeArea()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .statusBarHidden(false)
        .preferredColorScheme(.dark)
        .onAppear {
            maximizeBrightness()
        }
        .onDisappear {
            restoreBrightness()
            stopStrobe()
        }
    }
    
    private var backgroundLayer: some View {
        Group {
            if useSolidColor {
                solidColor
            } else {
                gradientColor
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                useSolidColor.toggle()
            }
        }
    }
    
    private var solidColor: some View {
        switch style {
        case .red:
            return AnyView(
                Color(red: 1.0, green: 0.08, blue: 0.05)
            )
        case .white:
            return AnyView(
                Color(.white)
            )
        }
    }
    
    private var gradientColor: some View {
        switch style {
        case .red:
            return AnyView(
                LinearGradient(
                    colors: [
                        .black,
                        Color.red.opacity(0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .white:
            return AnyView(
                LinearGradient(
                    colors: [
                        .black,
                        Color.white.opacity(0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private var screenDescription: String {
        switch style {
        case .red: return "Red light spectrum helps preserve human night vision by allowing our eyes to remain adjusted to the dark."
        case .white: return "Using your screen as a light source delivers bright, uniform illumination, making it easy to see clearly in dark or low light conditions."
        }
    }
    
    // MARK: Bottom Content
    private var bottomContent: some View {
        VStack(spacing: 24) {
            if !useSolidColor {
                Button(action: { toggleStrobe() }) {
                    Text(isStrobing ? "Stop" : "Strobe")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 86, height: 86)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                
                Text(screenDescription)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 20)
            }
            
            Button(action: { dismiss() }) {
                VStack(spacing: 4) {
                    Text("Close Screen")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(useSolidColor ? .gray : .white)
                    
                    Image(systemName: "chevron.compact.down")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(useSolidColor ? .gray : .white)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private func toggleStrobe() {
        isStrobing.toggle()
        
        if isStrobing {
            startStrobe()
        } else {
            stopStrobe()
        }
    }
    
    private func startStrobe() {
        stopStrobe()
        
        strobeTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { _ in
            strobeVisible.toggle()
        }
    }
    
    private func stopStrobe() {
        strobeTimer?.invalidate()
        strobeTimer = nil
        isStrobing = false
        strobeVisible = true
    }
    
    private func maximizeBrightness() {
        if savedBrightness == nil {
            savedBrightness = UIScreen.main.brightness
        }
        UIScreen.main.brightness = 1.0
    }
    
    private func restoreBrightness() {
        if let savedBrightness {
            UIScreen.main.brightness = savedBrightness
        }
    }
}

#Preview {
    ScreenLightView(style: .white)
}
