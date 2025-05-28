//
//  NightStandVC.swift
//  ProLight
//
//  Created by Paul on 9/26/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct NightStandVC: View {
    var backToMAinVC: HomeVC?
    
    var body: some View {
        VStack {
            Button(action: {
                self.backToMAinVC?.presentedViewController?.dismiss(animated: true)
            }, label: {
                CancelButtonLabel()
                    .foregroundColor(Color.green)
            })
            ComponentsView()
            analogClock()
        }
        .background(
            Image("background")
        )
    }
}

struct NightStandVC_Previews: PreviewProvider {
    static var previews: some View {
        NightStandVC()
    }
}
