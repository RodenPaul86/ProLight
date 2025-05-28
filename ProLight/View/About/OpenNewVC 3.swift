//
//  OpenNewView.swift
//  ProLight
//
//  Created by Paul on 9/2/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct OpenNewVC: View {
    var body: some View {
        
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                
                Message(headerText: "", bodyText: "")
                
                
                
            }
            .navigationBarTitle("About", displayMode: .inline)
            .background(Color("ColorBackground").edgesIgnoringSafeArea(.all))
            
            
            
        }
    }
}

struct OpenNewView_Previews: PreviewProvider {
    static var previews: some View {
        OpenNewVC()
    }
}
