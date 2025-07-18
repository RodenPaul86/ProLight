//
//  WalkingMapView.swift
//  ProLight
//
//  Created by Paul  on 7/17/25.
//

import SwiftUI
import MapKit

struct WalkingMapView: View {
    var tabBarHeight: CGFloat
    
    // Map Properties
    @State private var cameraPosition: MapCameraPosition = .region(.myRegion)
    @State private var mapSelection: MKMapItem?
    @Namespace private var locationSpace
    @State private var viewingRegion: MKCoordinateRegion?
    
    // Search Properties
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    
    // Map Selection Detail Properties
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    
    // Route Properties
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace) {
                // Map Annotations
                /*
                Marker("Apple Park", systemImage: "applelogo", coordinate: .myLocation)
                    .tint(.black)
                */
                
                Marker("Apple Park", coordinate: .myLocation)
                
                // Simply Display Annotations as Marker
                ForEach(searchResults, id: \.self) { mapItem in
                    // Hiding All Other Markers, Expect Destionation one
                    if routeDisplaying {
                        if mapItem == routeDestination {
                            let placemark = mapItem.placemark
                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                                .tint(.blue)
                        }
                    } else {
                        let placemark = mapItem.placemark
                        Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                            .tint(.blue)
                    }
                }
                
                // Displaying Route using Polylines
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 7)
                }
                
                // To Show User Current Location
                UserAnnotation()
            }
            .onMapCameraChange({ ctx in
                viewingRegion = ctx.region
            })
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
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, isPresented: $showSearch) /// <-- Search Bar
            .toolbarBackground(.visible, for: .navigationBar) /// <-- Showing Trasnlucent Toolbar
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar) /// <-- Hidding top and bottom bar
            .sheet(isPresented: $showDetails, onDismiss: {
                withAnimation(.snappy) {
                    // Zooming Route
                    if let boundingRect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(boundingRect)
                    }
                }
            }, content: {
                MapDetails()
                    .presentationDetents([.height(300)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled(true)
            })
            .safeAreaInset(edge: .bottom) {
                if routeDisplaying {
                    Button("End Route") {
                        withAnimation(.snappy) {
                            routeDisplaying = false
                            showDetails = true
                            mapSelection = routeDestination
                            routeDestination = nil
                            route = nil
                            cameraPosition = .region(.myRegion) /// <-- Replace this with MapSelection Coordinates for more natural feel
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
        }
        .onSubmit(of: .search) {
            Task {
                guard !searchText.isEmpty else { return }
                await searchPlaces()
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                // Clearing Search Results
                searchResults.removeAll(keepingCapacity: false)
                showDetails = false
                // Zooming out to User Region when Sreach Cancelled
                withAnimation(.snappy) {
                    cameraPosition = .region(.myRegion)
                }
            }
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            // Displaying Details about the Selected Places
            showDetails = newValue != nil
            
            // Fetching Look Around Preview
            fetchLookAroundPreview()
        }
    }
    
    // Map Details View
    @ViewBuilder
    func MapDetails() -> some View {
        VStack(spacing: 15) {
            ZStack {
                // Look Around API
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
            
            Button("Get Directions") {
                fetchRoute()
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.blue.gradient, in: .rect(cornerRadius: 15))
        }
        .padding(15)
    }
    
    // Search Places
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = viewingRegion ?? .myRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        searchResults = results?.mapItems ?? []
    }
    
    // Fetching Loctaion Preview
    func fetchLookAroundPreview() {
        if let mapSelection {
            // Clearing onle one
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = .init(placemark: .init(coordinate: .myLocation)) /// <-- replace with user's current location
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                // Saving Route Destination
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    
                }
            }
        }
    }
    
}

#Preview {
    WalkingMapView(tabBarHeight: 0)
}

extension CLLocationCoordinate2D {
    static var myLocation: CLLocationCoordinate2D {
        return .init(latitude: 37.3346, longitude: -122.0090)
    }
}

extension MKCoordinateRegion {
    static var myRegion: MKCoordinateRegion {
        return .init(center: .myLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}
