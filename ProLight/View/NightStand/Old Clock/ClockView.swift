//
//  ClockView.swift
//  ProLight
//
//  Created by Paul on 10/5/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct ClockView: View {
    
    @State var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text(getTime())
                    .onReceive(timer) { input in
                        currentDate = input
                    }
                    .font(Font.custom("alarmClock", size: 60))
                    .foregroundColor(Color(.systemGreen))
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(Color.white.opacity(0.1))
            .modifier(CardModifier())
        }
    }
    
    func getTime() -> String {
        let format = DateFormatter()
        format.dateFormat = "h:mm a"
        return format.string(from: currentDate)
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
    }
}
