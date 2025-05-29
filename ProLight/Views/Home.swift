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
    @State private var flashlightOn = true
    @State private var showLockIcon = false
    
    @State private var dragOffset: CGFloat = 0
    
    let maxLevel = 4
    
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
                        curvedRectangle(topRadius: 40, bottomRadius: 10)
                            .fill(!flashlightOn ? Color.gray.opacity(0.3) : (brightnessLevel == maxLevel ? Color.white : Color.gray.opacity(0.3)))
                            .frame(width: 120, height: 60)
                            .onTapGesture {
                                flashlightOn = true
                                brightnessLevel = maxLevel
                                print("Tapped level: \(maxLevel)")
                                updateTorch()
                            }

                        ForEach((1..<(maxLevel)).reversed(), id: \.self) { level in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(!flashlightOn ? Color.gray.opacity(0.3) : (level <= brightnessLevel ? Color.white : Color.gray.opacity(0.3)))
                                .frame(width: 120, height: 60)
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
                        curvedRectangle(topRadius: 10, bottomRadius: 40)
                            .fill(flashlightOn ? Color.green.opacity(0.6) : Color.gray.opacity(0.3))
                            .frame(width: 120, height: 90)
                        Image(systemName: "power")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                    }
                    .onTapGesture {
                        flashlightOn.toggle()
                        brightnessLevel = maxLevel
                        updateTorch()
                    }
                    .onLongPressGesture(minimumDuration: 1) {
                        
                    }
                    
                    HStack {
                        Text("Hold to")
                        Image(systemName: "lock.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.gray)
                }
                
                // Mode Buttons
                HStack(spacing: 13) {
                    // Wider SOS button with subtitle
                    modeButton(
                        title: "SOS",
                        subtitle: "Emergency\nlight pattern",
                        width: 140,
                        height: 70
                    )
                    
                    // Smaller RED and STROBE buttons
                    modeButton(title: "RED", width: 80, height: 70)
                    modeButton(title: "Strobe", width: 80, height: 70)
                    
                }
                .padding(.horizontal)
            }
        }
    }
    
    func modeButton(title: String, subtitle: String? = nil, width: CGFloat = 80, height: CGFloat = 60) -> some View {
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
        .background(Color.gray.opacity(0.2))
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
