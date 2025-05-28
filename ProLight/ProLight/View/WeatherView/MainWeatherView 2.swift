//
//  MainWeatherView.swift
//  ProLight
//
//  Created by Paul on 11/12/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI

struct MainWeatherView: View {
    @ObservedObject var weatherService = WeatherService.shared
    @State var isPermissionDisabled = true
    @State var showSafari = false
    
    var backToMAinVC: HomeVC?
    
    var body: some View {
        VStack {
            Button(action: {
                self.backToMAinVC?.presentedViewController?.dismiss(animated: true)
            }, label: {
                HStack {
                    
                }
            })
            
            Spacer()
            
            if let json = weatherService.liveForecast, !isPermissionDisabled {
                ScrollView(.vertical) {
                    VStack(alignment: .center) {
                        CurrentForecastView(current: json.current, city: weatherService.city)
                        HourlyForcastView(hourlyForecast: json.hourly)
                        DailyForecastView(dailyForecast: json.daily)
                        
                        HStack {
                            Text("Powered")
                                .foregroundColor(.gray)
                            
                            Text("by")
                                .foregroundColor(.gray)
                            
                            Button(action: { self.showSafari = true }, label: {
                                Text("OpenWeatherMap.org")
                            })
                            .sheet(isPresented: $showSafari) {
                                /*
                                SafariView(url:URL(string: "https://openweathermap.org")!).ignoresSafeArea()
                                 */
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            } else {
                loadingWeather()
                Spacer()
            }
        }
    }
}

struct MainWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        MainWeatherView()
    }
}

struct loadingWeather: View {
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
