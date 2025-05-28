//
//  CancelButtonLabel.swift
//  ProLight
//
//  Created by Paul on 12/2/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct CancelButtonLabel: View {
    var body: some View {
        VStack {
            Group {
                Spacer().frame(width: 0, height: 20.0, alignment: .topLeading)
                HStack {
                    Text("Close")
                        .bold()
                        .font(.system(size: 17.0))
                        .padding(.leading, 20)
                    Spacer()
                }
            }
        }
    }
}



struct CancelButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
        CancelButtonLabel()
    }
}
