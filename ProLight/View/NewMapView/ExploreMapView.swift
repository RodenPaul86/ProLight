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
    @Published var pace: Double = 0 /// <-- min/mile
    
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
                if #available(iOS 26.0, *) {
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
                    .foregroundStyle(.black)
                    .glassEffect(
                        .regular.interactive()
                        .tint(isSaved ? .green : .mint),
                        in: .capsule
                    )
                    .animation(.spring(response: 0.3), value: isSaved)
                } else {
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
            }
            .disabled(isSaved)
            .padding(.horizontal, 20)
            
            //Spacer()
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

// MARK: - Place Category Model

struct PlaceCategory {
    let label: String
    let icon: String
    let query: String
}

let placeCategories: [PlaceCategory] = [
    .init(label: "Restaurants", icon: "fork.knife",              query: "restaurants"),
    .init(label: "Coffee",      icon: "cup.and.saucer.fill",     query: "coffee"),
    .init(label: "Parks",       icon: "leaf.fill",               query: "parks"),
    .init(label: "Gyms",        icon: "dumbbell.fill",           query: "gym"),
    .init(label: "Gas",         icon: "fuelpump.fill",           query: "gas station"),
    .init(label: "Pharmacy",    icon: "cross.case.fill",         query: "pharmacy"),
    .init(label: "Grocery",     icon: "cart.fill",               query: "grocery store"),
    .init(label: "Hospital",    icon: "staroflife.fill",         query: "hospital"),
    .init(label: "Hotels",      icon: "bed.double.fill",         query: "hotel"),
    .init(label: "Parking",     icon: "parkingsign.circle.fill", query: "parking"),
    .init(label: "Banks",       icon: "banknote.fill",           query: "bank"),
    .init(label: "Schools",     icon: "graduationcap.fill",      query: "school"),
    .init(label: "Shopping",    icon: "bag.fill",                query: "shopping mall"),
    .init(label: "Transit",     icon: "bus.fill",                query: "bus station"),
    .init(label: "Bars",        icon: "wineglass.fill",          query: "bar"),
]

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: PlaceCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if #available(iOS 26.0, *) {
                HStack(spacing: 5) {
                    Image(systemName: category.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(category.label)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .glassEffect(
                    isSelected ? .regular.tint(.mint).interactive() : .regular.interactive(),
                    in: .capsule
                )
                .foregroundColor(isSelected ? .black : .primary)
            } else {
                HStack(spacing: 5) {
                    Image(systemName: category.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text(category.label)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.mint : Color(.systemBackground).opacity(0.92))
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                )
                .foregroundColor(isSelected ? .black : .primary)
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Nearby Result Row

private struct NearbyResultRow: View {
    let item: MKMapItem
    let userLocation: CLLocation?
    let isSelected: Bool
    let action: () -> Void
    
    private var distance: String {
        guard let userLoc = userLocation else { return "" }
        let dest = CLLocation(
            latitude: item.placemark.coordinate.latitude,
            longitude: item.placemark.coordinate.longitude
        )
        let meters = userLoc.distance(from: dest)
        return meters < 1609
        ? String(format: "%.0f m away", meters)
        : String(format: "%.1f mi away", meters / 1609.34)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.mint.opacity(0.2) : Color(.secondarySystemBackground))
                        .frame(width: 42, height: 42)
                    Image(systemName: poiIcon(for: item))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .mint : .secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name ?? "Unknown")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if let address = item.placemark.thoroughfare {
                        Text(address)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if !distance.isEmpty {
                    Text(distance)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.mint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.mint.opacity(0.12)))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.mint.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    private func poiIcon(for item: MKMapItem) -> String {
        switch item.pointOfInterestCategory {
        case .restaurant, .cafe, .bakery, .brewery, .foodMarket: return "fork.knife"
        case .hospital:                                          return "staroflife.fill"
        case .pharmacy:                                          return "cross.case.fill"
        case .gasStation:                                        return "fuelpump.fill"
        case .hotel:                                             return "bed.double.fill"
        case .parking:                                           return "parkingsign.circle.fill"
        case .bank, .atm:                                        return "banknote.fill"
        case .school, .university:                               return "graduationcap.fill"
        case .publicTransport:                                   return "bus.fill"
        case .nightlife, .winery:                                return "wineglass.fill"
        case .fitnessCenter:                                     return "dumbbell.fill"
        case .park:                                              return "leaf.fill"
        case .store:                                             return "bag.fill"
        default:
            let name = (item.name ?? "").lowercased()
            if name.contains("coffee")  { return "cup.and.saucer.fill" }
            if name.contains("park")    { return "leaf.fill" }
            if name.contains("gym")     { return "dumbbell.fill" }
            return "mappin.circle.fill"
        }
    }
}

// MARK: - Nearby Results Sheet

struct NearbyResultsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let results: [MKMapItem]
    let userLocation: CLLocation?
    @Binding var mapSelection: MKMapItem?
    var selectedCategory: String
    
    // Sort results by distance from user
    private var sortedResults: [MKMapItem] {
        guard let userLoc = userLocation else { return results }
        return results.sorted {
            let a = CLLocation(latitude: $0.placemark.coordinate.latitude,
                               longitude: $0.placemark.coordinate.longitude)
            let b = CLLocation(latitude: $1.placemark.coordinate.latitude,
                               longitude: $1.placemark.coordinate.longitude)
            return userLoc.distance(from: a) < userLoc.distance(from: b)
        }
    }
    
    var body: some View {
        NavigationStack {
            if #available(iOS 26.0, *) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedResults, id: \.self) { item in
                            NearbyResultRow(
                                item: item,
                                userLocation: userLocation,
                                isSelected: mapSelection == item
                            ) {
                                mapSelection = item
                            }
                            if item != sortedResults.last {
                                Divider().padding(.leading, 70)
                            }
                        }
                    }
                }
                .background(.regularMaterial)
                .navigationTitle(selectedCategory.isEmpty ? "Nearby" : selectedCategory)
                .toolbarTitleDisplayMode(.inlineLarge)
                .navigationSubtitle("\(results.count) result\(results.count == 1 ? "" : "s")")
            } else {
                VStack(spacing: 0) {
                    // Drag handle + header
                    VStack(spacing: 8) {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Nearby" : selectedCategory)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Spacer()
                            Text("\(results.count) result\(results.count == 1 ? "" : "s")")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                    }
                    
                    Divider()
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sortedResults, id: \.self) { item in
                                NearbyResultRow(
                                    item: item,
                                    userLocation: userLocation,
                                    isSelected: mapSelection == item
                                ) {
                                    mapSelection = item
                                }
                                if item != sortedResults.last {
                                    Divider().padding(.leading, 70)
                                }
                            }
                        }
                    }
                }
                .background(.regularMaterial)
            }
        }
    }
}

// MARK: - Main Map View

struct mapView: View {
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
                            Circle().fill(trackButtonColor.opacity(0.15)).frame(width: 56, height: 56)
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
                        Button("Clear", systemImage: "xmark") {
                            withAnimation(.spring(response: 0.3)) {
                                searchResults.removeAll()
                                selectedCategory = ""
                                showNearbyResults = false
                                showDetails = false
                            }
                        }
                        .tint(.red)
                    }
                }
            }
            .searchable(text: $searchText, isPresented: $showSearch)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
            .safeAreaPadding(.bottom, tabBarHeight)
            // Place detail sheet
            .sheet(isPresented: $showDetails, onDismiss: {
                withAnimation(.snappy) {
                    if let boundingRect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(boundingRect)
                    }
                }
            }) {
                MapDetails()
                    .presentationDetents([.height(350)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(350)))
                    .interactiveDismissDisabled(true)
            }
            // Workout summary sheet
            .sheet(isPresented: $showWorkoutSummary) {
                WorkoutSummarySheet(workout: workout)
                    .presentationDetents([.fraction(0.62)]) /// <-- 62% of screen height
                    .interactiveDismissDisabled(true)
            }
            // Nearby results sheet
            .sheet(isPresented: $showNearbyResults) {
                NearbyResultsSheet(
                    results: searchResults,
                    userLocation: userLocation,
                    mapSelection: $mapSelection,
                    selectedCategory: selectedCategory
                )
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            }
            
            // MARK: - End Route Bar + Turn-by-Turn Banner
            
            .safeAreaInset(edge: .bottom) {
                if routeDisplaying, let route {
                    VStack(spacing: 0) {
                        
                        // Turn-by-turn step banner
                        if !route.steps.isEmpty {
                            let step = route.steps[min(currentStepIndex, route.steps.count - 1)]
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
                                
                                // Previous / Next step controls
                                HStack(spacing: 6) {
                                    Button {
                                        if currentStepIndex > 0 { currentStepIndex -= 1 }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(currentStepIndex == 0 ? .white.opacity(0.3) : .white)
                                    }
                                    .disabled(currentStepIndex == 0)
                                    
                                    Button {
                                        if currentStepIndex < route.steps.count - 1 { currentStepIndex += 1 }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(currentStepIndex == route.steps.count - 1 ? .white.opacity(0.3) : .white)
                                    }
                                    .disabled(currentStepIndex == route.steps.count - 1)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 10, style: .continuous))
                            .clipShape(.rect(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        }
                        
                        if #available(iOS 26.0, *) {
                            Button("End Route") {
                                endRoute()
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .glassEffect(.regular.tint(.red).interactive(), in: .capsule)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        } else {
                            Button("End Route") {
                                endRoute()
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.red.gradient, in: .rect(cornerRadius: 15))
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
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
        VStack(spacing: 15) {
            Spacer(minLength: 0)
            LookAroundPreviewCard(
                lookAroundScene: $lookAroundScene, mapSelection: mapSelection,
                onDismiss: {
                    showDetails = false
                    withAnimation(.snappy) { mapSelection = nil }
                }
            )
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    )
            )
            
            OpenMapsButton(mapSelection: mapSelection)
            
            GetDirectionsButton {
                fetchRoute()
                hideTabBar = true
            }
        }
        .padding([.vertical, .horizontal], 15)
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
    mapView()
}

// MARK: - Look Around Preview Card

private struct LookAroundPreviewCard: View {
    @Binding var lookAroundScene: MKLookAroundScene?
    let mapSelection: MKMapItem?
    let onDismiss: () -> Void

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
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                if #available(iOS 26.0, *) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 45, height: 45)
                        .glassEffect(.regular.interactive(), in: .circle)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.black)
                        .background(.white, in: .circle)
                }
            }
            .padding(10)
        }
        .overlay(alignment: .bottomLeading) {
            if #available(iOS 26.0, *) {
                VStack(alignment: .leading, spacing: 2) {
                    if let name = mapSelection?.name {
                        Text(name)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    if let phone = mapSelection?.phoneNumber, !phone.isEmpty {
                        if let url = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                            Link(phone, destination: url)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 10, style: .continuous))
                .glassEffect(.regular, in: .rect(cornerRadius: 10, style: .continuous))
                .padding(10)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    if let name = mapSelection?.name {
                        Text(name)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    if let phone = mapSelection?.phoneNumber, !phone.isEmpty {
                        if let url = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                            Link(phone, destination: url)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 10, style: .continuous))
                .padding(10)
            }
        }
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
