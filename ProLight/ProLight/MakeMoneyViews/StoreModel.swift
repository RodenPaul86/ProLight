//
//  Store.swift
//  Noel
//
//  Created by Paul on 7/30/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import StoreKit
import SwiftUI

class StoreModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedIds: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    func fetchProducts() {
        isLoading = true
        Task.init {
            do {
                let products = try await Product.products(for: ["pl2022MO"])
                DispatchQueue.main.async {
                    self.products = products
                    self.isLoading = false
                }
                
                if let product = products.first {
                    await isPurchased(product: product)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func isPurchased(product: Product) async {
        guard let state = await product.currentEntitlement else {
            return
        }
        
        switch state {
        case .verified(let transaction):
            DispatchQueue.main.async {
                self.purchasedIds.append(transaction.productID)
            }
        case .unverified(_, _):
            break
        }
    }
    
    func purchase(product: Product) {
        Task.init {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let varification):
                    switch varification {
                    case .verified(let transaction):
                        DispatchQueue.main.async {
                            self.purchasedIds.append(transaction.productID)
                        }
                    case .unverified(_, _):
                        break
                    }
                case .userCancelled:
                    break
                case .pending:
                    break
                @unknown default:
                    break
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }
}
