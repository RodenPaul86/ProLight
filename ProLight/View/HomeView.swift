//
//  HomeView.swift
//  ProLight
//
//  Created by Paul on 9/19/16.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import AVFoundation

struct HomeView: View {
    @StateObject private var flashControllerInstance = FlashController()
    @State private var brightnessLevel: Int = 4
    
    @State private var intensityLevel: Int = 1
    @State private var flashlightOn: Bool = true
    @State private var isStrobeModeOn: Bool = false
    @State private var isLockedPower: Bool = false
    @State private var strobePressed: Bool = false
    @State private var sosPressed: Bool = false
    @State private var showSecondSlider: Bool = false
    
    @State private var selectedLevel: Int = 4
    @State private var selectedStrobeLevel: Int = 4
    @State private var selectedFrequency: Double? = nil
    
    @State private var selectedFrequencies: Set<Double> = []
    
    @State private var selectedMaxFrequency: Double? = nil
    
    let maxLevel: Int = 4
    let frequencies: [Int: Double] = [1: 2.0, 2: 3.0, 3: 6.0, 4: 10.0]
    var tabBarHeight: CGFloat
    
    let strobeData: [(label: String, frequency: Double, ppm: Int)] = [
        ("15 Hz", 15.0, 900),
        ("10 Hz", 10.0, 600),
        ("6 Hz", 6.0, 360),
        ("3 Hz", 3.0, 180),
        ("2 Hz", 2.0, 120)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                flashlightIndicator
                brightnessSliders
                modeButtons
            }
            .onAppear {
                updateTorch()
            }
            .onDisappear {
                flashControllerInstance.stopFlashing()
            }
            .padding()
            .safeAreaPadding(.bottom, tabBarHeight)
        }
    }
    
    private var flashlightIndicator: some View {
        VStack(spacing: 8) {
            if flashlightOn {
                let scaledOpacity = Double(brightnessLevel) / Double(maxLevel)
                let shadowRadius = 5 + (15 * scaledOpacity)
                
                Image(systemName: "flashlight.on.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 50)
                    .foregroundColor(Color.white.opacity(scaledOpacity))
                    .shadow(color: .white.opacity(scaledOpacity), radius: shadowRadius)
            } else {
                Image(systemName: "flashlight.off.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 50)
                    .foregroundColor(.white.opacity(0.1))
            }
        }
    }
    
    private var brightnessSliders: some View {
        HStack(alignment: .top, spacing: 50) {
            // MARK: Flashlight Slider
            VStack(spacing: 10) {
                VStack(spacing: 5) {
                    curvedRectangle(topRadius: 40, bottomRadius: 5)
                        .fill(!flashlightOn ? Color.gray.opacity(0.3) : (brightnessLevel == maxLevel ? Color.white : Color.gray.opacity(0.3)))
                        .frame(width: 125, height: 80)
                        .onTapGesture {
                            flashlightOn = true
                            brightnessLevel = maxLevel
                            updateTorch()
                        }
                    
                    ForEach((1..<(maxLevel)).reversed(), id: \.self) { level in
                        RoundedRectangle(cornerRadius: 5)
                            .fill(!flashlightOn ? Color.gray.opacity(0.3) : (level <= brightnessLevel ? Color.white : Color.gray.opacity(0.3)))
                            .frame(width: 125, height: 80)
                            .onTapGesture {
                                flashlightOn = true
                                brightnessLevel = level
                                updateTorch()
                            }
                    }
                }
                powerButton
                lockHint
            }
            .animation(.easeInOut(duration: 0.3), value: showSecondSlider)
            .offset(x: showSecondSlider ? 0 : 111)
            
            // MARK: Strobe Slider
            VStack(spacing: 6) {
                ForEach(0..<strobeData.count, id: \.self) { index in
                    let item = strobeData[index]
                    let isTop = index == 0
                    let isBottom = index == strobeData.count - 1
                    
                    HStack {
                        // Frequency Label
                        Text(item.label)
                            .foregroundColor(.white)
                            .font(.caption2)
                            .frame(width: 40, alignment: .leading)
                        
                        // Strobe Bar
                        curvedRectangle(topRadius: isTop ? 40 : 5, bottomRadius: isBottom ? 40 : 5)
                            .fill(item.frequency <= (selectedMaxFrequency ?? 0) ? Color("strobeHzColor") : Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .onTapGesture {
                                flashlightOn = true
                                selectedMaxFrequency = item.frequency // Light up all ≤ this frequency

                                flashControllerInstance.startFlashing(
                                    frequencyHz: item.frequency,
                                    intensity: Float(brightnessLevel) / Float(maxLevel)
                                )
                            }
                        
                        // PPM Label
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(item.ppm)")
                                .foregroundColor(.white)
                                .font(.caption)
                            Text("ppm")
                                .foregroundColor(.white)
                                .font(.caption)
                                .italic()
                        }
                        .frame(width: 40, alignment: .leading)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSecondSlider)
            .offset(x: showSecondSlider ? 0 : 200)
        }
    }
    
    private func sliderSegment(level: Int, fillColor: Color) -> some View {
        let shape: AnyShape = level == maxLevel ? AnyShape(curvedRectangle(topRadius: 40, bottomRadius: 5)) : AnyShape(RoundedRectangle(cornerRadius: 5))
        
        return shape
            .fill(fillColor)
            .frame(width: 125, height: 80)
            .onTapGesture {
                flashlightOn = true
                brightnessLevel = level
                updateTorch()
            }
    }
    
    private var powerButton: some View {
        ZStack {
            curvedRectangle(topRadius: 0, bottomRadius: 40)
                .fill(Color("darkColor"))
                .frame(width: 125, height: 90)
                .offset(y: 35)
            
            curvedRectangle(topRadius: 5, bottomRadius: 40)
                .fill(Color("powerBtn"))
                .frame(width: 125, height: 90)
            
            VStack {
                Image(systemName: "power")
                    .font(.system(size: isLockedPower ? 20 : 40))
                    .foregroundStyle(Color("textColor"))
                    .padding(.bottom, isLockedPower ? 5 : 0)
                
                if isLockedPower {
                    Text("Double Tap")
                        .font(.caption.bold())
                        .foregroundStyle(Color("textColor"))
                    Text("to turn off")
                        .font(.caption)
                        .foregroundStyle(Color("textColor"))
                }
            }
        }
        .onTapGesture {
            flashlightOn.toggle()
            brightnessLevel = maxLevel
            
            if flashlightOn {
                if showSecondSlider {
                    // Restore strobe flashing at last selected frequency
                    let frequency = selectedMaxFrequency ?? 2.0 // fallback to 2Hz
                    selectedMaxFrequency = frequency // ensure UI stays lit
                    flashControllerInstance.startFlashing(
                        frequencyHz: frequency,
                        intensity: Float(brightnessLevel) / Float(maxLevel)
                    )
                } else {
                    updateTorch() // fallback to regular flashlight
                }
            } else {
                flashControllerInstance.stopFlashing()
            }
        }
        .onLongPressGesture(minimumDuration: 1) {
            isLockedPower.toggle()
        }
    }
    
    private var lockHint: some View {
        HStack {
            Text("Hold to")
            Image(systemName: isLockedPower ? "lock.open.fill" : "lock.fill")
        }
        .font(.caption)
        .foregroundStyle(Color("textColor"))
    }
    
    private var modeButtons: some View {
        HStack(spacing: 13) {
            modeButton(title: "SOS", subtitle: "Emergency\nLight Pattern", BGColor: sosPressed ? .red : Color("darkColor"), width: 140, height: 70)
                .onTapGesture { sosPressed.toggle() }
            
            modeButton(title: "Screen", width: 100, height: 70)
            
            modeButton(title: "Strobe", BGColor: strobePressed ? .blue : Color("darkColor"), width: 100, height: 70)
                .onTapGesture {
                    strobePressed.toggle()
                    showSecondSlider.toggle()
                    
                    if strobePressed {
                        flashlightOn = true
                        brightnessLevel = maxLevel
                        
                        // Set 2Hz as the default selected frequency
                        selectedFrequency = 2.0
                        selectedMaxFrequency = 2.0
                        
                        flashControllerInstance.startFlashing(
                            frequencyHz: frequencies[intensityLevel] ?? 2.0,
                            intensity: Float(brightnessLevel) / Float(maxLevel)
                        )
                    } else {
                        flashlightOn = false
                        flashControllerInstance.stopFlashing()
                    }
                }
        }
    }
    
    private func modeButton(title: String, subtitle: String? = nil, BGColor: Color = Color("darkColor"), width: CGFloat = 80, height: CGFloat = 60) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 5)
        .frame(width: width, height: height, alignment: .center)
        .background(BGColor)
        .cornerRadius(20)
    }
    
    private func updateTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            if flashlightOn {
                let level = Float(brightnessLevel) / Float(maxLevel)
                
                if showSecondSlider {
                    // Update strobe brightness
                    flashControllerInstance.updateBrightness(level: level)
                } else {
                    // Regular flashlight brightness
                    try device.setTorchModeOn(level: level)
                }
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch update error: \(error)")
        }
    }
}

#Preview {
    ContentView()
}

struct curvedRectangle: Shape {
    var topRadius: CGFloat
    var bottomRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topR = min(topRadius, rect.width / 2, rect.height / 2)
        let bottomR = min(bottomRadius, rect.width / 2, rect.height / 2)
        
        path.move(to: CGPoint(x: rect.minX + topR, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topR, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + topR), control: CGPoint(x: rect.maxX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomR))
        path.addArc(center: CGPoint(x: rect.maxX - bottomR, y: rect.maxY - bottomR), radius: bottomR, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.minX + bottomR, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomR, y: rect.maxY - bottomR), radius: bottomR, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topR))
        path.addQuadCurve(to: CGPoint(x: rect.minX + topR, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        
        path.closeSubpath()
        return path
    }
}

struct AnyShape: Shape {
    private let pathClosure: (CGRect) -> Path
    
    init<S: Shape>(_ wrapped: S) {
        self.pathClosure = wrapped.path(in:)
    }
    
    func path(in rect: CGRect) -> Path {
        pathClosure(rect)
    }
}
