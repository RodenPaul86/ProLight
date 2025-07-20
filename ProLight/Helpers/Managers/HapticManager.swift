//
//  HapticManager.swift
//  ProLight
//
//  Created by Paul  on 4/23/25.
//  Copyright © 2016 Studio4Designsoftware. All rights reserved.
//

import UIKit

enum HapticType {
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selection
}

class HapticManager {
    static let shared = hapticManager()
    
    private init() {}
    
    func notify(_ type: HapticType) {
        switch type {
        case .notification(let feedback):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(feedback)
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
