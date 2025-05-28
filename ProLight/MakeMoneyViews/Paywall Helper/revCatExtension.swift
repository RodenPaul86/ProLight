//
//  File.swift
//  ProLight
//
//  Created by Paul on 2/2/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import Foundation
import RevenueCat
import StoreKit

extension Package {
    func termsDescription() -> String {
        if let intro = storeProduct.introductoryDiscount {
            if intro.price == .zero {
                return "\(intro.subscriptionPeriod) free trial"
            } else if let priceString = localizedIntroductoryPriceString {
                return "\(priceString) for \(intro.subscriptionPeriod)"
            }
        }
        return "Unlocks Premium"
    }
}

@available(iOS 18.4, *)
extension StoreKit.SubscriptionPeriod {
    var durationTitle: String {
        switch unit {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        @unknown default: return "Unknown"
        }
    }

    var periodTitle: String {
        let period = "\(value) \(durationTitle)"
        return value > 1 ? "\(period)s" : period
    }
}
