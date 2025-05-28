//
//  SimpleWidgetBundle.swift
//  ProLight WidgetExtension
//
//  Created by Paul on 7/5/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct SimpleWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        appIconWidget()
        CalenderWidget()
        TimeDateWidget()
    }
}
