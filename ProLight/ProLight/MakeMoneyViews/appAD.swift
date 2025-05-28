//
//  appAD.swift
//  ProLight
//
//  Created by Paul on 8/31/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct appAD: View {
    //MARK: Properties
    
    //MARK: View Body
    var body: some View {
        ZStack {
            HStack {
                Image("PowerIcon")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    .padding(.leading)
                
                VStack(alignment: .leading) {
                    Text("GET PROLIGHT PREMIUM")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.top)
                    
                    Text("Hide these ad and support ProLight by subscribing!")
                        .font(.system(size: 15))
                        .padding([.bottom, .trailing])
                }
            }
            .background(Color(.systemGray5))
            .cornerRadius(15)
        }
    }
}

struct appAD_Previews: PreviewProvider {
    static var previews: some View {
        appAD()
    }
}
