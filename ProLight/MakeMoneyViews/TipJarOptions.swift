//
//  TipJarOptions.swift
//  ProLight
//
//  Created by Paul Roden II on 4/5/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import TipJarViewController

struct TipJarOptions: TipJarConfiguration {
    static var topHeader = "Hi There"
    static var topDescription = "If you've been enjoying ProLight and would like to show your support, please consider a tip. They go such a long way, and every little bit helps. Thanks! :)"

    static func subscriptionProductIdentifier(for row: SubscriptionRow) -> String {
        switch row {
        case .monthly: return "pl2022MT"
        case .yearly: return "pl2022YT"
        }
    }

    static func oneTimeProductIdentifier(for row: OneTimeRow) -> String {
        switch row {
        case .small: return "pl2022T1"
        case .medium: return "pl2022T2"
        case .large: return "pl2022T3"
        case .huge: return "pl2022T4"
        case .massive: return "pl2022T5"
        }
    }
    
    static var privacyPolicyURLString = "https://studio4designsoftware.weebly.com/prolight-policy.html"
    static var termsOfUseURLString = "https://studio4designsoftware.weebly.com/prolight-terms.html"
}
