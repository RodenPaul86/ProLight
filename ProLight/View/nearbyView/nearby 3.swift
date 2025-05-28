//
//  nearby.swift
//  ProLight
//
//  Created by Paul on 8/20/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct nearby: View {
    @State private var viewModel = mapViewModel()
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    @State private var isSearching = false
    @State var offset: CGFloat = 0
    
    var backToMAinVC: HomeVC?
    
    private func getNearByLandmarks() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
            }
        }
    }
    
    func calculateOffset() -> CGFloat {
        if self.landmarks.count > 0 && !self.tapped {
            return UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 4
        } else if self.tapped {
            return 100
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                
                MapView(landmarks: landmarks)
                    .edgesIgnoringSafeArea(.bottom)
                    .onAppear {
                        viewModel.checkIfLocationServicesIsEnabled()
                    }
                
                // MARK: Search Bar
                HStack(spacing: 15) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $search, onEditingChanged: { _ in }) {
                        self.getNearByLandmarks()
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            if isSearching {
                                Button(action: {
                                    search = ""
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                })
                            }
                        }.padding(.horizontal, 10)
                        .foregroundColor(.gray)
                    ).transition(.move(edge: .trailing))
                    //.animation(.spring())
                    
                    if isSearching {
                        Button(action: {
                            isSearching = false
                            search = ""
                            
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                        }, label: {
                            Text("Cancel")
                                .padding(.trailing)
                                .padding(.leading, 0)
                                .foregroundColor(Color(Theme.current.cancelText))
                                .buttonStyle(PlainButtonStyle())
                                .font(.none)
                        })
                        .transition(.move(edge: .trailing))
                        //.animation(.spring())
                    }
                }
                .padding(.vertical, 10)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(6)
                .padding(.horizontal)
                .background(Blur(style: .systemMaterial))
                
            }
            
            /*
            .alert(isPresented: $locationManager.permissionDenied, content: {
                
                Alert(title: Text("Permission Denied"), message: Text("Please Enable Location Permissions In App Settings "), dismissButton: .default(Text("Go To Settings"), action: {
                    
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
            })
             */
            
            .navigationBarTitle("Nearby Places", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                self.backToMAinVC?.presentedViewController?.dismiss(animated: true)
            }, label: {
                Text("Cancel")
                    .foregroundColor(Color(Theme.current.cancelText))
                    .buttonStyle(PlainButtonStyle())
                    .font(.none)
            }),
                                
            trailing: Button(action: {
                // TODO: Reset The view...
            }, label: {
                Text("Reset")
                    .foregroundColor(Color(Theme.current.cancelText))
                    .buttonStyle(PlainButtonStyle())
                    .font(.none)
            }))
        }
    }
}

struct nearby_Previews: PreviewProvider {
    static var previews: some View {
        nearby()
    }
}
