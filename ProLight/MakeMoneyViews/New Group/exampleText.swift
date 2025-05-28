//
//  exampleText.swift
//  Noel
//
//  Created by Paul on 6/10/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct exampleText: View {
    var icon: String
    var color: Color
    var text: String
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            .frame(width: 36, height: 36, alignment: .center)
            
            VStack(alignment: .leading) {
                Text(text)
            }
            Spacer()
        }
    }
}

struct exampleText_Previews: PreviewProvider {
    static var previews: some View {
        exampleText(icon: "car", color: .orange, text: "Example")
    }
}
