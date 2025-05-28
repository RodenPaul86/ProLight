//
//  CardViewController.swift
//  ProLight
//
//  Created by Paul on 5/25/19.
//  Copyright © 2019 Studio4Designsoftware. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class CardViewController: UIViewController {
    override var shouldAutorotate: Bool {
        return false
    }
    
// MARK: Outlets
    @IBOutlet weak var indicatorLine: UIImageView!
    @IBOutlet weak var handleArea: UIView!
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var huntBtn: UIButton!
    @IBOutlet weak var mapOptions: UISegmentedControl!
    
    @IBOutlet weak var tripInfoView: UIVisualEffectView!
    @IBOutlet weak var arrTimeLabel: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    
    let annotation = MKPointAnnotation()
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var steps = [MKRoute.Step]()
    let speechSynthesizer = AVSpeechSynthesizer()
    var stepCounter = 0
    var pressed = false
    
    @IBOutlet weak var walkingBtn: UIButton!
    
// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        mapPointOfInterestCategorys()
        self.becomeFirstResponder()
        mapView.showsUserLocation = true
        
        walkingBtn.isHidden = true
        currentDistance.isHidden = true
        
        //walkingBtn.alpha = 0
        //walkingBtn.layer.cornerRadius = 12
        //walkingBtn.clipsToBounds = true
        
        mapView.layer.cornerRadius = 12
        mapView.clipsToBounds = true
        mapView.pointOfInterestFilter?.includes(MKPointOfInterestCategory.park)
        mapView.pointOfInterestFilter?.excludes(MKPointOfInterestCategory.school)
        
        tripInfoView.layer.cornerRadius = 25
        tripInfoView.clipsToBounds = true
        tripInfoView.isHidden = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let nonSelectedTitleText = [NSAttributedString.Key.foregroundColor: UIColor.white]
        mapOptions.setTitleTextAttributes(nonSelectedTitleText, for: .normal)
        
        let selectedTitleText = [NSAttributedString.Key.foregroundColor: UIColor.black]
        mapOptions.setTitleTextAttributes(selectedTitleText, for: .selected)
        
        searchBar.placeholder = "Where would you like to go?"
    }
    
    private func mapPointOfInterestCategorys() {
        let categories:[MKPointOfInterestCategory] = [.park, .police, .restaurant, .restroom]
        let filters = MKPointOfInterestFilter(including: categories)
        mapView.pointOfInterestFilter = .some(filters)
    }
    
    @IBAction func startBtn(_ sender: Any) {
        pressed = !pressed
        
        if pressed {
            walkingBtn.setTitle("End Walk", for: .normal)
            walkingBtn.backgroundColor = UIColor.systemRed
            
            locationManager.startUpdatingLocation()
            
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            
        } else {
            walkingBtn.setTitle("Start Walk", for: .normal)
            walkingBtn.backgroundColor = UIColor.systemGreen
            
            locationManager.stopUpdatingLocation()
            
            directionsLabel.text = ""
            searchBar.text = ""
            
            mapOptions.selectedSegmentIndex = 0
            mapView.mapType = .standard
            
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            
            mapView.showsUserLocation = true
            mapView.removeAnnotation(annotation)
            
            //tripInfoView.isHidden = true
            walkingBtn.alpha = 0
            
            recenterUser()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
// MARK: Actions
    @IBAction func segControlAction(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            mapView.mapType = .standard
        case 1:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            mapView.mapType = .hybrid
        case 2:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            mapView.mapType = .hybridFlyover
        default:
            break;
        }
    }
    
    @IBAction func heading(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        pressed = !pressed
        if pressed {
            mapView.userTrackingMode = .followWithHeading
            let image = UIImage(named: "trackOff") as UIImage?
            huntBtn.setImage(image, for: .normal)
        } else {
            mapView.userTrackingMode = .none
            let image = UIImage(named: "trackOn") as UIImage?
            huntBtn.setImage(image, for: .normal)
        }
    }
    
    @IBAction func resetMap(_ sender: Any) {
        let message = "map reset"
        directionsLabel.text = message
        let speechUtterance = AVSpeechUtterance(string: message)
        speechSynthesizer.speak(speechUtterance)
        
        directionsLabel.text = ""
        searchBar.text = ""
        
        mapOptions.selectedSegmentIndex = 0
        mapView.mapType = .standard
        
        let overlays = self.mapView.overlays
        self.mapView.removeOverlays(overlays)
        
        mapView.showsUserLocation = true
        mapView.removeAnnotation(annotation)
        
        //tripInfoView.isHidden = true
        walkingBtn.alpha = 0
        
        mapView.userTrackingMode = .none
        let image = UIImage(named: "trackOn") as UIImage?
        huntBtn.setImage(image, for: .normal)
        
        recenterUser()
    }
    
    
// MARK: Functions
    func recenterUser() {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destination
        directionsRequest.transportType = .walking
        directionsRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            guard let response = response else { return }
            guard let primaryRoute = response.routes.first else { return }
            
            self.mapView.addOverlay(primaryRoute.polyline)
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0)})
            self.steps = primaryRoute.steps
            
            for i in 0 ..< primaryRoute.steps.count {
                
                let step = primaryRoute.steps[i]
                
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                //self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
                
                let eta = primaryRoute.expectedTravelTime
                self.printSecondsToHoursMinutesSeconds(seconds: Int(eta))
                
                self.currentDistance.text = "Current distance away: \(step.distance.miles()) miles"
            }
            
            let initialMessage = "\(self.steps[1].instructions)"
            self.directionsLabel.text = initialMessage
            let speechUtterance = AVSpeechUtterance(string: initialMessage)
            self.speechSynthesizer.speak(speechUtterance)
            self.stepCounter += 1
            self.zoomToPolyLine(map: self.mapView, polyLine: primaryRoute.polyline, animated: true)
        }
    }
    
    // converting seconds to regular time
    func printSecondsToHoursMinutesSeconds (seconds:Int) -> () {
        //let (h, m, _) = secondsToHoursMinutesSeconds (seconds: Double(seconds))
        //arrTimeLabel.text = "Your arriving in: \(h.clean) Hours, \(m.clean) Minutes"
    }
    
    func secondsToHoursMinutesSeconds (seconds : Double) -> (Double, Double, Double) {
        let (hr,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (hr, min, 60 * secf)
    }
    
// MARK: zoom polyLine
    func zoomToPolyLine(map: MKMapView, polyLine: MKPolyline, animated: Bool) {
        var regionRect = polyLine.boundingMapRect
        
        let widthPadding = regionRect.size.width * 0.80
        let heightPadding = regionRect.size.height * 0.80

        //Add padding to the region
        regionRect.size.width += widthPadding
        regionRect.size.height += heightPadding

        //Center the region on the line
        regionRect.origin.x -= widthPadding / 2
        regionRect.origin.y -= heightPadding / 2
        
        map.setRegion(MKCoordinateRegion(regionRect), animated: animated)
    }
    // MARK: - End Of Code...
}


// MARK: Extensions
extension CardViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.userTrackingMode = .follow
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("entered")
        stepCounter += 1
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            let message = "Travel \(currentStep.distance.miles()) miles, then you would \(currentStep.instructions)"
            directionsLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
            
            locationManager.startUpdatingLocation()
            
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            
            // Update text for "Current Distence..."
            
        } else {
            let message = "You have arrived..."
            directionsLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
            stepCounter = 0
            locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
        }
    }
}

extension CardViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let region = MKCoordinateRegion(center: currentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        localSearchRequest.region = region
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (response, error) in
            guard let response = response else { return }
            guard let firstMapItem = response.mapItems.first else { return }
            self.getDirections(to: firstMapItem)
            
            // Remove old search polyLines
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            
            //self.tripInfoView.isHidden = false
            
            UIView.animate(withDuration: 2.5, animations: { () -> Void in
                self.walkingBtn.alpha = 1
            })
            
            self.addPinToMapView(title: firstMapItem.name, subtitle: firstMapItem.phoneNumber, latitude: firstMapItem.placemark.location!.coordinate.latitude, longitude: firstMapItem.placemark.location!.coordinate.longitude)
        }
    }
    
    
    func addPinToMapView(title: String?, subtitle: String?, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if let title = title {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = location
            annotation.title = title
            annotation.subtitle = subtitle
            
            mapView.addAnnotation(annotation)
        }
    }
}

extension CardViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 10
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .green
            renderer.fillColor = .lightGray
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

// Extensions for distance conversion.
extension Float {
  func format(f: String) -> String {
    return NSString(format: "%\(f)f" as NSString, self) as String
  }
}

extension CLLocationDistance {
  func miles() -> String {
    let miles = Float(self)/1609.344
    return miles.format(f: ".2")
  }
}

// clean up decimals
extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
