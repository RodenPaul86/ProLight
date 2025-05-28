//
//  SheetView.swift
//  ProLight
//
//  Created by Paul on 8/25/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import MapKit

struct SheetView: View {
    
    @Binding var offset: CGFloat
    var value: CGFloat
    
    let landmarks: [Landmark]
    
    var body: some View {
        
        VStack {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 50, height: 5)
                .padding()
            
            //BlurView...
            //For Dark Mode Adoption...
            .cornerRadius(15)
            
            List {
                ForEach(self.landmarks, id: \.id) { landmark in
                    
                    VStack(alignment: .leading) {
                        
                        Text(landmark.name)
                            .fontWeight(.bold)
                        
                        Text(landmark.address)
                            .font(.body)
                    }
                }
                .cornerRadius(15)
            }
            //.animation(nil)
        }
        .background(Blur(style: .systemMaterial))
        .cornerRadius(15)
    }
}

struct Blur : UIViewRepresentable {
    
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}
