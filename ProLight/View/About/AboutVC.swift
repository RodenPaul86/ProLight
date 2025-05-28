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
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Form {
                    Section() {
                        if IAPManager.shared.isPremium() {
                            FormRowStaticView(icon: "crown.fill", color: Color(.systemGreen), firstText: "Membership", secondText: "Active")
                        } else {
                            FormRowStaticView(icon: "star.fill", color: Color(.systemGreen), firstText: "Membership", secondText: "Not Active")
                        }
                    }
                    .padding(.vertical, 3)
                    
                    Section(header: Text("app info")) {
                        FormRowStaticView(icon: "gear", color: Color(.systemGreen), firstText: "Application", secondText: Bundle.main.displayName)
                        
                        FormRowStaticView(icon: "swift", color: Color(.systemGreen), firstText: "Language", secondText: "Swift / SwiftUI")
                        
                        FormRowStaticView(icon: "square.on.square.dashed", color: Color(.systemGreen), firstText: "Version", secondText: getVersion())
                        
                        FormRowStaticView(icon: "hammer", color: Color(.systemGreen), firstText: "Build", secondText: getBuild())
                        
                        NavigationLink(destination: {
                            webView(url: showURL).edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("\(showURL)")
                                .toolbar {
                                    Link(destination: URL(string: "\(showURL)")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "link", firstText: "Sounds", secondText: "FreeSound.org")
                        })
                    }
                    .padding(.vertical, 3)
                    
                    Section() {
                        FormRowStaticView(icon: "keyboard", color: Color(.systemGreen), firstText: "Developer", secondText: "Paul Roden Jr")
                        
                        Message(bodyText: "ProLight, crafted by a single dedicated developer, relies on your support to grow. Together, we'll continuously expand and enrich the experience, ensuring you always get the most out of your subscription. Thank you for being a part of this journey!")
                        
                        NavigationLink(destination: {
                            webView(url: "https://github.com/RodenPaul86").edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("https://github.com/RodenPaul86")
                                .toolbar {
                                    Link(destination: URL(string: "https://github.com/RodenPaul86")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "link", firstText: "github.com", secondText: "")
                        })
                        
                        NavigationLink(destination: {
                            webView(url: "https://www.buymeacoffee.com/paulRoden").edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("https://www.buymeacoffee.com/paulRoden")
                                .toolbar {
                                    Link(destination: URL(string: "https://www.buymeacoffee.com/paulRoden")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "link", firstText: "buymeacoffee.com", secondText: "")
                        })
                    }
                    .padding(.vertical, 3)
                    
                    Section(header: Text("Legal")) {
                        NavigationLink(destination: {
                            licensesView()
                                .navigationTitle("Licenses")
                                .navigationBackButton(color: .green, text: "Back")
                        }, label: {
                            legalDocs(icon: "doc.fill", firstText: "Open Source", secondText: "Licenses")
                        })
                    }
                    .padding(.vertical, 3)
                    
                    Section() {
                        NavigationLink(destination: {
                            webView(url: eula).edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("\(eula)")
                                .toolbar {
                                    Link(destination: URL(string: "\(eula)")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "doc.fill", firstText: "End User License Agreement", secondText: "")
                        })
                        
                        NavigationLink(destination: {
                            webView(url: privacy).edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("\(privacy)")
                                .toolbar {
                                    Link(destination: URL(string: "\(privacy)")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "doc.fill", firstText: "Privacy Notice", secondText: "")
                        })
                        
                        NavigationLink(destination: {
                            webView(url: disclaimer).edgesIgnoringSafeArea(.bottom)
                                .navigationTitle("\(disclaimer)")
                                .toolbar {
                                    Link(destination: URL(string: "\(disclaimer)")!) {
                                        Image(systemName: "safari")
                                    }
                                }
                        }, label: {
                            ClickableLink(icon: "doc.fill", firstText: "Disclaimer", secondText: "")
                        })
                    }
                    .padding(.vertical, 3)
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                
                // MARK: - FOOTER
                Text("© 2016 - \(Date().displayYear) Studio 4 Design Software \n Made in Illinois, USA 🇺🇸")
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
                        Text("Cancel")
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
