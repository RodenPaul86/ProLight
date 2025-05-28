//
//  clockView.swift
//  ProLight
//
//  Created by Paul on 6/21/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import AVFoundation

struct clockView: View {
    @State var audioPlayer: AVAudioPlayer!
    
    var width = UIScreen.main.bounds.width
    @State var currentTime = calculatingTime(min: 0, sec: 0, hour: 0)
    @State var receiver = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    @State private var showText = false
    
    var body: some View {
        VStack {
            /*
            Text(Locale.current.localizedString(forRegionCode: Locale.current.regionCode!) ?? "")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 35)
             */
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.06))
                
                // Sec and Min dots...
                
                ForEach(0..<60,id: \.self) { index in
                    Rectangle()
                        .fill(index % 5 == 0 ? .white : .gray)
                    // 60/12 = 5
                        .frame(width: 2, height: index % 5 == 0 ? 10 : 5)
                        .offset(y: (width - 110) / 2)
                        .rotationEffect(.init(degrees: Double(index) * 6))
                }
                
                // MARK: Clock Text
                let text = [6,9,12,3]
                ForEach(text.indices,id: \.self) { index in
                    Text("\(text[index])")
                        .font(.caption.bold())
                        .foregroundColor(.primary)
                        .rotationEffect(.init(degrees: Double(index) * -90))
                        .offset(y: (width - 150) / 2)
                        .rotationEffect(.init(degrees: Double(index) * 90))
                }
                
                // Hour...
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary)
                    .frame(width: 4.5, height: (width - 240) / 2)
                    .offset(y: -(width - 240) / 4)
                    .rotationEffect(.init(degrees: Double(currentTime.hour + (currentTime.min / 60)) * 30))
                
                // Min...
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary)
                    .frame(width: 4, height: (width - 200) / 2)
                    .offset(y: -(width - 200) / 4)
                    .rotationEffect(.init(degrees: Double(currentTime.min) * 6))
                
                // Sec...
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: 2, height: (width - 180) / 2)
                    .offset(y: -(width - 180) / 4)
                    .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
                
                // Center Circle...
                Circle()
                    .fill(Color.primary)
                    .frame(width: 15, height: 15)
            }
            .frame(width: width - 80, height: width - 80)
            
            Text(Date().dateFormatted)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 35)
            
            Text(Date().timeFormatted)
                .font(Font.custom("alarmClock", size: 60))
                .fontWeight(.heavy)
                .padding(.top, 10)
        }
        .onAppear(perform: {
            let calender = Calendar.current
            let min = calender.component(.minute, from: Date())
            let sec = calender.component(.second, from: Date())
            let hour = calender.component(.hour, from: Date())
            
            withAnimation(Animation.linear(duration: 0.01)) {
                self.currentTime = calculatingTime(min: min, sec: sec, hour: hour)
            }
            
            if UserDefaults.standard.value(forKey: "stateOfSound") != nil {
                let switchOn: Bool = UserDefaults.standard.value(forKey: "stateOfSound") as! Bool
                
                if switchOn == true {
                    
                } else if switchOn == false {
                    playSounds("clock.wav")
                }
            } else {
                playSounds("clock.wav")
            }
        })
        .onReceive(receiver) { (_) in
            let calender = Calendar.current
            let min = calender.component(.minute, from: Date())
            let sec = calender.component(.second, from: Date())
            let hour = calender.component(.hour, from: Date())
            
            withAnimation(Animation.linear(duration: 0.01)) {
                self.currentTime = calculatingTime(min: min, sec: sec, hour: hour)
            }
        }
    }
}

struct clockView_Previews: PreviewProvider {
    static var previews: some View {
        clockView()
    }
}

// Calculating Time...

struct calculatingTime {
    var min: Int
    var sec: Int
    var hour: Int
}

extension clockView {
    func playSounds(_ soundFileName : String) {
        guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: nil) else {
            fatalError("Unable to find \(soundFileName) in bundle")
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print(error.localizedDescription)
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
}

extension Date {
    var timeFormatted: String {
        self.formatted(
            .dateTime
                .hour()
                .minute()
        )
    }
    
    var dateFormatted: String {
        self.formatted(
            .dateTime
                .month()
                .day()
                .year()
        )
    }
}
