//
//  Extensions and Representables.swift
//  ProLight
//
//  Created by Paul on 9/1/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

// Extensions
extension Date {
    var displayYear: String {
        self.formatted(.dateTime.year())
    }
}

// UIViewRepresentables
struct webView: UIViewRepresentable {
    var url: String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
    }
}
