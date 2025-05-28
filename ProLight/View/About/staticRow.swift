//
//  FormRowStaticView.swift
//  ProLight
//
//  Created by Paul on 8/12/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct FormRowStaticView: View {
    var icon: String
    var color: Color
    var firstText: String
    var secondText: String
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                Image(systemName: icon)
                    .foregroundColor(Color(UIColor.systemGray5))
            }
            .frame(width: 36, height: 36, alignment: .center)
            
            Text(firstText).foregroundColor(.gray)
            
            Spacer()
            
            Text(secondText).font(.headline)
        }
    }
}

struct FormRowStaticView_Previews: PreviewProvider {
    static var previews: some View {
        FormRowStaticView(icon: "gear", color: .gray, firstText: "Application", secondText: "Name")
            .previewLayout(.fixed(width: 375, height: 60))
            .padding()
    }
}
