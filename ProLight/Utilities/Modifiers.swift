//
//  Modifiers.swift
//  ProLight
//
//  Created by Paul on 11/12/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View { content
        .cornerRadius(10)
        .shadow(color: .init(.sRGB, white: 0, opacity: 0.25), radius: 4, x: 0, y: 4)
    }
}
