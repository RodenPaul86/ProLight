//
//  btnLoadingView.swift
//  ProLight
//
//  Created by Paul on 6/30/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import Lottie

struct btnLoadingView: View {
    var fileName: String
    
    var body: some View {
        VStack {
            LottieView(name: fileName, loopMode: .loop, speed: 1.00)
                .frame(width: 50, height: 50)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(Color(.systemBlue))
        .modifier(CardModifier())
        .padding()
    }
}

struct btnLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        btnLoadingView(fileName: "")
    }
}
