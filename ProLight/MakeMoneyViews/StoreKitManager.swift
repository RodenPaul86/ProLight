//
//  StoreKitManager.swift
//  ProLight
//
//  Created by Paul on 7/21/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import StoreKit

class StoreKitManager: NSObject, ObservableObject,SKProductsRequestDelegate {
    @Published var product: SKProduct?
    @Published var isSpecialOffer = false
    
    func fetchProductPrice(productIdentifier: String) {
        let productIds: Set<String> = [productIdentifier]
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            DispatchQueue.main.async { [weak self] in
                self?.product = product
                self?.isSpecialOffer = self?.isProductSpecialOffer(product) ?? false
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error fetching product: \(error.localizedDescription)")
    }
    
    func isProductSpecialOffer(_ product: SKProduct) -> Bool {
        return product.localizedPrice == "$0.99"
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? ""
    }
}
