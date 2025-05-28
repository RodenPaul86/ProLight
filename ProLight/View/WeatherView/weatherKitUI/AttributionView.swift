//
//  AttributionView.swift
//  ProLight
//
//  Created by Paul on 9/1/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct AttributionView: View {
    let logo: URL
    let link: URL
    
    var body: some View {
        VStack {
            AsyncImage(url: logo) { image in
                image
                    .resizable()
                    .frame(width: 110, height: 20)
                    .clipShape(Rectangle())
            } placeholder: {
                ProgressView()
            }
            .frame(width: 110, height: 20)
            
            NavigationLink(destination: {
                webView(url: "\(link)").edgesIgnoringSafeArea(.bottom)
                    .navigationTitle("\(link)")
                    .toolbar {
                        Link(destination: URL(string: "\(link)")!) {
                            Image(systemName: "safari")
                        }
                    }
            }, label: {
                Text("Other data sources")
            })
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.8))
    }
}
