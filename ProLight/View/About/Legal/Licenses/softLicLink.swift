//
//  softLicLink.swift
//  ProLight
//
//  Created by Paul Roden II on 4/11/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import SafariServices

struct softLicLink: View {
    @State var showSafari = false
    
    var name: String
    var version: String
    var licensesHolder: String
    var licensesLink: String
    
    var body: some View {
        HStack {
            Button(action: { self.showSafari = true }, label: {
                VStack(alignment: .leading) {
                    Text("\(name) - v\(version)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(licensesHolder)
                        .font(.subheadline)
                }
            })
            .sheet(isPresented: $showSafari) {
                //SafariView(url:URL(string: licensesLink)!).ignoresSafeArea()
            }
            
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}

struct softLicLink_Previews: PreviewProvider {
    static var previews: some View {
        softLicLink(name: "CocoaPods", version: "0.0.0", licensesHolder: "Licenses Holder Name", licensesLink: "")
    }
}
