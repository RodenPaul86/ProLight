//
//  NavHeader.swift
//  ProLight
//
//  Created by Paul on 9/23/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct analogClock: View {
    
    //@Binding var isDark: Bool
    var width = UIScreen.main.bounds.width
    @State var current_Time = Time(min: 0, sec: 0, hour: 0)
    @State var receiver = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                // THis is for the Analog Clock
                
                ZStack {
                    Circle()
                        .fill(Color("Color").opacity(0.1))
                    
                    // Sec and Min dots...
                    
                    ForEach(0..<60,id: \.self) { i in
                        
                        Rectangle()
                            .fill(Color.white)
                            // 60/12 = 5
                            .frame(width: 2, height: (i % 5) == 0 ? 15 : 5)
                            .offset(y: (width - 110) / 2)
                            .rotationEffect(.init(degrees: Double(i) * 6))
                    }
                    
                    // Hour...
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 4.5, height: (width - 240) / 2)
                        .offset(y: -(width - 240) / 4)
                        .rotationEffect(.init(degrees: Double(current_Time.hour + (current_Time.min / 60)) * 30))
                    
                    // Min...
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 4, height: (width - 200) / 2)
                        .offset(y: -(width - 200) / 4)
                        .rotationEffect(.init(degrees: Double(current_Time.min) * 6))
                    
                    // Sec...
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2, height: (width - 180) / 2)
                        .offset(y: -(width - 180) / 4)
                        .rotationEffect(.init(degrees: Double(current_Time.sec) * 6))
                    
                    // Center Circle...
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 15, height: 15)
                    
                }
                //.frame(width: 200, height: 200)
            }
            .onAppear(perform: {
                let calender = Calendar.current
                let hour = calender.component(.hour, from: Date())
                let min = calender.component(.minute, from: Date())
                let sec = calender.component(.second, from: Date())
                
                withAnimation(Animation.linear(duration: 0.01)) {
                    self.current_Time = Time(min: min, sec: sec, hour: hour)
                }
                
            })
            .onReceive(receiver) { (_) in
                let calender = Calendar.current
                let hour = calender.component(.hour, from: Date())
                let min = calender.component(.minute, from: Date())
                let sec = calender.component(.second, from: Date())
                
                withAnimation(Animation.linear(duration: 0.01)) {
                    self.current_Time = Time(min: min, sec: sec, hour: hour)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(Color.white.opacity(0.1))
            .modifier(CardModifier())
        }
        .padding([.leading, .trailing, .bottom])
    }
    
    func getTime() -> String {
        let format = DateFormatter()
        format.dateFormat = "hh:mm a"
        return format.string(from: Date())
    }
}


// Calculating Time...

struct Time {
    var min: Int
    var sec: Int
    var hour: Int
}

struct analogClock_Previews: PreviewProvider {
    static var previews: some View {
        analogClock()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
    }
}
