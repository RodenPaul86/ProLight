//
//  ClickableLink.swift
//  ProLight
//
//  Created by Paul on 9/1/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct ClickableLink: View {
    //MARK: Properties
    
    var icon: String
    var firstText: String
    var secondText: String
    
    //MARK: View Body
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray)
                Image(systemName: icon)
                    .foregroundColor(Color.white)
            }
            .frame(width: 36, height: 36, alignment: .center)
            
            Text(firstText).foregroundColor(Color.gray)
            
            Spacer()
            
            Text(secondText)
                .font(.headline)
                .foregroundColor(.green)
        }
    }
}

struct ClickableLink_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ClickableLink(icon: "gear", firstText: "Application", secondText: "Website Link")
        }
    }
}
