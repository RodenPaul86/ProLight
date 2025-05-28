//
//  Compass.swift
//  ProLight
//
//  Created by Paul on 6/30/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import SwiftUI
import CoreLocation

struct Compass: View {
    @ObservedObject var compassHeading = CompassHeading()
    
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 5,
                       height: 50)
            
            ZStack {
                ForEach(Marker.markers(), id: \.self) { marker in
                    CompassMarkerView(marker: marker,
                                      compassDegress: self.compassHeading.degrees)
                }
            }
            .frame(width: 300, height: 300)
            .rotationEffect(Angle(degrees: self.compassHeading.degrees))
            .statusBar(hidden: true)
            
            Text("\(compassHeading.degrees)")
                .font(.system(size: 55))
                .padding()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Latitude:")
                    
                    Text("00° 00' 00'' N")
                        .font(.system(size: 30))
                }
                
                HStack {
                    Text("Longitude:")
                    
                    Text("00° 0' 00'' E")
                        .font(.system(size: 30))
                }
                
                HStack {
                    Text("Elevation:")
                    
                    Text("0,000 m")
                        .font(.system(size: 30))
                }
                
                HStack {
                    Text("Sunrise:")
                    
                    Text("6:00 AM")
                        .font(.system(size: 30))
                }
                
                HStack {
                    Text("Sunset:")
                    
                    Text("4:00 PM")
                        .font(.system(size: 30))
                }
            }
        }
    }
}

struct Compass_Previews: PreviewProvider {
    static var previews: some View {
        Compass()
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
