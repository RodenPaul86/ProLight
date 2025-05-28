//
//  webDataModel.swift
//  ProLight
//
//  Created by Paul on 8/6/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct webDataModel: Identifiable {
    var id = UUID()
    var name: String
    var version: String
    var holder: String
    var link: String
}

var packageDependencies: [webDataModel] = [
    
    webDataModel(name: "BugShaker", version: "0.5.1", holder: "Apache", link: "https://github.com/dtrenz/BugShaker/blob/develop/LICENSE"),
    
    //webDataModel(name: "TipJarViewController", version: "2.1.0", holder: "Apache", link: "https://github.com/lionheart/TipJarViewController/blob/master/LICENSE"),
    
    webDataModel(name: "lottie-ios", version: "3.3.0", holder: "Apache", link: "https://github.com/airbnb/lottie-ios/blob/master/LICENSE"),
    
    webDataModel(name: "ANActivityIndicator", version: "1.2.0", holder: "MIT", link: "https://github.com/anelad/ANActivityIndicator/blob/master/LICENSE"),
    
    webDataModel(name: "BrightnessToggle", version: "0.1.1", holder: "MIT", link: "https://github.com/lammertw/BrightnessToggle/blob/master/LICENSE"),
    
    webDataModel(name: "CTFeedbackSwift", version: "0.1.9", holder: "MIT", link: "https://github.com/rizumita/CTFeedbackSwift/blob/main/LICENSE"),
    
    webDataModel(name: "KMPlaceholderTextView", version: "1.4.0", holder: "MIT", link: "https://github.com/MoZhouqi/KMPlaceholderTextView/blob/master/LICENSE"),
    
    webDataModel(name: "PDFReader", version: "2.5.1", holder: "MIT", link: "https://github.com/Alua-Kinzhebayeva/iOS-PDF-Reader/blob/master/LICENSE.txt"),
    
    webDataModel(name: "RevenueCat", version: "4.6.1", holder: "MIT", link: "https://github.com/RevenueCat/purchases-ios/blob/main/LICENSE"),
    
    webDataModel(name: "S3SwiftUIAppRater", version: "0.0.6", holder: "MIT", link: "https://github.com/muhammedtanriverdi/S3SwiftUIAppRater/blob/master/LICENSE"),
    
    webDataModel(name: "SwiftAlertView", version: "2.2.1", holder: "MIT", link: "https://github.com/dinhquan/SwiftAlertView/blob/master/LICENSE")
]
