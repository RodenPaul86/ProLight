//
//  Home2.swift
//  ProLight
//
//  Created by Paul  on 5/29/25.
//

import SwiftUI
import AVFoundation

struct Home: View {
    @State private var brightnessLevel = 3
    @State private var flashlightOn = true
    @State private var showLockIcon = false
    
    @State private var dragOffset: CGFloat = 0
    
    let maxLevel = 3
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(.black)
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 40) {
                // Flashlight icon with beam
                VStack(spacing: 8) {
                    if flashlightOn {
                        Image(systemName: "flashlight.on.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 60)
                            .foregroundColor(Color.white.opacity(Double(brightnessLevel)))
                            .shadow(color: .white.opacity(Double(brightnessLevel)), radius: 10)
                        
                    } else {
                        Image(systemName: "flashlight.off.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 60)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                // Brightness slider
                VStack(spacing: 10) {
                    VStack(spacing: 5) {
                        TopCurvedRectangle()
                            .fill(!flashlightOn ? Color.gray.opacity(0.3) : (brightnessLevel == maxLevel ? Color.white : Color.gray.opacity(0.3)))
                            .frame(width: 120, height: 60)
                            .onTapGesture {
                                flashlightOn = true
                                brightnessLevel = maxLevel
                                updateTorch()
                            }

                        ForEach((1...maxLevel).reversed(), id: \.self) { level in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(!flashlightOn ? Color.gray.opacity(0.3) : (level <= brightnessLevel ? Color.white : Color.gray.opacity(0.3)))
                                .frame(width: 120, height: 60)
                                .onTapGesture {
                                    flashlightOn = true
                                    brightnessLevel = level
                                    updateTorch()
                                }
                        }
                    }
                    
                    // Power button with lock text
                    ZStack {
                        FlatTopRoundedRectangle()
                            .fill(flashlightOn ? Color.green.opacity(0.8) : Color.gray.opacity(0.3))
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
            
            
            
            
            
            /*
            // Brightness slider (hidden)
            Slider(value: $brightness, in: 0...1)
                .padding()
                .offset(y: 250)
            */
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

struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        let startAngle: Angle = .degrees(180)
        let endAngle: Angle = .degrees(0)
        return Path { path in
            path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                        radius: rect.width / 2,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
        }
    }
}

struct BeamMaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width / 2 - 20, y: 0))
        path.addLine(to: CGPoint(x: width / 2 + 20, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct TopCurvedRectangle: Shape {
    func path(in rect: CGRect) -> Path {
            var path = Path()
            let radius: CGFloat = 40

            path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // Start at bottom-left
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Line to bottom-right
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + radius)) // Line up
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                        radius: radius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(-90),
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.minY)) // Line to top-left arc start
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                        radius: radius,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-180),
                        clockwise: true)
            path.closeSubpath()
            return path
        }
}

struct FlatTopRoundedRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 40

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .zero,
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}
