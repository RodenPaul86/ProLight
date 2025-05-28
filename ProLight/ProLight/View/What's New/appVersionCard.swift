//
//  appVersionCard.swift
//  ProLight
//
//  Created by Paul Roden II on 4/13/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct appVersionCard: View {
    var data: whatsNewData
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(data.version)
                        .font(.system(.title2, design: .rounded).bold())
                    Spacer()
                    Text(data.date)
                        .font(.system(.title2, design: .rounded))
                }
                .padding(.bottom)
                
                Text("New Features:")
                    .font(.system(.headline, design: .rounded).bold())
                    .padding(.bottom, 5)
                
                Text(data.newFeatureBody)
                    .font(.system(.body, design: .rounded))
                    .padding(.bottom)
                
                Text("Bug Fixes:")
                    .font(.system(.headline, design: .rounded).bold())
                    .padding(.bottom, 5)
                
                Text(data.bugFixBody)
                    .font(.system(.body, design: .rounded))
            }
            .padding()
        }
        .background(Color(.systemGray5).opacity(1.0))
        .modifier(CardModifier())
        .padding()
    }
}

struct appVersionCard_Previews: PreviewProvider {
    static var previews: some View {
        whatsNewView()
    }
}
