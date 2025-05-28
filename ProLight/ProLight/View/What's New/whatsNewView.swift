//
//  whatsNewView.swift
//  ProLight
//
//  Created by Paul Roden II on 4/13/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct whatsNewView: View {
    @Environment(\.dismiss) var dismiss
    var data: [whatsNewData] = dataComponents
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ForEach(data) { user in
                    appVersionCard(data: user)
                }
            }
            .navigationBarTitle("What's New", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .bold()
                            .foregroundColor(.green)
                    }
                }
            })
        }
    }
}

struct whatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        whatsNewView()
    }
}
