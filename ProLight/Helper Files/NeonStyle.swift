//
//  NeonStyle.swift
//  ProLight
//
//  Created by Paul Roden II on 3/12/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import Foundation
import SwiftUI

struct NeonStyle: ViewModifier {
    let color: Color
    @Binding var blurRadius: CGFloat
    
    func body(content: Content) -> some View {
        return ZStack {
            content.foregroundColor(color)
            content.blur(radius: blurRadius)
        }
        .padding(10)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(color, lineWidth: 4)) // overlay
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(color, lineWidth: 4).brightness(0.1).blur(radius: blurRadius)) // background
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(color, lineWidth: 4).brightness(0.1).blur(radius: blurRadius).opacity(0.2)) // background
        .compositingGroup()
    }
}
