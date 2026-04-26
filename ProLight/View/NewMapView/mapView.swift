//
//  mapView.swift
//  ProLight
//
//  Created by Paul  on 4/2/26.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

// MARK: - Workout Manager

class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: Location
    private let locationManager = CLLocationManager()
    
    // MARK: Workout State
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    // MARK: Stats
    @Published var elapsedSeconds: Int = 0
    @Published var distanceMiles: Double = 0
    @Published var caloriesBurned: Double = 0
    @Published var steps: Int = 0
    @Published var pace: Double = 0   // min/mile
    
    private var timer: Timer?
    private var lastLocation: CLLocation?
    private let metValue: Double = 9.8
    private let weightKg: Double = 70.0
    
    // MARK: Formatted Helpers
    var formattedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return h > 0
        ? String(format: "%d:%02d:%02d", h, m, s)
        : String(format: "%02d:%02d", m, s)
    }
    
    var formattedPace: String {
        guard pace > 0 && pace < 99 else { return "--'--\"" }
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\"", mins, secs)
    }
    
    var formattedDistance: String { String(format: "%.2f mi", distanceMiles) }
    var formattedCalories: String {
        caloriesBurned < 1000
        ? String(format: "%.0f", caloriesBurned)
        : String(format: "%.1fk", caloriesBurned / 1000)
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: Controls
    
    func start() {
        reset()
        isActive = true
        isPaused = false
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    func pause() {
        isPaused = true
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func resume() {
        isPaused = false
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    func stop() {
        isActive = false
        isPaused = false
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    private func reset() {
        routeCoordinates.removeAll()
        lastLocation = nil
        elapsedSeconds = 0
        distanceMiles = 0
        caloriesBurned = 0
        steps = 0
        pace = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 1
            let hours = Double(self.elapsedSeconds) / 3600
            self.caloriesBurned = self.metValue * self.weightKg * hours
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isActive, !isPaused, let loc = locations.last else { return }
        routeCoordinates.append(loc.coordinate)
        if let last = lastLocation {
            let deltaMiles = loc.distance(from: last) / 1609.34
            distanceMiles += deltaMiles
            steps = Int(distanceMiles * 2112)
            if distanceMiles > 0 {
                pace = (Double(elapsedSeconds) / 60.0) / distanceMiles
            }
        }
        lastLocation = loc
    }
}

// MARK: - Stat Pill

private struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    var accent: Color = .green
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(accent)
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .kerning(0.8)
            }
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(accent.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - Workout Stats Panel

private struct WorkoutStatsPanel: View {
    @ObservedObject var workout: WorkoutManager
    
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.mint)
                Text(workout.formattedTime)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule().stroke(Color.mint.opacity(0.3), lineWidth: 1))
            )
            
            LazyVGrid(columns: columns, spacing: 8) {
                StatPill(icon: "figure.run",     label: "Pace",     value: workout.formattedPace,               accent: .mint)
                StatPill(icon: "map",             label: "Distance", value: workout.formattedDistance,           accent: .cyan)
                StatPill(icon: "flame.fill",      label: "Calories", value: workout.formattedCalories + " kcal", accent: .orange)
                StatPill(icon: "shoeprints.fill", label: "Steps",    value: "\(workout.steps)",                  accent: .yellow)
            }
        }
        .padding(11)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Workout Summary Sheet

struct WorkoutSummarySheet: View {
    let workout: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var isSaved: Bool = false
    @State private var saveError: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.mint)
                    .symbolRenderingMode(.hierarchical)
                Text("Workout Complete")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(workout.formattedTime)
                    .font(.system(size: 38, weight: .black, design: .monospaced))
                    .foregroundColor(.mint)
            }
            .padding(.top, 28)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                SummaryTile(icon: "map",             label: "Distance", value: workout.formattedDistance,           color: .cyan)
                SummaryTile(icon: "flame.fill",      label: "Calories", value: workout.formattedCalories + " kcal", color: .orange)
                SummaryTile(icon: "figure.run",      label: "Avg Pace", value: workout.formattedPace + "/mi",       color: .mint)
                SummaryTile(icon: "shoeprints.fill", label: "Steps",    value: "\(workout.steps)",                  color: .yellow)
            }
            .padding(.horizontal, 20)
            
            if saveError {
                Label("Could not save workout.", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
            
            Button { saveWorkout() } label: {
                HStack(spacing: 8) {
                    if isSaved {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(isSaved ? "Saved!" : "Done")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(isSaved ? Color.green : Color.mint)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .animation(.spring(response: 0.3), value: isSaved)
            }
            .disabled(isSaved)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func saveWorkout() {
        let entry = Workout(
            date: .now,
            duration: TimeInterval(workout.elapsedSeconds),
            movingTime: TimeInterval(workout.elapsedSeconds),
            distance: workout.distanceMiles * 1609.34,
            route: workout.routeCoordinates,
            notes: "",
            pace: workout.pace,
            caloriesBurned: workout.caloriesBurned,
            steps: workout.steps
        )
        context.insert(entry)
        do {
            try context.save()
            isSaved = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { dismiss() }
        } catch {
            print("SwiftData save error: \(error)")
            saveError = true
        }
    }
}

private struct SummaryTile: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .symbolRenderingMode(.hierarchical)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .kerning(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Main Map View

struct mapView: View {
    // MARK: Map Properties
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic) // ← FIXED
    @State private var mapSelection: MKMapItem?
    @Namespace private var locationSpace
    @State private var viewingRegion: MKCoordinateRegion?
    // MARK: Search Bar
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    // MARK: Map Selection Detail Properties
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    // MARK: Route Properties
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
            .onMapCameraChange({ ctx in
                viewingRegion = ctx.region
            })
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 10) {
                    MapCompass(scope: locationSpace)
                }
                .buttonBorderShape(.circle)
                .padding()
            }
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
                                Circle()
                                    .fill(Color.red.opacity(0.12))
                                    .frame(width: 46, height: 46)
                                Circle()
                                    .strokeBorder(Color.red.opacity(0.35), lineWidth: 1.2)
                                    .frame(width: 46, height: 46)
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
                            if !workout.isActive {
                                workout.start()
                            } else if workout.isPaused {
                                workout.resume()
                            } else {
                                workout.pause()
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(trackButtonColor.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Circle()
                                .strokeBorder(trackButtonColor.opacity(0.35), lineWidth: 1.5)
                                .frame(width: 56, height: 56)
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
            .searchable(text: $searchText, isPresented: $showSearch)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
            .safeAreaPadding(.bottom, tabBarHeight)
            .sheet(isPresented: $showDetails, onDismiss: {
                withAnimation(.snappy) {
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
            .sheet(isPresented: $showWorkoutSummary) {
                WorkoutSummarySheet(workout: workout)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(28)
            }
            .safeAreaInset(edge: .bottom) {
                if routeDisplaying {
                    Button("End Route") {
                        withAnimation(.snappy) {
                            routeDisplaying = false
                            showDetails = true
                            mapSelection = routeDestination
                            routeDestination = nil
                            route = nil
                            cameraPosition = .userLocation(fallback: .automatic) // ← FIXED
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
                searchResults.removeAll(keepingCapacity: false)
                showDetails = false
                withAnimation(.snappy) {
                    cameraPosition = .userLocation(fallback: .automatic) // ← FIXED
                }
            }
        }
        .onChange(of: mapSelection) { _, newValue in
            showDetails = newValue != nil
            fetchLookAroundPreview()
        }
    }
    
    // MARK: Track button helpers
    private var trackButtonIcon: String {
        if !workout.isActive { return "figure.run.circle.fill" }
        return workout.isPaused ? "play.circle.fill" : "pause.circle.fill"
    }
    
    private var trackButtonColor: Color {
        if !workout.isActive { return .mint }
        return workout.isPaused ? .cyan : .orange
    }
    
    // MARK: Map Details
    @ViewBuilder
    func MapDetails() -> some View {
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
                    withAnimation(.snappy) { mapSelection = nil }
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.black)
                        .background(.white, in: .circle)
                })
                .padding(10)
            }
            
            Button("Get Directions", action: fetchRoute)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(.blue.gradient, in: .rect(cornerRadius: 15))
        }
        .padding(15)
    }
    
    // MARK: Search Places
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = viewingRegion ?? MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )
        let results = try? await MKLocalSearch(request: request).start()
        searchResults = results?.mapItems ?? []
    }
    
    // MARK: Look Around Preview
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
    
    // MARK: Fetch Navigation Route
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem.forCurrentLocation() // ← FIXED: real device location
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
}

#Preview {
    mapView()
}
