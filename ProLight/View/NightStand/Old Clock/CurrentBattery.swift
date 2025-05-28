//
//  CurrentBattery.swift
//  ProLight
//
//  Created by Paul on 10/5/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct CurrentBattery: View {
    
    var batteryLevel: Int {
        let device = UIDevice.current
        let level = device.batteryLevel
        
        if level > 0.99 {
            return 100
        }
        if level > 0.80 {
            return 90
        }
        if level > 0.64 {
            return 75
        }
        if level > 0.40 {
            return 50
        }
        if level > 0.34 {
            return 30
        }
        if level > 0.14 {
            return 20
        }
        return 10
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                let batteryText = String(format: "%.0f%%", UIDevice.current.batteryLevel * 100)
                
                if batteryLevel == 100 {
                    Image(systemName: "battery.100")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .padding(.top)
                    
                } else if batteryLevel == 75 {
                    Image(systemName: "battery.75")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .padding(.top)
                    
                } else if batteryLevel == 50 {
                    Image(systemName: "battery.50")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .padding(.top)
                    
                } else if batteryLevel == 25 {
                    Image(systemName: "battery.25")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                        .padding(.top)
                    
                } else if batteryLevel == 10 {
                    Image(systemName: "battery.25")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                Text(batteryText)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding(.bottom)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(Color.white.opacity(0.1))
            .modifier(CardModifier())
        }
    }
}

struct CurrentBattery_Previews: PreviewProvider {
    static var previews: some View {
        CurrentBattery()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
    }
}
