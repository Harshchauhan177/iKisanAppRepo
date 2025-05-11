import SwiftUI
import Supabase
import MapKit
import CoreLocation

struct UpdateAddressView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @State private var showMapPicker = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629), // Default to center of India
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    // Green color used throughout the app
    private let ikisanGreen = Color(red: 76/255, green: 175/255, blue: 80/255)
    private let supabase = SupabaseManager.shared
    
    init() {
        // Load current address if available
        if let currentUser = AuthManager.shared.currentUser,
           let location = currentUser.location {
            
            // Load coordinates
            _latitude = State(initialValue: location.latitude)
            _longitude = State(initialValue: location.longitude)
            
            // Initialize map region based on user's location if available
            if location.latitude != 0 && location.longitude != 0 {
                _region = State(initialValue: MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
            
            if let address = location.address {
                let components = parseAddressComponents(from: address)
                _street = State(initialValue: components.street)
                _city = State(initialValue: components.city)
                _state = State(initialValue: components.state)
                _zipCode = State(initialValue: components.zipCode)
            }
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Location on Map")) {
                VStack {
                    MapPreview(latitude: latitude, longitude: longitude)
                        .frame(height: 150)
                        .cornerRadius(8)
                        .padding(.vertical, 4)
                    
                    Button(action: {
                        showMapPicker = true
                    }) {
                        Label("Choose Location on Map", systemImage: "map")
                            .foregroundColor(ikisanGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(ikisanGreen, lineWidth: 1)
                    )
                }
            }
            
            Section(header: Text("Address Details")) {
                TextField("Street", text: $street)
                    .textContentType(.streetAddressLine1)
                    .disableAutocorrection(true)
                
                TextField("City", text: $city)
                    .textContentType(.addressCity)
                    .disableAutocorrection(true)
                
                TextField("State", text: $state)
                    .textContentType(.addressState)
                    .disableAutocorrection(true)
                
                TextField("Zip Code", text: $zipCode)
                    .textContentType(.postalCode)
                    .keyboardType(.numberPad)
                    .disableAutocorrection(true)
            }
            
            Section(header: Text("Coordinates")) {
                HStack {
                    Text("Latitude:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.6f", latitude))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Longitude:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.6f", longitude))
                        .foregroundColor(.primary)
                }
            }
            
            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Update Address")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    updateAddress()
                }
                .disabled(isLoading || !isFormValid)
            }
        }
        .overlay(
            ZStack {
                if isLoading {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .tint(ikisanGreen)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        )
                }
            }
        )
        .alert("Address Updated", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your address has been successfully updated.")
        }
        .sheet(isPresented: $showMapPicker) {
            MapLocationPickerWithPermissions(
                region: $region,
                latitude: $latitude,
                longitude: $longitude,
                onDismiss: { showMapPicker = false },
                onSelect: { lat, long in
                    latitude = lat
                    longitude = long
                    lookupAddress(for: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    showMapPicker = false
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private var isFormValid: Bool {
        !street.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty && 
        !(latitude == 0.0 && longitude == 0.0) // Require coordinates
    }
    
    private func updateAddress() {
        guard isFormValid else {
            errorMessage = "Please fill in all address fields and select a location on the map"
            return
        }
        
        guard let userId = AuthManager.shared.currentUser?.id.uuidString else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Format address string
        let formattedAddress = "\(street), \(city), \(state) \(zipCode)"
        
        Task {
            do {
                // Serialize with JSONEncoder if needed
                let locationUpdate = LocationUpdate(
                    address: formattedAddress,
                    latitude: latitude,
                    longitude: longitude
                )
                
                // Update address and coordinates in Supabase
                _ = try await supabase.client
                    .from("users")
                    .update(locationUpdate)
                    .eq("userID", value: userId)
                    .execute()
                
                // Update user locally if needed
                if let currentUser = AuthManager.shared.currentUser {
                    let location = Location(
                        latitude: latitude,
                        longitude: longitude,
                        address: formattedAddress
                    )
                    
                    // This would need a proper method in AuthManager to update the address
                    // For now, we just show success
                }
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to update address: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Helper function to parse address components from a formatted address string
    private func parseAddressComponents(from address: String) -> (street: String, city: String, state: String, zipCode: String) {
        // Default empty values
        var street = ""
        var city = ""
        var state = ""
        var zipCode = ""
        
        // Example format: "123 Main St, Anytown, CA 12345"
        let components = address.components(separatedBy: ", ")
        
        if components.count >= 1 {
            street = components[0]
        }
        
        if components.count >= 2 {
            city = components[1]
        }
        
        if components.count >= 3 {
            // The last component might contain state and zip code
            let stateZip = components[2].components(separatedBy: " ")
            if stateZip.count >= 1 {
                state = stateZip[0]
            }
            if stateZip.count >= 2 {
                zipCode = stateZip[1]
            }
        }
        
        return (street, city, state, zipCode)
    }
    
    // Perform reverse geocoding to get address from coordinates
    private func lookupAddress(for coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                return
            }
            
            // Update address fields based on the placemark
            DispatchQueue.main.async {
                street = [placemark.subThoroughfare, placemark.thoroughfare]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                city = placemark.locality ?? ""
                state = placemark.administrativeArea ?? ""
                zipCode = placemark.postalCode ?? ""
            }
        }
    }
}

// MARK: - Data Models

// Type-safe model for updating location data
struct LocationUpdate: Encodable {
    let address: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Map Preview Component
struct MapPreview: View {
    var latitude: Double
    var longitude: Double
    
    var body: some View {
        if latitude == 0 && longitude == 0 {
            // No location selected yet
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                Text("No location selected")
                    .foregroundColor(.secondary)
            }
        } else {
            // Show map with pin
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )),
                annotationItems: [MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))]
            ) { annotation in
                MapMarker(coordinate: annotation.coordinate, tint: .red)
            }
        }
    }
}

// Simple annotation model for the map
struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Location Manager
class LocationPermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var locationError: String?
    @Published var isLoadingLocation = false
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = locationManager.authorizationStatus
        
        // Check if we have permissions at initialization
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // Initial state
            authorizationStatus = .notDetermined
        case .restricted, .denied:
            // User has denied location access
            authorizationStatus = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            // User has granted location access
            authorizationStatus = locationManager.authorizationStatus
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
    
    func requestPermission() {
        // Always request when-in-use authorization first
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        // Set loading state
        isLoadingLocation = true
        
        // Make sure we have proper authorization
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            // Clear any previous errors
            locationError = nil
            
            // Request one-time location
            locationManager.startUpdatingLocation()
        } else {
            // Request permission first
            requestPermission()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            // If newly granted permission and we were trying to get location
            if (self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways) && self.isLoadingLocation {
                self.getCurrentLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if let location = locations.first {
                self.currentLocation = location
                self.isLoadingLocation = false
                // Stop getting updates after we've received a location
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            // Convert the Error to a String for Equatable conformance
            self.locationError = error.localizedDescription
            self.isLoadingLocation = false
            print("Location error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Map Location Picker with Permissions
struct MapLocationPickerWithPermissions: View {
    @Binding var region: MKCoordinateRegion
    @Binding var latitude: Double
    @Binding var longitude: Double
    var onDismiss: () -> Void
    var onSelect: (Double, Double) -> Void
    
    @StateObject private var locationManager = LocationPermissionManager()
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var isPresentingConfirmation = false
    @State private var showPermissionAlert = false
    @State private var showLocationError = false
    @State private var errorMessage = ""
    
    // Search-related states
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [MKMapItem] = []
    @State private var showSearchResults = false
    @State private var searchDebounceTask: DispatchWorkItem?
    
    // Computed property to simplify the Map view's annotation items
    private var annotationItems: [MapAnnotation] {
        if let location = selectedLocation {
            return [MapAnnotation(coordinate: location)]
        }
        return []
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map view
                Map(
                    coordinateRegion: $region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: nil,
                    annotationItems: annotationItems
                ) { annotation in
                    MapMarker(coordinate: annotation.coordinate, tint: .red)
                }
                .edgesIgnoringSafeArea(.all)
                .navigationTitle("Select Location")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            // Cancel any pending search task
                            searchDebounceTask?.cancel()
                            onDismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        confirmButton
                    }
                }
                
                // Search bar and results overlay at the top
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Search results list
                    if showSearchResults && !searchResults.isEmpty {
                        searchResultsList
                    }
                    
                    Spacer()
                }
                
                // Center indicator
                centerIndicator
                
                // Bottom buttons
                VStack {
                    Spacer()
                    buttonRow
                }
            }
            .alert(isPresented: $isPresentingConfirmation) {
                confirmationAlert
            }
            .alert("Location Access Required", isPresented: $showPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Settings") {
                    openSettings()
                }
            } message: {
                Text("Please allow location access in Settings to use your current location.")
            }
            .alert("Location Error", isPresented: $showLocationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Check permissions when view appears
                locationManager.checkLocationAuthorization()
            }
            .onChange(of: locationManager.currentLocation) { newLocation in
                handleLocationUpdate(newLocation)
            }
            .onChange(of: locationManager.locationError) { newErrorMessage in
                handleLocationError(newErrorMessage)
            }
        }
    }
    
    // MARK: - UI Components
    
    // Search bar with enhanced UI following Apple's HIG
    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 17, weight: .medium))
                    .frame(width: 24, height: 24)
                
                TextField("Search for a location", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .onChange(of: searchText) { newValue in
                        // Cancel any previous search task
                        searchDebounceTask?.cancel()
                        
                        // Create a new debounced search task
                        let task = DispatchWorkItem {
                            searchForPlaces()
                        }
                        searchDebounceTask = task
                        
                        // Execute the search after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
                    }
                    .accessibilityLabel("Search location")
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                        showSearchResults = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 17))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            if isSearching {
                Button("Cancel") {
                    searchText = ""
                    searchResults = []
                    showSearchResults = false
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                  to: nil,
                                                  from: nil,
                                                  for: nil)
                }
                .foregroundColor(.accentColor)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.2), value: isSearching)
                .accessibilityLabel("Cancel search")
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color(.systemBackground).opacity(0.95))
        .onTapGesture {
            isSearching = true
        }
    }
    
    // Search results list with enhanced UI following Apple's HIG
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
                if !searchResults.isEmpty {
                    // Display section header mimicking iOS native search UI
                    HStack {
                        Text("Locations")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color(.systemGroupedBackground).opacity(0.8))
                    
                    ForEach(searchResults, id: \.self.hashValue) { item in
                        Button(action: {
                            selectSearchResult(item)
                            hapticFeedback(.light)
                        }) {
                            HStack(spacing: 12) {
                                // Different icon for different place types to improve clarity
                                Group {
                                    if item.placemark.thoroughfare != nil && item.placemark.subThoroughfare != nil {
                                        // Address
                                        Image(systemName: "mappin.circle.fill")
                                    } else if item.pointOfInterestCategory != nil {
                                        // Point of interest
                                        Image(systemName: "building.2.fill")
                                    } else if isCurrentLocation(item) {
                                        // Current location (if applicable)
                                        Image(systemName: "location.circle.fill")
                                    } else {
                                        // Default
                                        Image(systemName: "mappin.circle.fill")
                                    }
                                }
                                .font(.system(size: 22))
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "Unnamed Location")
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    Text(formatAddress(from: item.placemark))
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color(.systemBackground))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.name ?? "Location"), \(formatAddress(from: item.placemark))")
                        .accessibilityAddTraits(.isButton)
                        
                        if item.hashValue != searchResults.last?.hashValue {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                } else if !searchText.isEmpty {
                    VStack(spacing: 8) {
                        Text("No results found")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                        Text("Try a different search term")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .frame(maxHeight: 350) // Slightly taller to show more results
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    // Confirm button
    private var confirmButton: some View {
        Button("Confirm") {
            if let location = selectedLocation {
                onSelect(location.latitude, location.longitude)
            }
        }
        .disabled(selectedLocation == nil)
    }
    
    // Center indicator view
    private var centerIndicator: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 8, height: 8)
            .background(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 24, height: 24)
            )
    }
    
    // Button row at the bottom
    private var buttonRow: some View {
        HStack(spacing: 20) {
            // Use current location button
            locationButton
            
            // Select this location button
            selectButton
        }
        .padding(.bottom, 40)
    }
    
    // Location button
    private var locationButton: some View {
        Button(action: {
            handleLocationButtonPress()
        }) {
            HStack {
                if locationManager.isLoadingLocation {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .tint(.blue)
                } else {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                }
                Text("Use Current Location")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .disabled(locationManager.isLoadingLocation)
    }
    
    // Select button
    private var selectButton: some View {
        Button("Select This Location") {
            selectedLocation = region.center
            isPresentingConfirmation = true
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
    
    // Confirmation alert
    private var confirmationAlert: Alert {
        Alert(
            title: Text("Confirm Location"),
            message: Text("Use this location as your address?"),
            primaryButton: .default(Text("Yes")) {
                if let location = selectedLocation {
                    onSelect(location.latitude, location.longitude)
                }
            },
            secondaryButton: .cancel()
        )
    }
    
    // MARK: - Helper Methods
    
    private func handleLocationUpdate(_ newLocation: CLLocation?) {
        if let location = newLocation {
            let coordinate = location.coordinate
            selectedLocation = coordinate
            
            // Update the map region to center on the user's current location
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func handleLocationError(_ newErrorMessage: String?) {
        if let errorMessage = newErrorMessage {
            self.errorMessage = "Unable to get location: \(errorMessage)"
            showLocationError = true
        }
    }
    
    private func handleLocationButtonPress() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestPermission()
        case .restricted, .denied:
            showPermissionAlert = true
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.getCurrentLocation()
        @unknown default:
            locationManager.requestPermission()
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Search Methods
    
    private func searchForPlaces() {
        // Don't search if the text is empty, or just show local suggestions for single characters
        guard !searchText.isEmpty else {
            DispatchQueue.main.async {
                self.searchResults = []
                self.showSearchResults = false
            }
            return
        }
        
        // Create a more expansive search request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        // Use a larger region for more results if search is short
        if searchText.count <= 3 {
            // Use a much larger region for short searches to get more results
            request.region = MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
            )
        } else {
            // For longer searches, we want more focused results
            request.region = region
        }
        
        // Increase result limit for more comprehensive results
        request.resultTypes = [.address, .pointOfInterest]
        
        // Perform search
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.searchResults = []
                    self.showSearchResults = false
                }
                return
            }
            
            guard let response = response else {
                DispatchQueue.main.async {
                    self.searchResults = []
                    self.showSearchResults = false
                }
                return
            }
            
            // Update search results on main thread
            DispatchQueue.main.async {
                // Filter and sort results to prioritize places that start with the search text
                let filteredItems = response.mapItems.filter { item in
                    guard let name = item.name?.lowercased() else { return false }
                    let searchLower = self.searchText.lowercased()
                    
                    // Check if place name or address components start with search text
                    if name.starts(with: searchLower) {
                        return true
                    }
                    
                    // Check street name
                    if let street = item.placemark.thoroughfare?.lowercased(), 
                       street.starts(with: searchLower) {
                        return true
                    }
                    
                    // Check city name
                    if let city = item.placemark.locality?.lowercased(),
                       city.starts(with: searchLower) {
                        return true
                    }
                    
                    // Include other results that contain the search text anywhere
                    return name.contains(searchLower)
                }
                
                // Sort places with names starting with search text first
                let sortedItems = filteredItems.sorted { item1, item2 in
                    let name1 = item1.name?.lowercased() ?? ""
                    let name2 = item2.name?.lowercased() ?? ""
                    let searchLower = self.searchText.lowercased()
                    
                    // Places that start with search text come first
                    if name1.starts(with: searchLower) && !name2.starts(with: searchLower) {
                        return true
                    }
                    if !name1.starts(with: searchLower) && name2.starts(with: searchLower) {
                        return false
                    }
                    
                    // Then sort by proximity to current map center
                    let distance1 = item1.placemark.location?.distance(from: CLLocation(latitude: self.region.center.latitude, longitude: self.region.center.longitude)) ?? Double.infinity
                    let distance2 = item2.placemark.location?.distance(from: CLLocation(latitude: self.region.center.latitude, longitude: self.region.center.longitude)) ?? Double.infinity
                    
                    return distance1 < distance2
                }
                
                // Limit to a reasonable number for UI
                self.searchResults = Array(sortedItems.prefix(15))
                self.showSearchResults = !self.searchResults.isEmpty
            }
        }
    }
    
    private func selectSearchResult(_ mapItem: MKMapItem) {
        // Get coordinates from the selected place
        let coordinate = mapItem.placemark.coordinate
        
        // Update the map region to center on the selected location with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            // Set the selected location
            selectedLocation = coordinate
        }
        
        // Hide search results and keyboard
        withAnimation(.easeOut(duration: 0.2)) {
            showSearchResults = false
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Helper function for haptic feedback
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        // Add street number if available
        if let subThoroughfare = placemark.subThoroughfare {
            if let thoroughfare = placemark.thoroughfare {
                // Complete street address
                addressComponents.append("\(subThoroughfare) \(thoroughfare)")
            } else {
                addressComponents.append(subThoroughfare)
            }
        } else if let thoroughfare = placemark.thoroughfare {
            // Just street name
            addressComponents.append(thoroughfare)
        }
        
        // Add sublocality (neighborhood/district) if available
        if let subLocality = placemark.subLocality, addressComponents.isEmpty || !subLocality.contains(placemark.thoroughfare ?? "") {
            addressComponents.append(subLocality)
        }
        
        // City
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        // State/Province
        if let administrativeArea = placemark.administrativeArea {
            // Use abbreviation if available
            addressComponents.append(administrativeArea)
        }
        
        // Format according to iOS standard
        return addressComponents.joined(separator: ", ")
    }
    
    // Helper function to determine if a place is a current location marker
    private func isCurrentLocation(_ mapItem: MKMapItem) -> Bool {
        return mapItem.name == "Current Location"
    }
}

#Preview {
    NavigationView {
        UpdateAddressView()
    }
} 