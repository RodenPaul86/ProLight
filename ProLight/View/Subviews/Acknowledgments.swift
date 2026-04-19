//
//  Acknowledgments.swift
//  ProLight
//
//  Created by Paul  on 4/19/26.
//

import SwiftUI

struct Acknowledgments: View {
    
    @State private var animateGlow = false
    @State private var fadeIn = false
    
    var body: some View {
        ZStack {
            
            // Background gradient (adapts to feel like night + light spill)
            LinearGradient(
                colors: [
                    Color.black,
                    Color.blue.opacity(0.25),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Soft "flashlight glow" effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 300
                    )
                )
                .scaleEffect(animateGlow ? 1.15 : 0.9)
                .opacity(animateGlow ? 0.7 : 0.4)
                .blur(radius: 40)
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                    value: animateGlow
                )
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    // Title
                    Text("Thank You")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .opacity(fadeIn ? 1 : 0)
                        .offset(y: fadeIn ? 0 : 10)
                        .animation(.easeOut(duration: 1), value: fadeIn)
                    
                    // Subtitle
                    Text("ProLight is built with gratitude")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(fadeIn ? 1 : 0)
                        .offset(y: fadeIn ? 0 : 10)
                        .animation(.easeOut(duration: 1).delay(0.2), value: fadeIn)
                    
                    VStack(spacing: 18) {
                        
                        Text("""
I am the sole developer behind ProLight. Every feature, design decision, and line of code has been crafted personally with care and intention.
""")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary.opacity(0.85))
                        
                        Text("""
This app is dedicated to my late father, Paul, who used ProLight often and was a constant inspiration behind its creation.
""")
                        .font(.body.weight(.medium))
                        .multilineTextAlignment(.center)
                        
                        Text("""
Thank you for using ProLight and being part of its journey.
""")
                        .font(.body.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 28)
                    .opacity(fadeIn ? 1 : 0)
                    .offset(y: fadeIn ? 0 : 20)
                    .animation(.easeOut(duration: 1).delay(0.4), value: fadeIn)
                    
                    // Signature
                    Text("— Paul Roden Jr.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                        .opacity(fadeIn ? 1 : 0)
                        .animation(.easeOut(duration: 1).delay(0.6), value: fadeIn)
                    
                    Spacer(minLength: 60)
                }
                .padding(.top, 60)
            }
        }
        .onAppear {
            animateGlow = true
            fadeIn = true
        }
    }
}

#Preview {
    Acknowledgments()
}
