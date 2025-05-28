//
//  Agreement.swift
//  ProLight
//
//  Created by Paul Roden II on 4/11/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct legalDocs: View {
    var icon: String
    var firstText: String
    var secondText: String
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(UIColor.systemGreen))
                Image(systemName: icon)
                    .foregroundColor(Color(UIColor.systemGray5))
            }
            .frame(width: 36, height: 36, alignment: .center)
            
            Text(firstText).foregroundColor(Color.gray)
            
            Spacer()
            
            Text(secondText)
                .font(.headline)
        }
    }
}

struct legalDocs_Previews: PreviewProvider {
    static var previews: some View {
        legalDocs(icon: "doc", firstText: "Document", secondText: "Doc Name")
            .previewLayout(.fixed(width: 375, height: 60))
            .padding()
    }
}
