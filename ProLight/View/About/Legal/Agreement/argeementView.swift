//
//  Agreement.swift
//  Noel
//
//  Created by Paul on 5/15/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct agreementView: View {
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                VStack(alignment: .leading) {
                    Text("Studio 4 Design Software")
                        .font(.headline)
                    
                    Text("Copyright (c) \(getYear()) Studio 4 Design Software")
                        .font(.system(size: 15))
                    
                    
                    VStack(alignment: .leading) {
                        Text("Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ''Software''), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:")
                        
                        Text("The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.")
                            .padding(.vertical, 10)
                        
                        Text("THE SOFTWARE IS PROVIDED ''AS IS'', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
                    }
                    .font(.body)
                    .padding(.vertical, 5)
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .background(Color(.systemGray5).opacity(1.0))
            .modifier(CardModifier())
            .padding()
        }
    }
    
    func getYear() -> String {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currentYear = yearFormatter.string(from: Date())
        return "\(currentYear)"
    }
}

struct Agreement_Previews: PreviewProvider {
    static var previews: some View {
        agreementView()
    }
}
