//
//  Home2.swift
//  ProLight
//
//  Created by Paul  on 5/29/25.
//

import SwiftUI
import AVFoundation

struct Home: View {
    @State private var brightnessLevel = 4
    @State private var flashlightOn: Bool = true
    @State private var isLockedPower: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var strobePressed: Bool = false
    @State private var sosPressed: Bool = false
    
    let maxLevel = 4
    var tabBarHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(.black)
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 40) {
                // Flashlight icon indicator
                VStack(spacing: 8) {
                    if flashlightOn {
                        let scaledOpacity = Double(brightnessLevel) / Double(maxLevel)
                        let shadowRadius = 5 + (15 * scaledOpacity) // radius grows with brightness
                        
                        Image(systemName: "flashlight.on.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 60)
                            .foregroundColor(Color.white.opacity(scaledOpacity))
                            .shadow(color: .white.opacity(scaledOpacity), radius: shadowRadius)
                    } else {
                        Image(systemName: "flashlight.off.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 60)
                            .foregroundColor(.white.opacity(0.4))
                            .shadow(color: .clear, radius: 0)
                    }
                }
                
                // Brightness slider
                VStack(spacing: 10) {
                    VStack(spacing: 5) {
                        curvedRectangle(topRadius: 40, bottomRadius: 5)
                            .fill(!flashlightOn ? Color.gray.opacity(0.3) : (brightnessLevel == maxLevel ? Color.white : Color.gray.opacity(0.3)))
                            .frame(width: 125, height: 80)
                            .onTapGesture {
                                flashlightOn = true
                                brightnessLevel = maxLevel
                                print("Tapped level: \(maxLevel)")
                                updateTorch()
                            }
                        
                        ForEach((1..<(maxLevel)).reversed(), id: \.self) { level in
                            RoundedRectangle(cornerRadius: 5)
                                .fill(!flashlightOn ? Color.gray.opacity(0.3) : (level <= brightnessLevel ? Color.white : Color.gray.opacity(0.3)))
                                .frame(width: 125, height: 80)
                                .onTapGesture {
                                    flashlightOn = true
                                    brightnessLevel = level
                                    print("Tapped level: \(level)")
                                    updateTorch()
                                }
                        }
                    }
                    
                    // Power button with lock text
                    ZStack {
                        curvedRectangle(topRadius: 0, bottomRadius: 40)
                            .fill(Color("darkColor"))
                            .frame(width: 125, height: 90)
                            .offset(y: 35)
                        
                        curvedRectangle(topRadius: 5, bottomRadius: 40)
                            .fill(Color("powerBtn"))
                            .frame(width: 125, height: 90)
                        
                        VStack {
                            if isLockedPower == true {
                                Image(systemName: "power")
                                    .font(.title3)
                                    .foregroundStyle(Color("textColor"))
                                    .padding(5)
                                
                                Text("Double Tap")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color("textColor"))
                                Text("to turn off")
                                    .font(.caption)
                                    .foregroundStyle(Color("textColor"))
                            } else {
                                Image(systemName: "power")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color("textColor"))
                            }
                        }
                    }
                    .onTapGesture {
                        flashlightOn.toggle()
                        brightnessLevel = maxLevel
                        updateTorch()
                    }
                    .onLongPressGesture(minimumDuration: 1) {
                        isLockedPower.toggle()
                    }
                    
                    if isLockedPower == true {
                        HStack {
                            Text("Hold to")
                            Image(systemName: "lock.open.fill")
                        }
                        .font(.caption)
                        .foregroundStyle(Color("textColor"))
                        
                    } else {
                        HStack {
                            Text("Hold to")
                            Image(systemName: "lock.fill")
                        }
                        .font(.caption)
                        .foregroundStyle(Color("textColor"))
                    }
                }
                
                // Mode Buttons
                HStack(spacing: 13) {
                    // Wider SOS button with subtitle
                    modeButton(title: "SOS", subtitle: "Emergency\nLight Pattern", BGColor: sosPressed ? .red : Color("darkColor"), width: 140, height: 70)
                        .onTapGesture {
                            sosPressed.toggle()
                        }
                    
                    // Smaller SCREEN and STROBE buttons
                    modeButton(title: "Screen", width: 100, height: 70)
                    
                    modeButton(title: "Strobe", BGColor: strobePressed ? .blue : Color("darkColor"), width: 100, height: 70)
                        .onTapGesture {
                            strobePressed.toggle()
                        }
                }
            }
            .onAppear {
                updateTorch()
            }
            .padding()
            .safeAreaPadding(.bottom, tabBarHeight)
        }
    }
    
    func modeButton(title: String, subtitle: String? = nil, BGColor: Color = Color("darkColor"), width: CGFloat = 80, height: CGFloat = 60) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            if let subtitle = subtitle {
                Text(subtitle)
                    .padding(.horizontal, 5)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(width: width, height: height)
        .background(BGColor)
        .cornerRadius(20)
    }
    
    func updateTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        
        if flashlightOn {
            let level = Float(brightnessLevel) / Float(maxLevel)
            try? device.setTorchModeOn(level: level)
        } else {
            device.torchMode = .off
        }
        
        device.unlockForConfiguration()
    }
}

#Preview {
    ContentView()
}

struct RoundedTriangle: Shape {
    var cornerRadius: CGFloat = 10.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: CGPoint(x: top.x, y: top.y + cornerRadius))
        
        path.addQuadCurve(to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y - cornerRadius),
                          control: CGPoint(x: rect.minX, y: rect.midY))
        
        path.addQuadCurve(to: CGPoint(x: bottomRight.x - cornerRadius, y: bottomRight.y - cornerRadius),
                          control: CGPoint(x: rect.midX, y: rect.maxY))
        
        path.addQuadCurve(to: CGPoint(x: top.x, y: top.y + cornerRadius),
                          control: CGPoint(x: rect.maxX, y: rect.midY))
        
        return path
    }
}

struct curvedRectangle: Shape {
    var topRadius: CGFloat
    var bottomRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topR = min(topRadius, rect.width / 2, rect.height / 2)
        let bottomR = min(bottomRadius, rect.width / 2, rect.height / 2)
        
        path.move(to: CGPoint(x: rect.minX + topR, y: rect.minY))
        
        // Top edge with rounded corners
        path.addLine(to: CGPoint(x: rect.maxX - topR, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + topR),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Right side down to bottom corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomR))
        path.addArc(center: CGPoint(x: rect.maxX - bottomR, y: rect.maxY - bottomR),
                    radius: bottomR,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + bottomR, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomR, y: rect.maxY - bottomR),
                    radius: bottomR,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        
        // Left side up to top corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topR))
        path.addQuadCurve(to: CGPoint(x: rect.minX + topR, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        
        path.closeSubpath()
        return path
    }
}
