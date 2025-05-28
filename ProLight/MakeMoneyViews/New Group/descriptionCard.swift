//
//  SwiftUIView.swift
//  Noel
//
//  Created by Paul on 6/10/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct descriptionCard: View {
    let description: String
    
    var body: some View {
        HStack {
            Text(description)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .padding()
            
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray5))
        .modifier(CardModifier())
        .padding()
    }
}

struct bannerView_Previews: PreviewProvider {
    static var previews: some View {
        descriptionCard(description: "Test data...")
    }
}
