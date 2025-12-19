//
//  HomeViewModel.swift
//  iKisanApp
//
//  SwiftUI ViewModel for Home Screen
//

import Foundation
import Combine
import CoreLocation

@MainActor
class HomeViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var allEquipment: [Equipment] = []
    @Published var discountedEquipment: [Equipment] = []
    @Published var suggestions: [Equipment] = []
    @Published var exploreEquipment: [Equipment] = []
    @Published var upcomingBookings: [Booking] = []
    @Published var reviews: [ReviewData] = []
    @Published var userLocation: String?
    
    @Published var searchText: String = ""
    @Published var filteredSearchResults: [String] = []
    @Published var isSearching: Bool = false
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    
    // MARK: - Navigation Coordinator (Bridge to UIKit)
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    // MARK: - Data Controller
    var dataController: DataController?
    
    // MARK: - Private Properties
    private let requestManager = RequestManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // User history
    private var recentSearches: [String] = []
    private var recentlyBookedEquipmentIds: [UUID] = []
    private let recentSearchesKey = "userRecentSearches"
    private let recentBookingsKey = "userRecentBookings"
    private let maxRecentItems = 10
    
    // Location
    private var locationManager: CLLocationManager?
    private let locationPermissionKey = "didRequestLocationPermission"
    
    // Data list for search
    private var dataList: [String] = []
    
    // MARK: - Computed Properties
    var hasUpcomingBookings: Bool {
        !upcomingBookings.isEmpty
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupSearchSubscriber()
        loadUserHistory()
        setupLocationManager()
    }
    
    // MARK: - Setup Methods
    private func setupSearchSubscriber() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(query: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Data Loading
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch all data concurrently
            async let equipmentFetch = requestManager.fetchEquipments()
            async let reviewsFetch = requestManager.fetchReviews()
            async let bookingsFetch = requestManager.fetchBookings()
            
            allEquipment = await equipmentFetch
            reviews = await reviewsFetch
            let allBookings = await bookingsFetch
            
            // Process data
            processEquipmentData()
            processBookingsData(allBookings)
            generateExploreEquipment()
            
            // Generate search data list
            dataList = Array(Set(allEquipment.map { $0.name }))
            
            print("✅ HomeViewModel loaded: \(allEquipment.count) equipment, \(upcomingBookings.count) bookings")
        } catch {
            print("❌ Error loading data: \(error)")
        }
    }
    
    func refreshData() async {
        isRefreshing = true
        await loadData()
        isRefreshing = false
    }
    
    // MARK: - Data Processing
    private func processEquipmentData() {
        // Filter discounted equipment (20%+ discount)
        discountedEquipment = allEquipment.filter { equipment in
            // Special case for Rice Harvester
            if equipment.name.lowercased().contains("rice") &&
               equipment.name.lowercased().contains("harvest") {
                return true
            }
            
            guard equipment.realPricePerHour > 0 || equipment.realPricePerAcre > 0 else {
                return false
            }
            
            var hourDiscountPercent: Double = 0
            var acreDiscountPercent: Double = 0
            
            if equipment.realPricePerHour > 0 {
                hourDiscountPercent = ((equipment.realPricePerHour - equipment.pricePerHour) / equipment.realPricePerHour) * 100
            }
            
            if equipment.realPricePerAcre > 0 {
                acreDiscountPercent = ((equipment.realPricePerAcre - equipment.pricePerAcre) / equipment.realPricePerAcre) * 100
            }
            
            return hourDiscountPercent >= 20.0 || acreDiscountPercent >= 20.0
        }
        
        // Fallback to all equipment if no discounts
        if discountedEquipment.isEmpty {
            discountedEquipment = allEquipment
        }
        
        // Filter suggestions based on user's crops
        suggestions = filterEquipmentForUserCrops(from: allEquipment)
    }
    
    private func processBookingsData(_ allBookings: [Booking]) {
        // Sort by date, most recent first, and take top 3
        let sortedBookings = allBookings.sorted { $0.bookingDate > $1.bookingDate }
        upcomingBookings = Array(sortedBookings.prefix(3))
        
        // Save booked equipment IDs
        for booking in allBookings {
            saveBookedEquipment(id: booking.equipmentID)
        }
    }
    
    private func filterEquipmentForUserCrops(from equipment: [Equipment]) -> [Equipment] {
        // Get user's selected crops
        guard let userId = AuthManager.shared.currentUser?.id else {
            return Array(equipment.prefix(5))
        }
        
        // For now, return top rated equipment
        // TODO: Implement crop-based filtering when crop data is available
        return Array(equipment.sorted { $0.rating > $1.rating }.prefix(5))
    }
    
    // MARK: - Explore Equipment Generation
    private func generateExploreEquipment() {
        var exploreSet: [Equipment] = []
        
        // 1. Add recently booked equipment
        for equipmentId in recentlyBookedEquipmentIds {
            if let equipment = allEquipment.first(where: { $0.equipmentID == equipmentId }) {
                exploreSet.append(equipment)
            }
        }
        
        // 2. Add equipment based on recent searches
        for searchTerm in recentSearches {
            let matchingEquipment = allEquipment.filter {
                $0.name.lowercased().contains(searchTerm.lowercased()) ||
                $0.type.lowercased().contains(searchTerm.lowercased())
            }
            exploreSet.append(contentsOf: matchingEquipment)
        }
        
        // 3. Remove duplicates
        var seen = Set<UUID>()
        exploreSet = exploreSet.filter { equipment in
            guard !seen.contains(equipment.equipmentID) else { return false }
            seen.insert(equipment.equipmentID)
            return true
        }
        
        // 4. If still not enough, add top-rated equipment
        if exploreSet.count < 6 {
            let topRated = allEquipment
                .filter { !seen.contains($0.equipmentID) }
                .sorted { $0.rating > $1.rating }
            exploreSet.append(contentsOf: topRated)
        }
        
        // 5. Limit to reasonable number
        exploreEquipment = Array(exploreSet.prefix(20))
    }
    
    // MARK: - Search
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            filteredSearchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        filteredSearchResults = dataList.filter {
            $0.lowercased().contains(query.lowercased())
        }
        
        // Save search term if substantial
        if query.count >= 3 {
            saveSearchTerm(query)
        }
    }
    
    func selectSearchResult(_ result: String) {
        searchText = result
        saveSearchTerm(result)
        isSearching = false
        
        // Regenerate explore equipment with new search
        generateExploreEquipment()
    }
    
    // MARK: - User History Management
    private func loadUserHistory() {
        if let savedSearches = UserDefaults.standard.array(forKey: recentSearchesKey) as? [String] {
            recentSearches = savedSearches
        }
        
        if let savedBookingIds = UserDefaults.standard.array(forKey: recentBookingsKey) as? [String] {
            recentlyBookedEquipmentIds = savedBookingIds.compactMap { UUID(uuidString: $0) }
        }
    }
    
    private func saveSearchTerm(_ term: String) {
        guard !term.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0.lowercased() == term.lowercased() }
        
        // Add to front
        recentSearches.insert(term, at: 0)
        
        // Keep only recent items
        if recentSearches.count > maxRecentItems {
            recentSearches = Array(recentSearches.prefix(maxRecentItems))
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    private func saveBookedEquipment(id: UUID) {
        // Remove if already exists
        recentlyBookedEquipmentIds.removeAll { $0 == id }
        
        // Add to front
        recentlyBookedEquipmentIds.insert(id, at: 0)
        
        // Keep only recent items
        if recentlyBookedEquipmentIds.count > maxRecentItems {
            recentlyBookedEquipmentIds = Array(recentlyBookedEquipmentIds.prefix(maxRecentItems))
        }
        
        // Save to UserDefaults
        let idStrings = recentlyBookedEquipmentIds.map { $0.uuidString }
        UserDefaults.standard.set(idStrings, forKey: recentBookingsKey)
    }
    
    // MARK: - Location Methods
    func requestLocationPermission() {
        guard !UserDefaults.standard.bool(forKey: locationPermissionKey) else { return }
        locationManager?.requestWhenInUseAuthorization()
        UserDefaults.standard.set(true, forKey: locationPermissionKey)
    }
    
    private func updateUserLocation(latitude: Double, longitude: Double) {
        guard AuthManager.shared.isLoggedIn,
              let userId = AuthManager.shared.currentUser?.id.uuidString else {
            return
        }
        
        Task {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                let address = formatAddress(from: placemarks.first)
                
                // Update the UI with city name
                if let city = placemarks.first?.locality {
                    await MainActor.run {
                        self.userLocation = city
                    }
                }
                
                await updateLocationInSupabase(userId: userId, latitude: latitude, longitude: longitude, address: address)
            } catch {
                await updateLocationInSupabase(userId: userId, latitude: latitude, longitude: longitude, address: "Location set automatically")
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark?) -> String {
        guard let placemark = placemark else {
            return "Location set automatically"
        }
        
        let street = [placemark.subThoroughfare, placemark.thoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        let zipCode = placemark.postalCode ?? ""
        
        var addressComponents = [String]()
        if !street.isEmpty { addressComponents.append(street) }
        if !city.isEmpty { addressComponents.append(city) }
        if !state.isEmpty {
            if !zipCode.isEmpty {
                addressComponents.append("\(state) \(zipCode)")
            } else {
                addressComponents.append(state)
            }
        } else if !zipCode.isEmpty {
            addressComponents.append(zipCode)
        }
        
        return addressComponents.isEmpty ? "Location set automatically" : addressComponents.joined(separator: ", ")
    }
    
    private func updateLocationInSupabase(userId: String, latitude: Double, longitude: Double, address: String) async {
        do {
            struct LocationUpdate: Encodable {
                let address: String
                let latitude: Double
                let longitude: Double
            }
            
            let locationUpdate = LocationUpdate(address: address, latitude: latitude, longitude: longitude)
            
            _ = try await SupabaseManager.shared.client
                .from("users")
                .update(locationUpdate)
                .eq("userID", value: userId)
                .execute()
            
            print("✅ Updated user location: \(address)")
        } catch {
            print("❌ Failed to update location: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    func getEquipment(for booking: Booking) -> Equipment? {
        return allEquipment.first { $0.equipmentID == booking.equipmentID }
    }
    
    func getAverageRating(for equipment: Equipment) -> Double {
        let equipmentReviews = reviews.filter { review in
            if let reviewEquipmentID = review.equipmentID {
                return reviewEquipmentID.lowercased() == equipment.equipmentID.uuidString.lowercased()
            }
            return review.equipmentName?.lowercased() == equipment.name.lowercased()
        }
        
        guard !equipmentReviews.isEmpty else { return 0.0 }
        return equipmentReviews.reduce(0.0) { $0 + $1.rating } / Double(equipmentReviews.count)
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewModel: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager?.startUpdatingLocation()
            case .denied, .restricted:
                print("Location permission denied")
            default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            if let location = locations.first {
                updateUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                locationManager?.stopUpdatingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}
