//
//  WalkingMapView.swift
//  ProLight
//
//  Created by Paul  on 7/17/25.
//

import SwiftUI
import MapKit
import Contacts

struct WalkingMapView: View {
    var tabBarHeight: CGFloat
    @State private var hideTabBar: Bool = false
    @StateObject private var locationManager = LocationManager()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapSelection: MKMapItem?
    @Namespace private var locationSpace
    @State private var viewingRegion: MKCoordinateRegion?
    
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        NavigationStack {
            Group {
                if let userLocation = locationManager.currentLocation {
                    Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace) {
                        
                        // Search Markers
                        ForEach(searchResults, id: \.self) { mapItem in
                            let placemark = mapItem.placemark
                            if !routeDisplaying || mapItem == routeDestination {
                                Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                                    .tint(.blue)
                            }
                        }
                        
                        // Route Polyline
                        if let route {
                            MapPolyline(route.polyline)
                                .stroke(.blue, lineWidth: 7)
                        }
                        
                        UserAnnotation()
                    }
                    .onAppear {
                        cameraPosition = .region(
                            MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
                        )
                    }
                    .onMapCameraChange { ctx in
                        viewingRegion = ctx.region
                    }
                    .overlay(alignment: .bottomTrailing) {
                        VStack(spacing: 15) {
                            MapCompass(scope: locationSpace)
                            MapPitchToggle(scope: locationSpace)
                            MapUserLocationButton(scope: locationSpace)
                        }
                        .buttonBorderShape(.circle)
                        .padding()
                    }
                    .mapScope(locationSpace)
                } else {
                    ProgressView("Getting your location...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, isPresented: $showSearch)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
            .sheet(isPresented: $showDetails, onDismiss: {
                withAnimation(.snappy) {
                    if let boundingRect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(boundingRect)
                    }
                }
            }, content: {
                if let selectedItem = mapSelection {
                    MapDetails(for: selectedItem)
                        .presentationDetents([.height(380)])
                        .presentationCornerRadius(25)
                        .interactiveDismissDisabled(true)
                }
            })
            .safeAreaInset(edge: .bottom) {
                if routeDisplaying {
                    Button("End Route") {
                        hideTabBar = false
                        routeDisplaying = false
                        showDetails = true
                        mapSelection = routeDestination
                        routeDestination = nil
                        route = nil
                        withAnimation(.snappy) {
                            if let userLocation = locationManager.currentLocation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: userLocation,
                                    latitudinalMeters: 1000,
                                    longitudinalMeters: 1000
                                ))
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.red.gradient, in: .rect(cornerRadius: 15))
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .safeAreaPadding(.bottom, routeDisplaying ? 0 : tabBarHeight)
        }
        .onSubmit(of: .search) {
            Task {
                guard !searchText.isEmpty else { return }
                await searchPlaces()
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                searchResults.removeAll()
                showDetails = false
                
                if let userLocation = locationManager.currentLocation {
                    withAnimation(.snappy) {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: userLocation,
                            latitudinalMeters: 1000,
                            longitudinalMeters: 1000
                        ))
                    }
                }
            }
        }
        .onChange(of: mapSelection) { _, newValue in
            showDetails = newValue != nil
            fetchLookAroundPreview()
        }
        .hideFloatingTabBar(hideTabBar)
    }
    
    @ViewBuilder
    func MapDetails(for item: MKMapItem) -> some View {
        VStack(spacing: 15) {
            ZStack {
                if lookAroundScene == nil {
                    ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
                } else {
                    LookAroundPreview(scene: $lookAroundScene)
                }
            }
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    showDetails = false
                    withAnimation(.snappy) {
                        mapSelection = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.black)
                        .background(.white, in: .circle)
                }
                .padding(10)
            }
            
            VStack(alignment: .leading) {
                Text(item.name ?? "Unknown")
                    .font(.title3.bold())
                
                Text(item.placemark.formattedAddress)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                if let phone = item.phoneNumber {
                    Link(phone, destination: URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))")!)
                        .foregroundStyle(.blue)
                }
            }
            
            HStack {
                Button("Get Directions") {
                    hideTabBar = true
                    fetchRoute()
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue.gradient, in: .rect(cornerRadius: 15))
                
                Button("Open in Maps") {
                    item.openInMaps()
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.green.gradient, in: .rect(cornerRadius: 15))
            }
        }
        .padding(15)
    }
    
    func searchPlaces() async {
        guard let userLocation = locationManager.currentLocation else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: userLocation,
            latitudinalMeters: 1,
            longitudinalMeters: 1
        )
        
        let response = try? await MKLocalSearch(request: request).start()
        let results = response?.mapItems.filter {
            $0.placemark.location != nil
        } ?? []
        
        await MainActor.run {
            self.searchResults = results
            
            if !results.isEmpty {
                let coordinates = results.map { $0.placemark.coordinate }
                zoomToFit(coordinates: coordinates)
            }
        }
    }
    
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
    
    func fetchRoute() {
        if let mapSelection, let userLocation = locationManager.currentLocation {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: userLocation))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                }
            }
        }
    }
    
    func zoomToFit(coordinates: [CLLocationCoordinate2D]) {
        guard !coordinates.isEmpty else {
            // No coordinates? Zoom to user location fallback
            if let userLoc = locationManager.currentLocation {
                cameraPosition = .region(.region(around: userLoc, radiusMeters: 1000))
            }
            return
        }
        
        if coordinates.count == 1 {
            // Only one coordinate: zoom around that coordinate with fixed radius
            cameraPosition = .region(.region(around: coordinates[0], radiusMeters: 1000))
            return
        }
        
        // Multiple coordinates: fit bounding box
        var minLat = coordinates.first!.latitude
        var maxLat = coordinates.first!.latitude
        var minLon = coordinates.first!.longitude
        var maxLon = coordinates.first!.longitude
        
        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let latDelta = (maxLat - minLat) * 1.1
        let lonDelta = (maxLon - minLon) * 1.1
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        withAnimation(.snappy) {
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}

#Preview {
    WalkingMapView(tabBarHeight: 0)
}

extension MKCoordinateRegion {
    static func region(around coordinate: CLLocationCoordinate2D, radiusMeters: CLLocationDistance = 1000) -> MKCoordinateRegion {
        MKCoordinateRegion(center: coordinate, latitudinalMeters: radiusMeters, longitudinalMeters: radiusMeters)
    }
}

extension MKPlacemark {
    var formattedAddress: String {
        guard let postalAddress = self.postalAddress else { return "" }
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        return formatter.string(from: postalAddress).replacingOccurrences(of: "\n", with: ", ")
    }
}
