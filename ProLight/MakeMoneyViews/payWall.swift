//
//  payWall.swift
//  ProLight
//
//  Created by Paul on 8/5/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import RevenueCat
import StoreKit
import SwiftAlertView
import WebKit
import Lottie

struct payWall: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var store = StoreModel()
    @Environment(\.openURL) var openURL
    
    @State private var privacy = "https://studio4designsoftware.weebly.com/prolight-policy.html"
    @State private var terms = "https://studio4designsoftware.weebly.com/prolight-terms.html"
    
    @State private var isLoading = false
    private let loadingDuration: TimeInterval = 60 // 1 minute in seconds
    
    var backToMAinVC: HomeVC?
    var backToMainView: ScreenVC?
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    VStack {
                        VStack(spacing: 0) {
                            Image("App_00")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .cornerRadius(15)
                                .padding()
                            
                            Text("ProLight Premium")
                                .font(.system(size: 30).bold())
                            
                            Text("Illuminate Your Path!")
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.system(.body))
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                        .padding(.top, 20)
                        
                        //Payment button.
                        if let product = store.products.first {
                            Button {
                                isLoading = true
                                
                                IAPManager.shared.fetchPackage { package in
                                    guard let package = package else { return }
                                    IAPManager.shared.subscribe(package: package) { success in
                                        print("Purchase: \(success)")
                                        if success {
                                            isLoading = false
                                            dismiss()
                                        } else {
                                            isLoading = false
                                            SwiftAlertView.show(title: "Subscription Failed",
                                                                message: "We are unable to complete your transaction.",
                                                                buttonTitles: "OK") { alert in
                                                alert.style = .auto
                                                alert.buttonTitleColor = .systemBlue
                                                alert.cancelButtonIndex = 0
                                                alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                                                alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                payButton(subPeriod: "Start a 1-Week Free Trial",
                                          price: "\(product.displayPrice)/month after")
                            }
                        } else {
                            btnLoadingView(fileName: "loadingWheel2")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .modifier(CardModifier())
                    .padding([.trailing, .leading, .top])
                    
                    // Included in the subscription.
                    includedCard()
                    
                    // Privacy...
                    HStack {
                        NavigationLink(destination: {
                            webView(url: privacy).edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("\(privacy)")
                                .toolbar {
                                    Link(destination: URL(string: "\(privacy)")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            Text("Privacy Notice")
                        })
                        
                        Text("and")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        NavigationLink(destination: {
                            webView(url: terms).edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("\(terms)")
                                .toolbar {
                                    Link(destination: URL(string: "\(terms)")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            Text("Terms of Use")
                        })
                    }
                    .padding()
                }
                .navigationBarTitle("Subscription", displayMode: .inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .bold()
                                .foregroundColor(.green)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isLoading = true
                            
                            IAPManager.shared.restorePurchases { success in
                                print("Restored: \(success)")
                                DispatchQueue.main.async {
                                    if success {
                                        isLoading = false
                                        dismiss()
                                    } else {
                                        isLoading = false
                                        SwiftAlertView.show(title: "No Active Subscription",
                                                            message: "You don't currently have an active ProLight subscription. Please make sure you are logged in with the correct App Store account and try again.",
                                                            buttonTitles: "OK") { alert in
                                            alert.style = .auto
                                            alert.buttonTitleColor = .systemBlue
                                            alert.cancelButtonIndex = 0
                                            alert.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                                            alert.messageLabel.font = UIFont.systemFont(ofSize: 15)
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text("Restore")
                                .bold()
                                .foregroundColor(.green)
                        }
                    }
                })
                .onAppear(perform: store.fetchProducts)
            }
            
            if isLoading {
                loadingView()
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            startTimer()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: loadingDuration, repeats: false) { _ in
            // Update the state after the specified duration
            isLoading = false
        }
    }
}

struct payWall_Previews: PreviewProvider {
    static var previews: some View {
        payWall()
    }
}

// loading view 
struct loadingView: View {
    var body: some View {
        VStack {
            Text("Loading...")
                .foregroundColor(.black)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                .scaleEffect(2)
                .padding()
        }
        .frame(width: 150, height: 150)
        .background(Color.secondary)
        .foregroundColor(Color.primary)
        .cornerRadius(20)
    }
}
