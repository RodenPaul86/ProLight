//
//  IAPManager.swift
//  ProLight
//
//  Created by Paul on 8/5/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import Foundation
import RevenueCat
import StoreKit
import SwiftAlertView

final class IAPManager {
    static let shared = IAPManager()
    
    private init() {}
    
    func configure() {
        Purchases.configure(withAPIKey: "\(APIKeys.revenueCatAPI)")
    }
    
    func isPremium() -> Bool {
        return UserDefaults.standard.bool(forKey: "pro")
    }
    
    public func getSubscriptionStatus(completion: ((Bool) -> Void)?) {
        Purchases.shared.getCustomerInfo { info, error in
            guard let entitlements = info?.entitlements, error == nil else { return }
            if entitlements.all["Premium"]?.isActive == true {
                print("Got updated status of subscribed")
                UserDefaults.standard.set(true, forKey: "pro")
                completion?(true)
            } else {
                print("Got updated status of NOT subscribed")
                UserDefaults.standard.set(false, forKey: "pro")
                completion?(false)
            }
        }
    }
    
    public func fetchPackage(completion: @escaping (Package?) -> Void) {
        Purchases.shared.getOfferings { offerings, error in
            guard let package = offerings?.offering(identifier: "fullAccess")?.availablePackages.first, error == nil else {
                completion(nil)
                return
            }
            completion(package)
        }
    }
    
    public func subscribe(package: Package, completion: @escaping (Bool) -> Void) {
        guard !isPremium() else {
            completion(true)
            return
        }
        
        Purchases.shared.purchase(package: package) { transaction, info, error, userCancelled in
            guard let transaction = transaction,
                  let entitlements = info?.entitlements,
                  error == nil,
                  !userCancelled else { return }
            
            switch transaction.sk1Transaction?.transactionState {
            case .purchasing:
                print("purchasing")
            case .purchased:
                if entitlements.all["Premium"]?.isActive == true {
                    print("purchased!")
                    UserDefaults.standard.set(true, forKey: "pro")
                    completion(true)
                } else {
                    print("purchase failed!")
                    UserDefaults.standard.set(false, forKey: "pro")
                    completion(false)
                }
            case .failed:
                print("failed")
                SwiftAlertView.show(title: "User Had Cancelled",
                                    message: "Purchase was cancelled.",
                                    buttonTitles: "OK") { alert in
                    alert.style = .auto
                    alert.buttonTitleColor = .systemBlue
                    alert.cancelButtonIndex = 0
                    alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
                }
            case .restored:
                print("restored")
                SwiftAlertView.show(title: "Sussessfully Restored Purchase",
                                    message: "Purchase was restored.",
                                    buttonTitles: "OK") { alert in
                    alert.style = .auto
                    alert.buttonTitleColor = .systemBlue
                    alert.cancelButtonIndex = 0
                    alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
                }
            case .deferred:
                print("deferred")
            case .none:
                break
            @unknown default:
                print("default case")
            }
        }
    }
    
    public func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { info, error in
            guard let entitlements = info?.entitlements, error == nil else { return }
            if entitlements.all["fullAccess"]?.isActive == true {
                print("restored success")
                UserDefaults.standard.set(true, forKey: "pro")
                completion(true)
            } else {
                print("restored failed!")
                UserDefaults.standard.set(false, forKey: "pro")
                completion(false)
            }
        }
    }
}
