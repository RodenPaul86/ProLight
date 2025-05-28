//
//  ComponentsView.swift
//  ProLight
//
//  Created by Paul on 11/12/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct ComponentsView: View {
    var body: some View {
        VStack {
            HStack {
                CurrentDate()
                CurrentBattery()
            }
            ClockView()
        }
        .padding([.leading, .trailing, .top])
        .frame(width: .infinity, height: 230, alignment: .center)
    }
}

struct ComponentsView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentsView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
    }
}
