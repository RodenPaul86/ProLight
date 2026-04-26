//
//  Color.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
    //static let launch = LaunchTheme()
}

struct ColorTheme {
    let accent = Color("darkGreen").gradient
    let lowPower = Color.yellow.gradient
    let background = Color("darkGray")
    let iconText = Color("lightGreen")
}

/*
struct LaunchTheme {
    let accent = Color("LaunchAccentColor").gradient
    let background = Color("LaunchBackgroundColor")
}
*/
