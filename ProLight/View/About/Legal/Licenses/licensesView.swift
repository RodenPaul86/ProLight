//
//  LicensesVC.swift
//  ProLight
//
//  Created by Paul Roden II on 4/8/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct licensesView: View {
    @Environment(\.openURL) var openURL
    
    var dependencies: [webDataModel] = packageDependencies
    
    var body: some View {
        List {
            Section(header: Text("dependencies")) {
                ForEach(dependencies) { items in
                    NavigationLink(destination: {
                        webView(url: items.link).edgesIgnoringSafeArea(.bottom)
                            .navigationTitle("\(items.link)")
                            .toolbar {
                                Link(destination: URL(string: "\(items.link)")!) {
                                    Image(systemName: "safari")
                                }
                            }
                    }, label: {
                        VStack(alignment: .leading) {
                            Text("\(items.name) - v\(items.version)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(items.holder)
                                .font(.subheadline)
                                .foregroundColor(Color.blue)
                        }
                    })
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct licenses_Previews: PreviewProvider {
    static var previews: some View {
        licensesView()
    }
}
