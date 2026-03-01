//
//  HomeView.swift
//  ProLight
//
//  Created by Paul on 9/19/16.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import AVFoundation
import WeatherKit
import CoreLocation
import ActivityKit

// MARK: - Control State
enum ControlMode {
    case neutral
    case sos
    case strobe
    case camping
}

// MARK: - SOS State
enum SOSState: Equatable {
    case idle
    case countdown(Int)
    case sounding
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var flashControllerInstance = FlashController()
    @State private var brightnessLevel: Int = 4
    
    @State private var intensityLevel: Int = 1
    @State private var flashlightOn: Bool = true
    @State private var isLockedPower: Bool = false
    @State private var showSecondSlider: Bool = false
    @State private var strobePressed: Bool = false
    @State private var sosPressed: Bool = false
    @State private var campingPressed: Bool = false
    @State private var aiPressed: Bool = false
    
    @State private var selectedLevel: Int = 4
    @State private var selectedFrequency: Double? = nil
    @State private var selectedMaxFrequency: Double? = nil
    
    @State private var sosState: SOSState = .idle
    @State private var countdownTimer: Timer?
    
    @State private var countdownValue = 3
    @State private var glow = false
    
    @StateObject private var locationManager = LocationManager()
    @AppStorage("preferredTempUnit") private var selectedUnitRaw: String = TemperatureUnit.fahrenheit.rawValue
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled: Bool = true
    @AppStorage("isAssistantEnabled") private var isAssistantEnabled: Bool = true
    
    @State private var showWeatherSheet: Bool = false
    @State private var showSignalingMirrorSheet: Bool = false
    
    var selectedUnit: TemperatureUnit {
        TemperatureUnit(rawValue: selectedUnitRaw) ?? .fahrenheit
    }
    
    @State private var mode: ControlMode = .neutral
    
    var tabBarHeight: CGFloat
    @State private var hideTabBar: Bool = false
    
    var scaledOpacity: Double {
        Double(brightnessLevel) / Double(maxLevel)
    }
    var shadowRadius: Double {
        5 + (15 * scaledOpacity)
    }
    
    private let toneEngine = EmergencyToneEngine()
    
    let maxLevel: Int = 4
    let frequencies: [Int: Double] = [1: 2.0, 2: 3.0, 3: 6.0, 4: 10.0]
    
    let strobeData: [(label: String, frequency: Double, ppm: Int)] = [
        ("15 Hz", 15.0, 900),
        ("10 Hz", 10.0, 600),
        ("6 Hz", 6.0, 360),
        ("3 Hz", 3.0, 180),
        ("2 Hz", 2.0, 120)
    ]
    
    var sosOffset: CGFloat {
        switch mode {
        case .sos:
            return -120 // visible position
        default:
            return -400 // hidden offscreen to the left
        }
    }
    
    var flashlightOffset: CGFloat {
        switch mode {
        case .neutral:
            return 0 // centered
        case .sos:
            return 100 // shift right when SOS is shown
        case .strobe:
            return -100 // shift left when strobe is shown
        case .camping:
            return 0
        }
    }
    
    var strobeOffset: CGFloat {
        switch mode {
        case .strobe:
            return 100 // visible position
        default:
            return 400 // hidden offscreen to the right
        }
    }
    
    var campingOffsetLeft: CGFloat {
        switch mode {
        case .camping:
            return -220
        default:
            return -400
        }
    }
    
    var campingOffsetRight: CGFloat {
        switch mode {
        case .camping:
            return 220
        default:
            return 400
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 40) {
                    Spacer()
                    // MARK: Camping Functions
                    ZStack(alignment: .top) {
                        sosView
                            .offset(x: sosOffset)
                        
                        // Camping buttons from LEFT
                        VStack(spacing: 20) {
                            campingButton(icon: "tent", title: "Poisonous Plants", color: .green, rotation: 90, destination: PoisonousPlantsEntryView())
                            campingButton(icon: "flame.fill", title: "Morse Code", color: .orange, rotation: 90, destination: MorseTranslatorWithAudioView())
                        }
                        .offset(x: campingOffsetLeft)
                        
                        flashlightView
                            .offset(x: flashlightOffset)
                        
                        // Camping buttons from RIGHT
                        VStack(spacing: 20) {
                            campingButton(icon: "drop.fill", title: "Bug Repellent", color: .blue, rotation: -90, destination: UltrasonicRepellentView())
                            campingButton(icon: "binoculars.fill", title: "First Aid", color: .red, rotation: -90, destination: FirstAidListView())
                        }
                        .offset(x: campingOffsetRight)
                            
                        strobeView
                            .offset(x: strobeOffset)
                    }
                    .animation(.easeInOut(duration: 0.3), value: mode)
                    modeButtons
                }
                .overlay (
                    HStack(alignment: .top) {
                        if let weather = locationManager.currentWeather {
                            let temp = selectedUnit == .fahrenheit
                            ? weather.temperature.converted(to: .fahrenheit)
                            : weather.temperature.converted(to: .celsius)
                            
                            VStack(alignment: .leading) {
                                if !locationManager.cityName.isEmpty {
                                    Text("\(locationManager.cityName), \(locationManager.stateName)")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                } else {
                                    Text("Loading...")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                
                                Text("\(Int(temp.value))°")
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                
                                Text(weather.condition.description)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .onTapGesture {
                                showWeatherSheet = true
                            }
                            .sheet(isPresented: $showWeatherSheet) {
                                WeatherView()
                                    .presentationDetents([.fraction(0.50)]) // 50% of screen height
                                    .presentationDragIndicator(.visible) // Shows the line at top
                            }
                        }
                        Spacer()
                        CompassView()
                            .frame(width: 65, height: 65)
                    }
                        .padding(.leading)
                        .padding(.top, -10),
                    alignment: .topLeading
                )
                .padding()
                .safeAreaPadding(.bottom, tabBarHeight)
                .hideFloatingTabBar(sosPressed ? true : false)
                
                VStack {
                    Spacer()
                    Text("The SOS mode is designed to be used in situations of potential harm and should not be used deliberately.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .opacity(sosPressed ? 1 : 0)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .onAppear {
            updateTorch()
            NotificationManager.shared.requestAuthorization()
            hideTabBar = false
        }
        .onDisappear {
            flashControllerInstance.stopFlashing()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                print("App moved to background")
                
                // Only needed if you DO NOT want torch in background
                // setTorch(active: false)
                
            case .active:
                // App became active again
                print("App became active")
                updateTorch()
                
            case .inactive:
                //App going inactive (home button, app switcher)
                print("App inactive")
                
            @unknown default:
                break
            }
        }
    }
    
    /*
    // MARK: Flashlight Indicator
    private var flashlightIndicator: some View {
        VStack(spacing: 8) {
            let scaledOpacity = Double(brightnessLevel) / Double(maxLevel)
            let shadowRadius = 5 + (15 * scaledOpacity)
            
            Image(systemName: flashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 50)
                .foregroundColor(flashlightOn ? .white.opacity(scaledOpacity) : .white.opacity(0.1))
                .shadow(color: flashlightOn ? .white.opacity(scaledOpacity) : .white.opacity(0.0), radius: shadowRadius)
        }
    }
     */
    
    // MARK: SOS View
    private var sosView: some View {
        VStack(spacing: 10) {
            if let number = locationManager.emergencyNumber {
                // Call Emergency Services Button
                Button(action: {
                    if let url = URL(string: "tel://\(number)"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    print("Phone number: \(number)")
                }) {
                    curvedRectangle(topRadius: 40, bottomRadius: 0)
                        .fill(.green.opacity(0.2))
                        .rotationEffect(.degrees(90))
                        .frame(width: 200, height: 200)
                        .overlay {
                            VStack(spacing: 25) {
                                VStack(spacing: 5) {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.green)
                                    
                                    Text("Call Emergency \nServices")
                                        .bold()
                                        .foregroundStyle(.white)
                                }
                                
                                HStack {
                                    Text("Tap to call")
                                        .font(.system(size: 14).bold())
                                        .foregroundStyle(.white.opacity(0.5))
                                    
                                    Image(systemName: "chevron.compact.right")
                                        .font(.system(size: 14).bold())
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                        }
                }
            } else {
                curvedRectangle(topRadius: 40, bottomRadius: 0)
                    .fill(.green.opacity(0.2))
                    .rotationEffect(.degrees(90))
                    .frame(width: 200, height: 200)
                    .overlay {
                        VStack(spacing: 25) {
                            VStack(spacing: 5) {
                                Image(systemName: "phone.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.green)
                                
                                Text("Call Emergency \nServices")
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                            
                            ProgressView("Detecting your location…")
                                .font(.system(size: 14).bold())
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
            }
            
            // Signaling Mirror Instructions Button
            Button(action: { showSignalingMirrorSheet = true }) {
                curvedRectangle(topRadius: 40, bottomRadius: 0)
                    .fill(.gray.opacity(0.2))
                    .rotationEffect(.degrees(90))
                    .frame(width: 200, height: 200)
                    .overlay {
                        VStack(spacing: 25) {
                            Label("Requires clear sky",systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(.gray.opacity(0.5))
                            
                            VStack(spacing: 5) {
                                Image(systemName: "iphone.landscape")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.white)
                                    .overlay {
                                        ZStack {
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 10, height: 10)
                                            
                                            Image(systemName: "sun.max.circle.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                        .offset(x: 14, y: -8) // x = side to side and y = up and down
                                    }
                                
                                Text("Signaling \nMirror")
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                            
                            HStack {
                                Text("Instructions")
                                    .font(.system(size: 14).bold())
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                Image(systemName: "chevron.compact.right")
                                    .font(.system(size: 14).bold())
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
            }
            .sheet(isPresented: $showSignalingMirrorSheet) {
                SignalingMirrorView()
                    .presentationDetents([.fraction(0.50)]) /// <-- 50% of screen height
                    .presentationDragIndicator(.visible) /// <-- Shows the line at top
            }
        }
    }
    
    // MARK: Flashlight controls
    private var flashlightView: some View {
        VStack(spacing: 10) {
            VStack(spacing: 5) {
                curvedRectangle(topRadius: 40, bottomRadius: 5)
                    .fill(!flashlightOn ? Color.gray.opacity(0.2) : (brightnessLevel == maxLevel ? Color.white : Color.gray.opacity(0.2)))
                    .frame(width: 125, height: 80)
                    .onTapGesture {
                        guard !isLockedPower else { return }
                        HapticManager.shared.notify(.impact(.light))
                        flashlightOn = true
                        brightnessLevel = maxLevel
                        updateTorch()
                    }
                    .disabled(mode == .sos || mode == .strobe || isLockedPower)
                
                if sosPressed {
                    Button(action: { handleSOSAction() }) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(backgroundColor)
                            .frame(width: 125, height: 250)
                            .overlay(content)
                            .overlay(glowOverlay)
                            .animation(.easeInOut, value: sosState)
                    }
                } else {
                    ForEach((1..<(maxLevel)).reversed(), id: \.self) { level in
                        RoundedRectangle(cornerRadius: 5)
                            .fill(!flashlightOn ? Color.gray.opacity(0.2) : (level <= brightnessLevel ? Color.white : Color.gray.opacity(0.2)))
                            .frame(width: 125, height: 80)
                            .onTapGesture {
                                guard !isLockedPower else { return }
                                HapticManager.shared.notify(.impact(.light))
                                flashlightOn = true
                                brightnessLevel = level
                                updateTorch()
                            }
                            .disabled(mode == .strobe || isLockedPower)
                    }
                }
            }
            .shadow(color: .white.opacity(flashlightOn ? scaledOpacity : 0.1), radius: sosPressed ? 0 : shadowRadius)
            
            powerButton
            lockHint
        }
    }
    
    // MARK: Strobe View and Controls
    private var strobeView: some View {
        VStack(spacing: 6) {
            ForEach(0..<strobeData.count, id: \.self) { index in
                let item = strobeData[index]
                let isTop = index == 0
                let isBottom = index == strobeData.count - 1
                
                HStack {
                    // Frequency Label
                    Text("\(item.label) ·")
                        .foregroundColor(item.frequency == selectedMaxFrequency ? .white : Color.gray.opacity(0.2))
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                    
                    // Strobe Bar
                    curvedRectangle(topRadius: isTop ? 40 : 5, bottomRadius: isBottom ? 40 : 5)
                        .fill(item.frequency <= (selectedMaxFrequency ?? 0) ? Color("strobeHzColor") : Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .onTapGesture {
                            HapticManager.shared.notify(.impact(.light))
                            flashlightOn = true
                            selectedMaxFrequency = item.frequency // Light up all ≤ this frequency
                            
                            flashControllerInstance.startFlashing(
                                frequencyHz: item.frequency,
                                intensity: Float(brightnessLevel) / Float(maxLevel)
                            )
                        }
                        .disabled(isLockedPower)
                    
                    // PPM Label
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(item.ppm)")
                            .foregroundColor(item.frequency == selectedMaxFrequency ? .white : Color.gray.opacity(0.2))
                            .font(.caption)
                        Text("ppm")
                            .foregroundColor(item.frequency == selectedMaxFrequency ? .white : Color.gray.opacity(0.2))
                            .font(.caption)
                            .italic()
                    }
                    .frame(width: 40, alignment: .leading)
                }
            }
        }
    }
    
    // MARK: Camping View and Controls
    private func campingButton<Destination: View>(icon: String, title: String, color: Color, rotation: Double, destination: Destination) -> some View {
        NavigationLink {
            destination
        } label: {
            curvedRectangle(topRadius: 40, bottomRadius: 0)
                .fill(color.opacity(0.2))
                .rotationEffect(.degrees(rotation))
                .frame(width: 160, height: 160)
                .overlay {
                    VStack {
                        Text(title)
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.top)
                        
                        Spacer()
                    }
                    .rotationEffect(.degrees(rotation))
                }
        }
    }
    
    private func sliderSegment(level: Int, fillColor: Color) -> some View {
        let shape: AnyShape = level == maxLevel ? AnyShape(curvedRectangle(topRadius: 40, bottomRadius: 5)) : AnyShape(RoundedRectangle(cornerRadius: 5))
        
        return shape
            .fill(fillColor)
            .frame(width: 125, height: 80)
            .onTapGesture {
                HapticManager.shared.notify(.impact(.light))
                flashlightOn = true
                brightnessLevel = level
                updateTorch()
            }
    }
    
    // MARK: Main Power Button
    private var powerButton: some View {
        ZStack {
            curvedRectangle(topRadius: 0, bottomRadius: 40)
                .fill(Color("darkGray"))
                .frame(width: 125, height: 90)
                .offset(y: 35)
            
            curvedRectangle(topRadius: 5, bottomRadius: 40)
                .fill(Color("darkGreen"))
                .frame(width: 125, height: 90)
                .overlay(
                    curvedRectangle(topRadius: 5, bottomRadius: 40)
                        .stroke(Color("lightGreen").opacity(0.6), lineWidth: 2)
                )
            
            VStack {
                Image(systemName: "power")
                    .font(.system(size: 45))
                    .foregroundStyle(Color("lightGreen"))
            }
        }
        .onTapGesture {
            HapticManager.shared.notify(.impact(.medium))
            flashlightOn.toggle()
            brightnessLevel = maxLevel
            
            if flashlightOn {
                if mode == .strobe {
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
            HapticManager.shared.notify(.notification(.success))
            isLockedPower.toggle()
        }
    }
    
    private var lockHint: some View {
        HStack {
            Text("Hold to")
            Image(systemName: isLockedPower ? "lock.open.fill" : "lock.fill")
        }
        .font(.caption)
        .foregroundStyle(Color("lightGreen"))
    }
    
    // MARK: Mode Buttons
    private var modeButtons: some View {
        HStack(spacing: 13) {
            modeButton(icon: "sos", BGColor: sosPressed ? .red : Color("darkGray"))
                .onTapGesture {
                    guard mode != .strobe && mode != .camping else { return }
                    
                    HapticManager.shared.notify(.impact(.light))
                    sosPressed.toggle()
                    withAnimation {
                        mode = mode == .sos ? .neutral : .sos
                    }
                }
            
            modeButton(icon: "iphone", BGColor: Color("darkGray"))
                .onTapGesture {
                    HapticManager.shared.notify(.impact(.light))
                }
            
            /*
            modeButton(icon: "tent.fill", BGColor: campingPressed ? .green : Color("darkGray"))
                .onTapGesture {
                    guard mode != .sos && mode != .strobe else { return }
                    
                    HapticManager.shared.notify(.impact(.light))
                    campingPressed.toggle()
                    withAnimation {
                        mode = mode == .camping ? .neutral : .camping
                    }
                }
             */
            
            modeButton(icon: "light.beacon.max.fill", BGColor: strobePressed ? .blue : Color("darkGray"))
                .onTapGesture {
                    guard mode != .sos && mode != .camping else { return }
                    
                    HapticManager.shared.notify(.impact(.light))
                    strobePressed.toggle()
                    withAnimation {
                        mode = mode == .strobe ? .neutral : .strobe
                    }
                    
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
            
            if isAssistantEnabled {
                modeButton(icon: "questionmark.bubble", BGColor: aiPressed ? .purple : Color("darkGray"))
                    .onTapGesture {
                        HapticManager.shared.notify(.impact(.light))
                        aiPressed.toggle()
                    }
            }
        }
    }
    
    private func modeButton(icon: String, BGColor: Color = Color.blue) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity, maxHeight: 70, alignment: .center)
        .background(BGColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray.opacity(0.2), lineWidth: 2)
        )
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
            print("Flashlight update error: \(error)")
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

// MARK: - Triangle Shape (Your Warning Icon)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Background
extension HomeView {
    private var backgroundColor: Color {
        switch sosState {
        case .idle:
            return Color("darkRed")
        case .countdown:
            return Color("darkRed")
        case .sounding:
            return Color.red
        }
    }
}

// MARK: - Glow (Sounding State)
extension HomeView {
    private var glowOverlay: some View {
        Group {
            if sosState == .sounding {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red.opacity(0.8), lineWidth: 6)
                    .blur(radius: 12)
                    .scaleEffect(glow ? 1.06 : 1.0)
                    .opacity(glow ? 0.9 : 0.4)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.1)
                            .repeatForever(autoreverses: true)
                        ) {
                            glow = true
                        }
                    }
            }
        }
    }
}

// MARK: - Content Switcher
extension HomeView {
    @ViewBuilder
    private var content: some View {
        switch sosState {
        case .idle:
            idleContent
        case .countdown(let value):
            countdownContent(value: value)
        case .sounding:
            soundingContent
        }
    }
}

// MARK: - Idle Content
extension HomeView {
    private var idleContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "speaker.wave.2.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .overlay {
                    ZStack {
                        Triangle()
                            .fill(Color.black)
                            .frame(width: 10, height: 10)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                    .offset(x: 13, y: 10)
                }
            
            Text("Emergency Siren")
                .foregroundStyle(.white)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.red)
                .frame(width: 45, height: 2)
                .padding(.vertical, 12)
            
            Text("3 SECONDS DELAY")
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Countdown Content
extension HomeView {
    private func countdownContent(value: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: 110, height: 110)
                .scaleEffect(circleScale(for: value))
                .animation(
                    .easeOut(duration: 0.9),
                    value: value
                )
            
            VStack(spacing: 12) {
                Image(systemName: "speaker.wave.2.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .overlay {
                        ZStack {
                            Triangle()
                                .fill(Color.black)
                                .frame(width: 10, height: 10)
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                        .offset(x: 13, y: 10)
                    }
                
                Text("\(value)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("TAP TO\nCANCEL")
                    .font(.headline.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }
    
    private func circleScale(for value: Int) -> CGFloat {
        switch value {
        case 3: return 0.0
        case 2: return 0.7
        case 1: return 1.1
        default: return 1.1
        }
    }
}

// MARK: - Sounding Content
extension HomeView {
    private var soundingContent: some View {
        VStack(spacing: 12) {
            Text("Sounding…")
                .foregroundStyle(.white)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "speaker.wave.2.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("TAP TO\nSTOP")
                .font(.headline.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding([.top, .bottom], 30)
    }
}

// MARK: - SOS Alarm Logic
extension HomeView {
    private func handleSOSAction() {
        switch sosState {
        case .idle:
            startCountdown()
        case .countdown:
            cancelCountdown()
        case .sounding:
            stopSiren()
        }
    }
    
    private func startCountdown() {
        countdownTimer?.invalidate()
        
        countdownValue = 3
        sosState = .countdown(countdownValue)
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdownValue -= 1
            
            if countdownValue > 0 {
                HapticManager.shared.notify(.impact(.light))
                sosState = .countdown(countdownValue)
            } else {
                VolumeManager.saveCurrentVolume()
                timer.invalidate()
                countdownTimer = nil
                sosState = .sounding
                VolumeManager.setSystemVolume(to: 1.0)
                toneEngine.start()
            }
        }
    }
    
    private func cancelCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        HapticManager.shared.notify(.notification(.success))
        sosState = .idle
    }
    
    private func stopSiren() {
        // stop audio, flashlight, haptics, etc
        VolumeManager.restoreVolume()
        HapticManager.shared.notify(.notification(.success))
        toneEngine.stop()
        sosState = .idle
    }
}
