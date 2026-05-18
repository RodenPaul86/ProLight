//
//  ExploreMapView.swift
//  ProLight
//
//  Created by Paul  on 4/2/26.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct ExploreMapView: View {
    @Environment(\.openURL) private var openURL
    @State private var hideTabBar: Bool = false
    @State private var currentStepIndex: Int = 0
    // MARK: Map
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapSelection: MKMapItem?
    @Namespace private var locationSpace
    @State private var viewingRegion: MKCoordinateRegion?
    // MARK: Search
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    // MARK: Categories
    @State private var selectedCategory: String = ""
    // MARK: Nearby sheet
    @State private var showNearbyResults: Bool = false
    @State private var userLocation: CLLocation? = nil
    private let locationHelper = LocationHelper()
    // MARK: Place detail
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    // MARK: Navigation route
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    // MARK: Workout
    @StateObject private var workout = WorkoutManager()
    @State private var showWorkoutSummary: Bool = false
    
    var tabBarHeight: CGFloat?
    
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace) {
                ForEach(searchResults, id: \.self) { mapItem in
                    if routeDisplaying {
                        if mapItem == routeDestination {
                            let placemark = mapItem.placemark
                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                        }
                    } else {
                        let placemark = mapItem.placemark
                        Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                    }
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 7)
                }
                
                if workout.isActive && workout.routeCoordinates.count > 1 {
                    MapPolyline(MKPolyline(
                        coordinates: workout.routeCoordinates,
                        count: workout.routeCoordinates.count
                    ))
                    .stroke(.mint, lineWidth: 5)
                }
                
                UserAnnotation()
            }
            .onMapCameraChange { ctx in viewingRegion = ctx.region }
            // MARK: Category chips row
            .safeAreaInset(edge: .top) {
                if !routeDisplaying && !workout.isActive {
                    if #available(iOS 26.0, *) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(placeCategories, id: \.label) { cat in
                                    CategoryChip(
                                        category: cat,
                                        isSelected: selectedCategory == cat.label
                                    ) {
                                        selectedCategory = cat.label
                                        Task { await searchPlaces(query: cat.query) }
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(placeCategories, id: \.label) { cat in
                                    CategoryChip(
                                        category: cat,
                                        isSelected: selectedCategory == cat.label
                                    ) {
                                        selectedCategory = cat.label
                                        Task { await searchPlaces(query: cat.query) }
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        }
                        .background(.ultraThinMaterial)
                    }
                }
            }
            // MARK: Bottom-trailing buttons
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 10) {
                    MapPitchToggle(scope: locationSpace)
                    MapUserLocationButton(scope: locationSpace)
                    
                    if workout.isActive {
                        Button {
                            workout.stop()
                            showWorkoutSummary = true
                        } label: {
                            ZStack {
                                Circle().fill(Color.red.opacity(0.12)).frame(width: 46, height: 46)
                                Circle().strokeBorder(Color.red.opacity(0.35), lineWidth: 1.2).frame(width: 46, height: 46)
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(.red)
                                    .symbolRenderingMode(.hierarchical)
                            }
                        }
                        .shadow(color: .red.opacity(0.3), radius: 8, y: 3)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                            if !workout.isActive        { workout.start() }
                            else if workout.isPaused    { workout.resume() }
                            else                        { workout.pause() }
                        }
                    } label: {
                        ZStack {
                            if #available(iOS 26.0, *) {
                                Circle().fill(trackButtonColor.opacity(0.15)).frame(width: 56, height: 56)
                                    .glassEffect(.regular, in: .circle)
                            } else {
                                Circle().fill(trackButtonColor.opacity(0.15)).frame(width: 56, height: 56)
                            }
                            Circle().strokeBorder(trackButtonColor.opacity(0.35), lineWidth: 1.5).frame(width: 56, height: 56)
                            Image(systemName: trackButtonIcon)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(trackButtonColor)
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .shadow(color: trackButtonColor.opacity(0.4), radius: 12, y: 4)
                    .scaleEffect(workout.isActive && !workout.isPaused ? 1.06 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: workout.isActive)
                }
                .buttonBorderShape(.circle)
                .padding()
            }
            // MARK: Workout stats panel
            .overlay(alignment: .bottomLeading) {
                if workout.isActive {
                    WorkoutStatsPanel(workout: workout)
                        .padding(.leading, 14)
                        .padding(.trailing, 80)
                        .padding(.bottom, routeDisplaying ? 80 : 14)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: workout.isActive)
                }
            }
            .mapScope(locationSpace)
            .navigationTitle("Explore Map")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    // ── Clear button — only visible when results are showing ──
                    if !searchResults.isEmpty {
                        if #available(iOS 26.0, *) {
                            Button("Clear All", systemImage: "xmark") {
                                withAnimation(.spring(response: 0.3)) {
                                    searchResults.removeAll()
                                    selectedCategory = ""
                                    showNearbyResults = false
                                    showDetails = false
                                }
                            }
                            .tint(.red)
                        } else {
                            Button("Clear All", action: {
                                withAnimation(.spring(response: 0.3)) {
                                    searchResults.removeAll()
                                    selectedCategory = ""
                                    showNearbyResults = false
                                    showDetails = false
                                }
                            })
                            .tint(.red)
                        }
                    }
                }
            }
            .searchable(text: $searchText, isPresented: $showSearch) /// <-- Search Text
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
            .safeAreaPadding(.bottom, tabBarHeight)
            .sheet(isPresented: $showDetails, onDismiss: { /// <-- Place detail sheet
                withAnimation(.snappy) {
                    if let boundingRect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(boundingRect)
                    }
                }
            }) {
                MapDetails()
                    .presentationDetents([.fraction(0.45)]) /// <-- 45% of screen height
                    .interactiveDismissDisabled(true)
            }
            // MARK: Workout summary sheet
            .sheet(isPresented: $showWorkoutSummary) {
                WorkoutSummarySheet(workout: workout)
                    .presentationDetents([.fraction(0.62)]) /// <-- 62% of screen height
                    .interactiveDismissDisabled(true)
            }
            // MARK: Nearby results sheet
            .sheet(isPresented: $showNearbyResults) {
                NearbyResultsSheet(
                    results: searchResults,
                    userLocation: userLocation,
                    mapSelection: $mapSelection,
                    selectedCategory: selectedCategory
                )
                .presentationDetents([.medium])
                .interactiveDismissDisabled(true)
                .presentationDragIndicator(.visible)
            }
            
            // MARK: - End Route Bar + Turn-by-Turn Banner
            
            .safeAreaInset(edge: .bottom) {
                if routeDisplaying, let route {
                    VStack(spacing: 0) {
                        // Turn-by-turn step banner
                        if !route.steps.isEmpty {
                            let step = route.steps[min(currentStepIndex, route.steps.count - 1)]
                            if #available(iOS 26.0, *) {
                                HStack(spacing: 12) {
                                    Image(systemName: stepIcon(for: step))
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(width: 36)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(step.instructions.isEmpty ? "Head toward destination" : step.instructions)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .lineLimit(2)
                                        if step.distance > 0 {
                                            Text(step.distance < 1609
                                                 ? String(format: "In %.0f ft", step.distance * 3.28084)
                                                 : String(format: "In %.1f mi", step.distance / 1609.34))
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.7))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // MARK: - Previous / Next step controls
                                    HStack(spacing: 6) {
                                        Button {
                                            if currentStepIndex > 0 { currentStepIndex -= 1 }
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(currentStepIndex == 0 ? .white.opacity(0.3) : .white)
                                                .frame(width: 34, height: 34)
                                                .contentShape(Circle())
                                        }
                                        .disabled(currentStepIndex == 0)
                                        
                                        Button {
                                            if currentStepIndex < route.steps.count - 1 { currentStepIndex += 1 }
                                        } label: {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(currentStepIndex == route.steps.count - 1 ? .white.opacity(0.3) : .white)
                                                .frame(width: 34, height: 34)
                                                .contentShape(Circle())
                                        }
                                        .disabled(currentStepIndex == route.steps.count - 1)
                                    }
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 15)
                                .glassEffect(.regular, in: .capsule)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            } else {
                                HStack(spacing: 12) {
                                    Image(systemName: stepIcon(for: step))
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(width: 36)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(step.instructions.isEmpty ? "Head toward destination" : step.instructions)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .lineLimit(2)
                                        if step.distance > 0 {
                                            Text(step.distance < 1609
                                                 ? String(format: "In %.0f ft", step.distance * 3.28084)
                                                 : String(format: "In %.1f mi", step.distance / 1609.34))
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.7))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // MARK: - Previous / Next step controls
                                    HStack(spacing: 6) {
                                        Button {
                                            if currentStepIndex > 0 { currentStepIndex -= 1 }
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundStyle(currentStepIndex == 0 ? .white.opacity(0.3) : .white)
                                                .frame(width: 34, height: 34)
                                                .contentShape(Circle())
                                        }
                                        .disabled(currentStepIndex == 0)
                                        
                                        Button {
                                            if currentStepIndex < route.steps.count - 1 { currentStepIndex += 1 }
                                        } label: {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundStyle(currentStepIndex == route.steps.count - 1 ? .white.opacity(0.3) : .white)
                                                .frame(width: 34, height: 34)
                                                .contentShape(Circle())
                                        }
                                        .disabled(currentStepIndex == route.steps.count - 1)
                                    }
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 15)
                                .background(.ultraThinMaterial, in: .capsule)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                        }
                        
                        if #available(iOS 26.0, *) {
                            Button(action: { endRoute() }) {
                                Text("End Route")
                                    .font(.system(size: 17))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                            .glassEffect(.regular.tint(.red).interactive(), in: .capsule)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        } else {
                            Button(action: { endRoute() }) {
                                Text("End Route")
                                    .font(.system(size: 17))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                            .background(.red.gradient, in: .capsule)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
        }
        .onAppear {
            locationHelper.onLocationUpdate = { loc in
                userLocation = loc
            }
        }
        .onSubmit(of: .search) {
            Task {
                guard !searchText.isEmpty else { return }
                selectedCategory = ""
                await searchPlaces(query: searchText)
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                searchResults.removeAll(keepingCapacity: false)
                selectedCategory = ""
                showDetails = false
                showNearbyResults = false
                withAnimation(.snappy) {
                    cameraPosition = .userLocation(fallback: .automatic)
                }
            }
        }
        .onChange(of: mapSelection) { _, newValue in
            showDetails = newValue != nil
            fetchLookAroundPreview()
            if let item = newValue {
                moveMapToSelection(item)
            }
        }
        .onChange(of: searchResults) { _, newValue in
            withAnimation { showNearbyResults = !newValue.isEmpty }
        }
        .hideFloatingTabBar(hideTabBar)
    }
    
    // MARK: - Track button helpers
    
    private var trackButtonIcon: String {
        if !workout.isActive { return "figure.run.circle.fill" }
        return workout.isPaused ? "play.circle.fill" : "pause.circle.fill"
    }
    
    private var trackButtonColor: Color {
        if !workout.isActive { return .mint }
        return workout.isPaused ? .cyan : .orange
    }
    
    // MARK: - Map Details
    
    @ViewBuilder
    func MapDetails() -> some View {
        if #available(iOS 26.0, *) {
            NavigationStack {
                VStack(spacing: 12) {
                    Spacer()
                    LookAroundPreviewCard(lookAroundScene: $lookAroundScene)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
                        )
                        .padding(.top, 12)
                }
                .padding(.horizontal, 16)
                .navigationTitle(mapSelection?.name ?? "Loading...")
                .navigationSubtitle(mapSelection?.phoneNumber ?? "Loading...")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if let phone = mapSelection?.phoneNumber, !phone.isEmpty {
                            Button {
                                let cleaned = phone.filter(\.isNumber)
                                if let url = URL(string: "tel://\(cleaned)") {
                                    openURL(url)
                                }
                            } label: {
                                Image(systemName: "phone.fill")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel", systemImage: "xmark") {
                            showDetails = false
                            withAnimation(.snappy) { mapSelection = nil }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: 12) {
                        OpenMapsButton(mapSelection: mapSelection)
                        
                        GetDirectionsButton {
                            fetchRoute()
                            hideTabBar = true
                            showDetails = false
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                }
            }
        } else {
            NavigationStack {
                VStack(spacing: 12) {
                    Spacer()
                    LookAroundPreviewCard(lookAroundScene: $lookAroundScene)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
                        )
                        .padding(.top, 12)
                }
                .padding(.horizontal, 16)
                .navigationTitle(mapSelection?.name ?? "Loading...")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if let phone = mapSelection?.phoneNumber, !phone.isEmpty {
                            Button {
                                let cleaned = phone.filter(\.isNumber)
                                if let url = URL(string: "tel://\(cleaned)") {
                                    openURL(url)
                                }
                            } label: {
                                Image(systemName: "phone.fill")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel", systemImage: "xmark") {
                            showDetails = false
                            withAnimation(.snappy) { mapSelection = nil }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: 12) {
                        OpenMapsButton(mapSelection: mapSelection)
                        
                        GetDirectionsButton {
                            fetchRoute()
                            hideTabBar = true
                            showDetails = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Search Places (now accepts explicit query)
    
    func searchPlaces(query: String? = nil) async {
        let searchQuery = query ?? searchText
        guard !searchQuery.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = viewingRegion ?? MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )
        let results = try? await MKLocalSearch(request: request).start()
        searchResults = results?.mapItems ?? []
    }
    
    // MARK: - Look Around Preview
    
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
    
    // MARK: - Fetch Navigation Route
    
    func fetchRoute() {
        guard let mapSelection else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapSelection
        request.transportType = .walking  // change to .automobile if needed
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            guard let calculatedRoute = result?.routes.first else { return }
            route = calculatedRoute
            routeDestination = mapSelection
            
            withAnimation(.snappy) {
                routeDisplaying = true
                showDetails = false
                showNearbyResults = false
                // Fit the whole polyline in view with padding
                cameraPosition = .rect(
                    calculatedRoute.polyline.boundingMapRect.insetBy(
                        dx: -calculatedRoute.polyline.boundingMapRect.width  * 0.2,
                        dy: -calculatedRoute.polyline.boundingMapRect.height * 0.2
                    )
                )
            }
        }
    }
    
    private func moveMapToSelection(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        
        // Zoom span — tight enough to be useful, not so tight it clips context
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        // Shift the center north so the pin appears in the upper ~65 % of the screen
        // (above the 300 pt compact sheet). Adjust the multiplier if your sheet height differs.
        let sheetOffsetFraction: Double = 0.35
        let offsetLatitude = coordinate.latitude - (span.latitudeDelta * sheetOffsetFraction)
        
        let adjustedCenter = CLLocationCoordinate2D(
            latitude: offsetLatitude,
            longitude: coordinate.longitude
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(center: adjustedCenter, span: span)
            )
        }
    }
    
    // MARK: - Turn Icon Helper
    
    private func stepIcon(for step: MKRoute.Step) -> String {
        let text = step.instructions.lowercased()
        if text.contains("left")                           { return "arrow.turn.up.left" }
        if text.contains("right")                          { return "arrow.turn.up.right" }
        if text.contains("u-turn")                         { return "arrow.uturn.left" }
        if text.contains("merge") || text.contains("ramp") { return "arrow.merge" }
        if text.contains("exit")                           { return "arrow.up.right" }
        if text.contains("roundabout")                     { return "arrow.triangle.2.circlepath" }
        if text.contains("destination")                    { return "mappin.circle.fill" }
        return "arrow.up"
    }
    
    // MARK: - End Route

    private func endRoute() {
        let destination = routeDestination
        route = nil
        routeDestination = nil

        withAnimation(.snappy) {
            routeDisplaying = false
            showDetails = true
            mapSelection = destination
            currentStepIndex = 0
            cameraPosition = .userLocation(fallback: .automatic)
            hideTabBar = false
        }
    }
}

// MARK: - Location Helper (lightweight wrapper to get CLLocation for distance calc)

class LocationHelper: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        onLocationUpdate?(loc)
    }
}

#Preview {
    ExploreMapView()
}

// MARK: - Look Around Preview Card

private struct LookAroundPreviewCard: View {
    @Binding var lookAroundScene: MKLookAroundScene?

    var body: some View {
        ZStack {
            if lookAroundScene == nil {
                ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
            } else {
                LookAroundPreview(scene: $lookAroundScene)
            }
        }
        .frame(height: 200)
        .clipShape(.rect(cornerRadius: 15))
    }
}

// MARK: - Open Maps Button

private struct OpenMapsButton: View {
    let mapSelection: MKMapItem?

    var body: some View {
        Button {
            mapSelection?.openInMaps()
        } label: {
            if #available(iOS 26.0, *) {
                Text("Open Maps")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .glassEffect(.regular.interactive().tint(.green), in: .capsule)
            } else {
                Text("Open Maps")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(.green.gradient, in: .rect(cornerRadius: 15))
            }
        }
    }
}

// MARK: - Get Directions Button

private struct GetDirectionsButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if #available(iOS 26.0, *) {
                Text("Get Directions")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .glassEffect(.regular.interactive().tint(.mint), in: .capsule)
            } else {
                Text("Get Directions")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(.mint.gradient, in: .rect(cornerRadius: 15))
            }
        }
    }
}
