//
//  AboutVC.swift
//  ProLight
//
//  Created by Paul on 8/12/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import WebKit

struct AboutVC: View {
    @Environment(\.openURL) var openURL
    @State private var showURL = "https://freesound.org"
    @State private var eula = "https://studio4designsoftware.weebly.com/prolight-EULA.html"
    @State private var privacy = "https://studio4designsoftware.weebly.com/prolight-policy.html"
    @State private var disclaimer = "https://studio4designsoftware.weebly.com/prolight-disclaimer.html"
    
    let kVersion = "CFBundleShortVersionString"
    let kBuild = "CFBundleVersion"
    
    var backToMAinVC: HomeVC?
    
    func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        return version
    }
    
    func getBuild() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let build = dictionary[kBuild] as! String
        return build
    }
    
    func getYear() -> String {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currentYear = yearFormatter.string(from: Date())
        return "\(currentYear)"
    }
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Form {
                    Section() {
                        if IAPManager.shared.isPremium() {
                            FormRowStaticView(icon: "crown", color: Color(UIColor.systemGray3), firstText: "Premium", secondText: "Active")
                        } else {
                            FormRowStaticView(icon: "star", color: .gray, firstText: "Premium", secondText: "Not Active")
                        }
                    }
                    .padding(.vertical, 3)
                    
                    Section(header: Text("app info")) {
                        FormRowStaticView(icon: "gear", color: .gray, firstText: "Application", secondText: Bundle.main.displayName)
                        
                        FormRowStaticView(icon: "swift", color: .gray, firstText: "Language".localized(), secondText: "Swift / SwiftUI")
                        
                        FormRowStaticView(icon: "square.on.square.dashed", color: .gray, firstText: "Version", secondText: getVersion())
                        
                        FormRowStaticView(icon: "hammer", color: .gray, firstText: "Build", secondText: getBuild())
                        
                        NavigationLink(destination: {
                            WebView(request: URLRequest(url: URL(string: showURL)!)).ignoresSafeArea()
                                .navigationTitle("FreeSound.org")
                                .toolbar {
                                    Button {
                                        openURL(URL(string: showURL)!)
                                    } label: {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "link", firstText: "Sounds", secondText: "FreeSound.org")
                        })
                    }
                    .padding(.vertical, 3)
                    
                    Section() {
                        FormRowStaticView(icon: "keyboard", color: .gray, firstText: "Developer", secondText: "Paul Roden II")
                        
                        Message(bodyText: "ProLight was created by a single developer. I rely on your support and encouragement to continue its development. \n\nMy goal is to expand and enhance ProLight over time so that as a Subscriber you feel you are constantly getting your money's worth. \n\nThank You!")
                    }
                    .padding(.vertical, 3)
                    
                    Section(header: Text("Legal")) {
                        NavigationLink(destination: {
                            licensesView()
                                .navigationTitle("Licenses")
                        }, label: {
                            legalDocs(icon: "doc", firstText: "Open Source", secondText: "Licenses")
                        })
                    }
                    .padding(.vertical, 3)
                    
                    Section() {
                        NavigationLink(destination: {
                            WebView(request: URLRequest(url: URL(string: eula)!)).ignoresSafeArea()
                                .navigationTitle("EULA")
                                .toolbar {
                                    Button {
                                        openURL(URL(string: eula)!)
                                    } label: {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "doc", firstText: "End User License Agreement", secondText: "")
                        })
                        
                        NavigationLink(destination: {
                            WebView(request: URLRequest(url: URL(string: privacy)!)).ignoresSafeArea()
                                .navigationTitle("Privacy Notice")
                                .toolbar {
                                    Button {
                                        openURL(URL(string: privacy)!)
                                    } label: {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "doc", firstText: "Privacy Notice", secondText: "")
                        })
                        
                        NavigationLink(destination: {
                            WebView(request: URLRequest(url: URL(string: disclaimer)!)).ignoresSafeArea()
                                .navigationTitle("Disclaimer")
                                .toolbar {
                                    Button {
                                        openURL(URL(string: disclaimer)!)
                                    } label: {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "doc", firstText: "Disclaimer", secondText: "")
                        })
                    }
                    .padding(.vertical, 3)
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                
                // MARK: - FOOTER
                Text("© 2016 - \(getYear()) Studio 4 Design Software \n Made in Illinois, USA 🇺🇸")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
                    .foregroundColor(Color.secondary)
                
            }
            .navigationBarTitle("About", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.backToMAinVC?.presentedViewController?.dismiss(animated: true)
                    } label: {
                        Text("Close")
                            .bold()
                            .foregroundColor(.green)
                    }
                }
            })
        }
    }
}

// MARK: - PREVIEW
struct AboutVC_Previews: PreviewProvider {
    static var previews: some View {
        AboutVC()
    }
}
