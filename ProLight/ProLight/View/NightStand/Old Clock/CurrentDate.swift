//
//  CurrentDate.swift
//  ProLight
//
//  Created by Paul on 10/5/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct CurrentDate: View {
    
    @State var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Text(getDate())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .font(.title2)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(Color.white.opacity(0.1))
            .modifier(CardModifier())
        }
    }
    func getDate() -> String {
        let format = DateFormatter()
        format.dateFormat = "EEEE\nMMM dd yyyy"
        return format.string(from: currentDate)
    }
}

struct CurrentDate_Previews: PreviewProvider {
    static var previews: some View {
        CurrentDate()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
    }
}
