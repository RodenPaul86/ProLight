//
//  CompassViewModel.swift
//  ProLight
//
//  Created by Paul  on 8/11/25.
//

import SwiftUI
import CoreLocation

class CompassViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0
    @Published var directionText: String = "N"
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return } // invalid reading
        let newAngle = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        DispatchQueue.main.async {
            self.heading = newAngle
            self.directionText = self.headingToDirection(angle: newAngle)
        }
    }
    
    private func headingToDirection(angle: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((angle + 22.5) / 45.0) & 7
        return directions[index]
    }
}

struct CompassView: View {
    @StateObject private var viewModel = CompassViewModel()
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let tickOuterRadius = size / 2
            let tickInnerRadiusMajor = size / 2 - 10
            let tickInnerRadiusMinor = size / 2 - 5
            
            ZStack {
                // MARK: Outer Black Circle
                Circle()
                    .fill(Color.black)
                    .frame(width: size, height: size)
                
                // MARK: Tick Marks
                ForEach(0..<36) { tick in
                    Rectangle()
                        .fill(tick % 3 == 0 ? Color.white : Color.gray)
                        .frame(width: 2, height: tick % 3 == 0 ? size * 0.05 : size * 0.025)
                        .offset(y: -(tickOuterRadius - size * 0.05))
                        .rotationEffect(.degrees(Double(tick) * 10))
                }
                
                // MARK: N/E/S/W Labels
                VStack {
                    Text("N").foregroundColor(.red).font(.system(size: size * 0.10, weight: .bold))
                    Spacer()
                    Text("S").foregroundColor(.white).font(.system(size: size * 0.10, weight: .bold))
                }
                .frame(height: size * 0.8)
                
                HStack {
                    Text("W").foregroundColor(.white).font(.system(size: size * 0.10, weight: .bold))
                    Spacer()
                    Text("E").foregroundColor(.white).font(.system(size: size * 0.10, weight: .bold))
                }
                .frame(width: size * 0.8)
                
                // MARK: Rotating red arrow ring
                ZStack {
                    Circle()
                        .stroke(Color.red, lineWidth: size * 0.02)
                        .frame(width: size * 0.9, height: size * 0.9)
                    
                    // MARK: Red pointer at North
                    Image(systemName: "arrowtriangle.up.fill")
                        .resizable()
                        .frame(width: size * 0.09, height: size * 0.18)
                        .foregroundColor(.red)
                        .offset(y: -(size / 2) + size * 0.1)
                }
                .rotationEffect(.degrees(-viewModel.heading))
                
                // MARK: Center direction text
                Text(viewModel.directionText)
                    .font(.system(size: size * 0.18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
