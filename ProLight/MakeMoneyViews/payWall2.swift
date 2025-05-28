//
//  paywall2.swift
//  ProLight
//
//  Created by Paul on 1/29/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct payWall2: View {
    @ObservedObject var storeKitManager = StoreKitManager()
    let productIdentifier = "pl2022MO"
    
    var body: some View {
        VStack {
            if let product = storeKitManager.product {
                Button(action: {}, label: {
                    Text("Buy for \(product.localizedPrice)")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(10)
                })
                .overlay(
                    ZStack {
                        if storeKitManager.isSpecialOffer {
                            Capsule()
                                .fill(Color.red)
                                .frame(width: 80, height: 20)
                                .offset(x: 10, y: -10)
                            
                            Text("10% Off")
                                .foregroundColor(.white)
                                .offset(x: 10, y: -10)
                        }
                    }, alignment: .topTrailing
                )
                .padding()
            } else {
                
            }
            Button(action: {
                storeKitManager.fetchProductPrice(productIdentifier: productIdentifier)
            }, label: {
                Text("Fetch Price")
            })
        }
    }
}

struct payWall2_Previews: PreviewProvider {
    static var previews: some View {
        payWall2()
    }
}
