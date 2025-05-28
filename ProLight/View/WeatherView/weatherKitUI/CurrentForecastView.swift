//
//  CurentForecastView.swift
//  ProLight
//
//  Created by Paul on 1/10/23.
//  Copyright © 2023 Studio4Designsoftware. All rights reserved.
//

import Foundation
import SwiftUI
import WeatherKit
import CoreLocation

struct CurrentForecastView: View {
    let currentDate: String
    let conditionImage: String
    let currentTemp: String
    let condition: String
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Current Forecast")
                    .font(.caption)
                    .opacity(0.5)
                
                Spacer()
                
                Text(currentDate)
                    .font(.caption)
                    .opacity(0.5)
            }
            
            VStack {
                HStack {
                    Image(systemName: "\(conditionImage)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.trailing)
                    
                    Text(currentTemp)
                        .font(.system(size: 50))
                        .fontWeight(.light)
                }
                .foregroundColor(.green)
                
                HStack {
                    /*
                    VStack(alignment: .center) {
                        Image(systemName: "sunrise")
                        Text("00:00")
                    }
                    .padding(.leading)
                    .foregroundColor(.white)
                    .font(.caption)
                     */
                    
                    //Spacer()
                    
                    Text(condition)
                        .font(.system(size: 15))
                    
                    //Spacer()
                    
                    /*
                    VStack(alignment: .center) {
                        Image(systemName: "sunset")
                        Text("00:00")
                    }
                    .padding(.trailing)
                    .foregroundColor(.white)
                    .font(.caption)
                     */
                }
                .opacity(0.5)
            }
            .padding()
        }
        .padding()
        .frame(height: 170)
        .background(Color(.systemGray5))
        .modifier(CardModifier())
    }
}

extension String {
    var capitalizedSentence: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
