//
//  payButton.swift
//  Noel
//
//  Created by Paul on 6/10/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct payButton: View {
    var subPeriod: String
    var price: String
    
    var body: some View {
        HStack {
            VStack {
                Text(subPeriod)
                    .font(.system(size: 25).bold())
                Text(price)
                    .font(.system(size: 15))
            }
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(Color(.systemBlue))
        .modifier(CardModifier())
        .padding()
    }
}

struct payButton_Previews: PreviewProvider {
    static var previews: some View {
        payWall()
    }
}
