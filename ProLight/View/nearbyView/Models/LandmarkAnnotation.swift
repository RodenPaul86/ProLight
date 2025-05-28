//
//  LandmarkAnnotation.swift
//  ProLight
//
//  Created by Paul on 8/21/21.
//  Copyright © 2021 Studio4Designsoftware. All rights reserved.
//

import Foundation
import MapKit
import UIKit

final class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(landmark: Landmark) {
        self.title = landmark.name
        self.coordinate = landmark.coordinate
    }
}
