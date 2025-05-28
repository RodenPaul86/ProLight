//
//  clockTabView.swift
//  ProLight
//
//  Created by Paul on 6/21/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct clockTabView: View {
    var body: some View {
        TabView {
            clockView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Clock")
                }
            
            Text("TODO: alarm view")
                .font(.title)
                .tabItem {
                    Image(systemName: "alarm")
                    Text("Alarm")
                }
        }
        .accentColor(.green)
    }
}

struct clockTabView_Previews: PreviewProvider {
    static var previews: some View {
        clockTabView()
    }
}
