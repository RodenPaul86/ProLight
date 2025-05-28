//
//  includedCard.swift
//  Noel
//
//  Created by Paul on 6/10/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct includedCard: View {
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Included in this subscription:")
                        .foregroundColor(.gray)
                        
                    Spacer()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    exampleText(icon: "lock.open.fill", color: .gray, text: "Unlock all features.")
                    exampleText(icon: "deskclock.fill", color: .purple, text: "Desk mode.")
                    exampleText(icon: "app.fill", color: .indigo, text: "5 new app icons to choose from.")
                    exampleText(icon: "cloud.sun.rain.fill", color: .blue, text: "Current local weather.")
                    exampleText(icon: "flashlight.on.fill", color: .cyan, text: "Additional flashlight features: \nstrubing and flashing.")
                    exampleText(icon: "captions.bubble.fill", color: .green, text: "Additional morse code features.")
                    exampleText(icon: "person.2.fill", color: .yellow, text: "Share your subscription with your family members.")
                    exampleText(icon: "text.bubble.fill", color: .orange, text: "No commitment, cancel anytime.")
                    exampleText(icon: "heart.fill", color: .red, text: "Support indie developers.")
                }
                
                Spacer()
                
                Text("Your purchase will be applied to your iTunes account at the confirmation of your purchase. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings.")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray5))
        .modifier(CardModifier())
        .padding([.horizontal, .top])
    }
}

struct includedCard_Previews: PreviewProvider {
    static var previews: some View {
        payWall()
    }
}
