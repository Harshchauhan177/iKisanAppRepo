//
//  HomeViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UpcomingBookingsCollectionViewCellDelegate, ExploreMoreCollectionViewCellDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, CLLocationManagerDelegate {
   
    
//    var dataController: DataController = IKisanDataController()
    var dataController: DataController!
    private var allEquipment: [Equipment] = []
    private var discountedEquipment: [Equipment] = [] // Equipment with 20% discount
    private var suggestions: [Equipment] = []
    private var reviews: [ReviewData] = []
    var upcomingBookings: [Booking] = []
    var selectedSuggestion: String?
    
    // New properties for tracking user history
    private var recentSearches: [String] = []
    private var recentlyBookedEquipmentIds: [UUID] = []
    private var exploreEquipment: [Equipment] = [] // Equipment to show in Explore More section
    
    // Keys for UserDefaults
    private let recentSearchesKey = "userRecentSearches"
    private let recentBookingsKey = "userRecentBookings"
    private let maxRecentItems = 10
    
    // Location Manager
    private var locationManager: CLLocationManager?
    private let locationPermissionKey = "didRequestLocationPermission"
    
    var searchBar: UISearchBar!
    var tableView: UITableView!

    let requestManager = RequestManager.shared
    var dataList: [String] = []
    var filteredData: [String] = []
    
    var hasUpcomingBookings: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedIndexPath: IndexPath?
    
    // Add a computed property to track number of sections
    private var numberOfSections: Int {
        // Force the upcoming bookings section to be present when hasUpcomingBookings is true
        return hasUpcomingBookings ? 4 : 3 // Return 4 sections if there are bookings, 3 if not
    }
    
    // Add a function to map visual section to data section
    private func getDataSection(for visualSection: Int) -> Int {
        if hasUpcomingBookings {
            // If we have upcoming bookings, return the section as-is
            return visualSection
        } else {
            // If no upcoming bookings, skip section 1 (which would be the bookings section)
            return visualSection >= 1 ? visualSection + 1 : visualSection
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First check if dataController is initialized
        guard let dataController = dataController else {
            print("Error: DataController not initialized")
            // Show error alert to user
            let alert = UIAlertController(
                title: "Error",
                message: "Unable to initialize app data. Please try again later.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Load user history
        loadUserHistory()
        
        // Debug: Log user's selected crops
        debugLogUserSelectedCrops()
        
        collectionView.isHidden = false
        setupSearchController()
        setupTableView()

        // Add profile button to navigation bar
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        navigationItem.rightBarButtonItem = profileButton
        
        // Set the collection view reference in the data controller if it's the right type
        if let ikisanDataController = dataController as? IKisanDataController {
            ikisanDataController.collectionView = self.collectionView
        }
        
        // Load data asynchronously
        loadData()
        
        // Register for booking added notifications
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(handleBookingAdded(_:)),
            name: .bookingAdded,
            object: nil
        )
        
        // Registering Nibs for cells
        let discountsNib = UINib(nibName: "DiscountsCell", bundle: nil)
        let upcomingBookingsNib = UINib(nibName: "UpcomingBookingsCollectionViewCell", bundle: nil)
        collectionView.register(upcomingBookingsNib, forCellWithReuseIdentifier: "UpcomingBookingsCollectionViewCell")
        let suggestionNib = UINib(nibName: "SuggestionCell", bundle: nil)
        let exploreMoreNib = UINib(nibName: "ExploreMoreCell", bundle: nil)
        
        collectionView.register(discountsNib, forCellWithReuseIdentifier: "DiscountsCell")
        collectionView.register(suggestionNib, forCellWithReuseIdentifier: "SuggestionCell")
        collectionView.register(exploreMoreNib, forCellWithReuseIdentifier: "ExploreMoreCell")
        
        // Registering Header View
        collectionView.register(
            SectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )

        // Setting collectionView layout
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)

        // Set data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Check for location permissions
        checkLocationPermissionStatus()
        
        // Perform a second data load after a short delay to catch any bookings that might not be loaded initially
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Task {
                await self.loadDataFromBackend(forceRefresh: true)
                
                // Force section refresh if we have bookings, but DO NOT auto-scroll
                if !self.upcomingBookings.isEmpty {
                    self.hasUpcomingBookings = true
                    self.collectionView.reloadData()
                    
                    // Update layout without scrolling to upcoming bookings section
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if self.collectionView.numberOfSections > 1 {
                            // Force layout update but don't scroll - auto-scrolling removed intentionally
                            self.collectionView.collectionViewLayout.invalidateLayout()
                            self.collectionView.layoutIfNeeded()
                            print("Initial setup - upcoming bookings section refreshed (no auto-scroll)")
                        }
                    }
                }
            }
        }
        
        // Additional debug logging
        print("===== HomeViewController viewDidLoad completed =====")
        print("recentSearches: \(recentSearches)")
        print("recentlyBookedEquipmentIds: \(recentlyBookedEquipmentIds)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request location permission if we haven't already and user is logged in
        if !UserDefaults.standard.bool(forKey: locationPermissionKey) && AuthManager.shared.isLoggedIn {
            showLocationPermissionAlert()
        }
    }
    
    // MARK: - Location Permission Handling
    
    private func checkLocationPermissionStatus() {
        // Initialize location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Improve Your Experience",
            message: "iKisan works best with your location to find nearby equipment and provide personalized recommendations. Would you like to share your location?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel) { _ in
            // Mark that we've asked so we don't keep asking
            UserDefaults.standard.set(true, forKey: self.locationPermissionKey)
        })
        
        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in
            // Mark that we've asked
            UserDefaults.standard.set(true, forKey: self.locationPermissionKey)
            
            // Request permission
            self.locationManager?.requestWhenInUseAuthorization()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, request location
            locationManager?.startUpdatingLocation()
            
        case .denied, .restricted:
            // User denied permission, respect their choice
            print("Location permission denied")
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Got location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // Update user's location in Supabase
            updateUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            // Stop updating location after getting it once
            locationManager?.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    // Structure for updating location
    private struct LocationUpdate: Encodable {
        let address: String
        let latitude: Double
        let longitude: Double
    }
    
    private func updateUserLocation(latitude: Double, longitude: Double) {
        guard AuthManager.shared.isLoggedIn,
              let userId = AuthManager.shared.currentUser?.id.uuidString else {
            print("Cannot update location: User not logged in")
            return
        }
        
        // Perform reverse geocoding to get the actual address
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                // Use placeholder if geocoding fails
                self?.updateLocationInSupabase(userId: userId, latitude: latitude, longitude: longitude, address: "Location set automatically")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                // Use placeholder if no placemarks
                self?.updateLocationInSupabase(userId: userId, latitude: latitude, longitude: longitude, address: "Location set automatically")
                return
            }
            
            // Format the address from placemark
            let street = [placemark.subThoroughfare, placemark.thoroughfare]
                .compactMap { $0 }
                .joined(separator: " ")
            
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let zipCode = placemark.postalCode ?? ""
            
            // Create formatted address
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
            
            let formattedAddress = addressComponents.isEmpty ? 
                "Location set automatically" : addressComponents.joined(separator: ", ")
            
            // Update in Supabase
            self?.updateLocationInSupabase(userId: userId, latitude: latitude, longitude: longitude, address: formattedAddress)
        }
    }
    
    private func updateLocationInSupabase(userId: String, latitude: Double, longitude: Double, address: String) {
        // Update location in Supabase
        Task {
            do {
                let locationUpdate = LocationUpdate(
                    address: address,
                    latitude: latitude,
                    longitude: longitude
                )
                
                _ = try await SupabaseManager.shared.client
                    .from("users")
                    .update(locationUpdate)
                    .eq("userID", value: userId)
                    .execute()
                
                print("Successfully updated user location in Supabase: \(latitude), \(longitude), Address: \(address)")
            } catch {
                print("Failed to update location: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadDataFromBackend(forceRefresh: Bool = false) async {
        // Fetch equipment data from backend
        allEquipment = await requestManager.fetchEquipments()
        
        // Initialize exploreEquipment here (in case generateExploreEquipment isn't called yet)
        if exploreEquipment.isEmpty {
            exploreEquipment = allEquipment
        }
        
        // Find Rice Harvester specifically (forcing it to be in discounted equipment)
        var riceHarvesterFound = false
        for equipment in allEquipment where equipment.name.lowercased().contains("rice") && 
                                           equipment.name.lowercased().contains("harvest") {
            print("Found Rice Harvester: \(equipment.name), realPrice=\(equipment.realPricePerHour), price=\(equipment.pricePerHour)")
            
            // Calculate its discount
            let discount = equipment.realPricePerHour > 0 ?
                ((equipment.realPricePerHour - equipment.pricePerHour) / equipment.realPricePerHour) * 100 : 0
            print("Rice Harvester discount: \(discount)%")
            
            riceHarvesterFound = true
        }
        
        // Print raw equipment data for debugging
        print("=== All Equipment Raw Data ===")
        for (index, equip) in allEquipment.enumerated() {
            print("[\(index)] \(equip.name): hourPrice=\(equip.pricePerHour), realHour=\(equip.realPricePerHour), acrePrice=\(equip.pricePerAcre), realAcre=\(equip.realPricePerAcre)")
        }
        
        // Filter equipment with discount of at least 20%
        discountedEquipment = allEquipment.filter { equipment in
            // Special case for Rice Harvester - always include it
            if equipment.name.lowercased().contains("rice") && 
               equipment.name.lowercased().contains("harvest") {
                return true
            }
            
            // Skip equipment with invalid pricing data
            guard equipment.realPricePerHour > 0 || equipment.realPricePerAcre > 0 else {
                print("Skipping \(equipment.name) - No valid real prices")
                return false
            }
            
            var hourDiscountPercent: Double = 0
            var acreDiscountPercent: Double = 0
            
            // Calculate hour-based discount if available
            if equipment.realPricePerHour > 0 {
                hourDiscountPercent = ((equipment.realPricePerHour - equipment.pricePerHour) / equipment.realPricePerHour) * 100
            }
            
            // Calculate acre-based discount if available
            if equipment.realPricePerAcre > 0 {
                acreDiscountPercent = ((equipment.realPricePerAcre - equipment.pricePerAcre) / equipment.realPricePerAcre) * 100
            }
            
            // General 20% discount check
            let hasDiscount = hourDiscountPercent >= 20.0 || acreDiscountPercent >= 20.0
            
            print("\(equipment.name): hourDiscount=\(hourDiscountPercent)%, acreDiscount=\(acreDiscountPercent)%, selected=\(hasDiscount)")
            
            return hasDiscount
        }
        
        // If no equipment with discount, use all equipment as fallback
        if discountedEquipment.isEmpty {
            print("No equipment with 20% discount found. Using all equipment as fallback.")
            discountedEquipment = allEquipment
        }
        
        // Print summary
        print("Filtered discounted equipment: \(discountedEquipment.count) out of \(allEquipment.count) total")
        for equip in discountedEquipment {
            print("Discount section will show: \(equip.name)")
        }
        
        // Generate the search suggestions list
        dataList = Array(Set(allEquipment.map { $0.name }))
        
        // Filter equipment for suggestions based on user's selected crops
        suggestions = filterEquipmentForUserCrops(from: allEquipment)
        print("Suggestions based on user's crops: \(suggestions.count) items")
        for suggestion in suggestions {
            print("  - \(suggestion.name) (type: \(suggestion.type))")
        }
        
        // Get reviews
        reviews = await requestManager.fetchReviews()
        
        // Get upcoming bookings - with force refresh
        print("Explicitly fetching bookings with forceRefresh=\(forceRefresh)")
        let allBookings = await requestManager.fetchBookings()
        
        // Debug: Print all bookings with their dates to see what's actually coming from backend
        print("All Bookings from backend:")
        for (index, booking) in allBookings.enumerated() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let dateString = formatter.string(from: booking.bookingDate)
            print("Booking \(index + 1): ID=\(booking.bookingID), Date=\(dateString), Equipment=\(booking.equipmentID.uuidString)")
            
            // Add booked equipment to recent bookings
            saveBookedEquipment(id: booking.equipmentID)
        }
        
        // IMPORTANT: Force all bookings to be shown in upcoming section
        // For now, let's show all bookings regardless of date
        upcomingBookings = allBookings
        
        // Generate explore section equipment based on user history
        generateExploreEquipment()
        
        // Debug information
        print("Loaded \(upcomingBookings.count) upcoming bookings")
        if !upcomingBookings.isEmpty {
            for (index, booking) in upcomingBookings.enumerated() {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                let dateString = formatter.string(from: booking.bookingDate)
                print("Upcoming Booking \(index + 1): Date=\(dateString), Equipment=\(booking.equipmentID.uuidString)")
            }
        }
        
        // Explicitly set hasUpcomingBookings based on booking count
        hasUpcomingBookings = !upcomingBookings.isEmpty
        print("Setting hasUpcomingBookings to \(hasUpcomingBookings)")
        
        // Print debug info
        print("Loaded equipment count: \(allEquipment.count)")
        print("Loaded suggestions count: \(suggestions.count)")
        print("Loaded reviews count: \(reviews.count)")
        print("Loaded upcoming bookings count: \(upcomingBookings.count)")
        print("Loaded explore equipment count: \(exploreEquipment.count)")
        
        // Update UI on the main thread
        await MainActor.run {
            // Force a layout update
            self.collectionView.reloadData()
            
            // Force section visibility but don't scroll
            if hasUpcomingBookings {
                // Force section visibility
                let sections = numberOfSections
                print("Number of sections: \(sections)")
                
                // No scrolling to avoid disrupting user's view
            }
            
            // Print section counts for debugging
            print("SECTION COUNTS:")
            print("- Discounts: \(discountedEquipment.count)")
            print("- Upcoming Bookings: \(upcomingBookings.count)")
            print("- Suggestions: \(suggestions.count)")
            print("- Explore: \(exploreEquipment.count)")
        }
    }
    
    func loadData() {
        Task {
            await loadDataFromBackend(forceRefresh: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data when view appears
        loadData()
    }
    
    //MARK: Search Bar Implementation
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Equipments"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupTableView() {
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.backgroundColor = .init(red: 0.9216, green: 0.9216, blue: 0.9216, alpha: 1.0)/*.init(red: 0.6667, green: 0.6667, blue: 0.5882, alpha: 1.0)*/
        
            view.addSubview(tableView)
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredData[indexPath.row]
        cell.backgroundColor = .init(red: 0.9216, green: 0.9216, blue: 0.9216, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    navigationItem.searchController?.searchBar.text = filteredData[indexPath.row]
//    tableView.isHidden = true
//    navigationItem.searchController?.searchBar.resignFirstResponder()

        selectedSuggestion = filteredData[indexPath.row]
        
        // Save the search term
        saveSearchTerm(selectedSuggestion!)
        
        if let navController = self.navigationController {
            // Check if CreateRequestViewController already exists in the navigation stack
            if let existingVC = navController.viewControllers.first(where: { $0 is CreateRequestViewController }) as? CreateRequestViewController {
                existingVC.selectedSuggestion = selectedSuggestion
                existingVC.dataController = self.dataController
                existingVC.isFromHomeViewController = true
                existingVC.applySearchFilter()
                navController.popToViewController(existingVC, animated: true)
                return
            }
            
            // If CreateRequestViewController is not in the stack, create a new one
            let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
            if let createRequestVC = storyboard.instantiateViewController(withIdentifier: "CreateRequestViewController") as? CreateRequestViewController {
                createRequestVC.dataController = self.dataController
                createRequestVC.selectedSuggestion = self.selectedSuggestion
                createRequestVC.isFromHomeViewController = true
                navigationController?.pushViewController(createRequestVC, animated: true)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
   
    
    //Search Bar Functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            filteredData = dataList.filter { $0.lowercased().contains(searchText.lowercased()) }
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        // Save search term if it's not empty
        if let searchText = searchBar.text, !searchText.isEmpty {
            saveSearchTerm(searchText)
            
            // Reload explore section with new search history
            generateExploreEquipment()
            
            // Reload the collection view section
            let exploreSection = getDataSection(for: 3)
            collectionView.reloadSections(IndexSet(integer: exploreSection))
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
                    tableView.isHidden = true
                    return
                }
                
                tableView.isHidden = false
                filteredData = dataList.filter { $0.lowercased().contains(searchText.lowercased()) }
                tableView.reloadData()
                
                // If we have valid search results and the search was substantial (>= 3 characters)
                if !filteredData.isEmpty && searchText.count >= 3 {
                    // Save search term if user has typed a substantial query
                    saveSearchTerm(searchText)
                    
                    // Debug log
                    print("Saved search term: \(searchText) (from search bar)")
                }
            }
    
    //MARK: Collection View Implementation
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataSection = getDataSection(for: section)
        switch dataSection {
        case 0:
            return discountedEquipment.count
        case 1:
            return min(upcomingBookings.count, 3) // Limit to 3 bookings in the list
        case 2:
            return suggestions.count
        case 3:
            return exploreEquipment.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSection = getDataSection(for: indexPath.section)
        switch dataSection {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscountsCell", for: indexPath) as! DiscountsCollectionViewCell
            cell.layer.cornerRadius = 10
            //applyShadowStyling(to: cell)
            let equipment = discountedEquipment[indexPath.row]
            cell.updateDiscountsData(with: equipment, reviews: reviews)
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingBookingsCollectionViewCell", for: indexPath) as! UpcomingBookingsCollectionViewCell
            cell.layer.cornerRadius = 13
            cell.delegate = self
            
            let booking = upcomingBookings[indexPath.row]
            print("Setting up cell for booking: \(booking.bookingID) on date: \(booking.bookingDate)")
            
            // First try exact ID match
            if let equipment = allEquipment.first(where: { equip in 
                equip.equipmentID.uuidString.lowercased() == booking.equipmentID.uuidString.lowercased() 
            }) {
                print("Found matching equipment: \(equipment.name)")
                cell.updateUpcomingBookingsData(with: booking, equipment: equipment)
            } 
            // If exact match fails, try to get equipment by ID from dataController
            else if let matchingEquipment = dataController.getEquipment(byId: booking.equipmentID) {
                print("Found equipment using dataController: \(matchingEquipment.name)")
                cell.updateUpcomingBookingsData(with: booking, equipment: matchingEquipment)
            }
            // Last resort, use first equipment as fallback - ensures something displays
            else if !allEquipment.isEmpty {
                let fallbackEquipment = allEquipment[0]
                print("WARNING: Using fallback equipment: \(fallbackEquipment.name)")
                cell.updateUpcomingBookingsData(with: booking, equipment: fallbackEquipment)
            }
            else {
                print("ERROR: Cannot find any equipment for booking: \(booking.bookingID)")
            }
            return cell
           
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCollectionViewCell
            cell.layer.cornerRadius = 13
            //applyShadowStyling(to: cell)
            let suggestion = suggestions[indexPath.row]
            cell.updateSuggestionData(with: suggestion)
            return cell
           
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreMoreCell", for: indexPath) as! ExploreMoreCollectionViewCell
            cell.layer.cornerRadius = 13
            //applyShadowStyling(to: cell)
            let equipment = exploreEquipment[indexPath.row]
            // Set the delegate to self so button taps are received
            cell.delegate = self
            cell.updateExploreMoreData(with: equipment)
            return cell

        default:
            return UICollectionViewCell()
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let dataSection = self.getDataSection(for: sectionIndex)
            let section: NSCollectionLayoutSection
            
            switch dataSection {
            case 0:
                section = self.generateDiscountSection()
            case 1:
                section = self.generateUpcomingBookingsSection()
            case 2:
                section = self.generateSuggestionSection()
            case 3:
                section = self.generateExploreMoreSection()
            default:
                section = self.generateDiscountSection()
            }
            
            // Consistent header size across all sections
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            // Set consistent insets for all headers
            header.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
            
            section.boundarySupplementaryItems = [header]
            
            // Add consistent top and bottom section spacing
            section.contentInsets.top = 8
            section.contentInsets.bottom = 16
            
            return section
        }
        return layout
    }


    
    func generateDiscountSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(130), heightDimension: .absolute(116))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Add 8-point spacing between items
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        // Use continuousGroupLeadingBoundary for smoother scrolling
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        return section
    }
    
    func generateUpcomingBookingsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(115))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    

    func generateSuggestionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    
    func generateExploreMoreSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
       
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16 // Spacing between groups
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        return section
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderCollectionReusableView
            
            let dataSection = getDataSection(for: indexPath.section)
            
            print("Setting up header for section \(indexPath.section), dataSection: \(dataSection)")
            
            // Common font configuration for consistent appearance
            let headerFont = UIFont.systemFont(ofSize: 20, weight: .bold)
            
            switch dataSection {
            case 0:
                header.headerLabel.text = "Discounts"
                header.headerLabel.font = headerFont
                header.button.isHidden = true
            case 1:
                header.headerLabel.text = "Upcoming Bookings"
                header.headerLabel.font = headerFont
                header.button.setTitle("View All", for: .normal)
                header.button.isHidden = false
                header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
                
                // Debug - print the current upcoming bookings count
                print("Upcoming Bookings section header shown. Current bookings count: \(upcomingBookings.count)")
            case 2:
                header.headerLabel.text = "Suggestions"
                header.headerLabel.font = headerFont
                header.button.isHidden = true
            case 3:
                // Change header text based on content source
                if !recentSearches.isEmpty || !recentlyBookedEquipmentIds.isEmpty {
                    header.headerLabel.text = "Recent & Recommended"
                } else {
                    header.headerLabel.text = "Explore More"
                }
                header.headerLabel.font = headerFont
                header.button.isHidden = true
            default:
                header.headerLabel.text = ""
                header.button.isHidden = true
            }
            
            return header
        }
        return UICollectionReusableView()
    }
    
   // MARK: Extension data
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let dataSection = getDataSection(for: indexPath.section)
        var selectedEquipment: Equipment
        
        switch dataSection {
        case 0:
            // Discounts section
            if indexPath.row < discountedEquipment.count {
                selectedEquipment = discountedEquipment[indexPath.row]
            } else {
                print("Error: Index out of range in Discounts section")
                return
            }
        case 2:
            // Suggestions section
            if indexPath.row < suggestions.count {
                selectedEquipment = suggestions[indexPath.row]
            } else {
                print("Error: Index out of range in Suggestions section")
                return
            }
        case 3:
            // Explore More section
            if indexPath.row < exploreEquipment.count {
                selectedEquipment = exploreEquipment[indexPath.row]
            } else {
                print("Error: Index out of range in Explore More section")
                return
            }
        default:
            print("Selected item in section that doesn't navigate to details")
            return
        }
        
        print("HomeViewController - Selected equipment: \(selectedEquipment.name)")
        print("HomeViewController - Selected equipment ID: \(selectedEquipment.equipmentID.uuidString.lowercased())")
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            controller.equipment = selectedEquipment
            controller.bookingSource = .home
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    func userDidMakeBooking() {
        hasUpcomingBookings = true
        collectionView.reloadData()
    }
    
    @objc func sectionButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "UpcomingBookingsListViewController") as? UpcomingBookingsListViewController {
            // Pass the data controller and data
            viewController.dataController = self.dataController
            
            // Instead of passing local copies, let the ViewController fetch fresh data
            // Print debug info
            print("HomeViewController - Passing dataController to UpcomingBookingsListViewController")
            print("HomeViewController - Current upcomingBookings count: \(upcomingBookings.count)")
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
    func didTapViewButton(on cell: UpcomingBookingsCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let booking = upcomingBookings[indexPath.row]
            
            // More robust equipment finding logic
            var equipmentToUse: Equipment?
            
            // First try exact ID match (case-insensitive)
            if let equipment = allEquipment.first(where: { equip in 
                equip.equipmentID.uuidString.lowercased() == booking.equipmentID.uuidString.lowercased() 
            }) {
                print("Found matching equipment: \(equipment.name)")
                equipmentToUse = equipment
            } 
            // If exact match fails, try to get equipment by ID from dataController
            else if let matchingEquipment = dataController.getEquipment(byId: booking.equipmentID) {
                print("Found equipment using dataController: \(matchingEquipment.name)")
                equipmentToUse = matchingEquipment
            }
            // Last resort, use first equipment as fallback if needed
            else if !allEquipment.isEmpty {
                let fallbackEquipment = allEquipment[0]
                print("WARNING: Using fallback equipment in didTapViewButton")
                equipmentToUse = fallbackEquipment
            }
            
            guard let equipment = equipmentToUse else {
                print("ERROR: Cannot find any equipment for booking: \(booking.bookingID)")
                return
            }
            
            // Create BookingDetailsViewController programmatically instead of from storyboard
            let viewController = BookingDetailsViewController(equipment: equipment, booking: booking)
            viewController.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    func didTapViewButton(on cell: ExploreMoreCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            print("Error: Could not find indexPath for ExploreMoreCollectionViewCell")
            return
        }
        
        // Get the equipment data for the tapped cell
        let dataSection = getDataSection(for: indexPath.section)
        guard dataSection == 3, indexPath.row < exploreEquipment.count else {
            print("Error: Invalid section or index in didTapViewButton for ExploreMoreCollectionViewCell")
            return
        }
        
        let equipment = exploreEquipment[indexPath.row]
        
        // Navigate to Review Booking View
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewBookingTableViewController") as? ReviewBookingTableViewController {
            // Pass the equipment data to the ReviewBookingTableViewController
            viewController.equipment = equipment
            
            // Set the booking source to .home so it redirects back to Home tab after booking
            viewController.bookingSource = .home
            
            viewController.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(viewController, animated: true)
            
            print("Navigating to ReviewBookingTableViewController with source=home")
        }
    }
    
//    private func applyShadowStyling(to cell: UICollectionViewCell) {
//        // Create a shadow layer
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOpacity = 0.2
//        cell.layer.shadowRadius = 5
//        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
////        cell.layer.shadowColor = UIColor.black.cgColor
////        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
////        cell.layer.shadowRadius = 4
////        cell.layer.shadowOpacity = 1
//        cell.layer.masksToBounds = false
//        
//        // Make sure the content view keeps the corner radius
//        cell.contentView.layer.cornerRadius = cell.layer.cornerRadius
//        cell.contentView.layer.masksToBounds = true
//        
//        // Make sure the background is not transparent
//        cell.backgroundColor = .clear
//        cell.contentView.backgroundColor = .white
//        
//        // Improve shadow performance by setting its path
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
//    }

    @objc private func handleBookingAdded(_ notification: Notification) {
        print("HomeViewController - Received bookingAdded notification")
        
        // Force reload all data from backend to ensure we get fresh data
        Task {
            // Small delay to ensure database updates have been completed
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
            
            // Get fresh data with force refresh
            await loadDataFromBackend(forceRefresh: true)
            
            // Update UI on main thread
            await MainActor.run {
                print("After refresh - Upcoming bookings count: \(self.upcomingBookings.count)")
                
                // Force the upcoming bookings section to be visible
                self.hasUpcomingBookings = !self.upcomingBookings.isEmpty
                if !self.upcomingBookings.isEmpty {
                    print("Force showing upcoming bookings section")
                }
                
                // Completely recreate the layout
                self.collectionView.setCollectionViewLayout(self.generateLayout(), animated: false)
                
                // Reload data and force a layout pass
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                
                // Force a layout refresh after a delay, but don't scroll
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Force the layout to update again
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.layoutIfNeeded()
                    
                    print("Layout refreshed with \(self.collectionView.numberOfSections) sections visible")
                }
            }
        }
    }

    @objc private func profileButtonTapped() {
        // Use the SwiftUI ProfileView wrapped in a UIHostingController
        let profileVC = ProfileHostingController()
        navigationController?.pushViewController(profileVC, animated: true)
    }

    deinit {
        // Remove notification observer when this view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Make sure our collection view layout matches our data state
        if collectionView.numberOfSections != numberOfSections {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }
//
//    // Test method to verify discount calculation
//    private func testRiceHarvesterDiscount() {
//        // Mock Rice Harvester data
//        let realPrice: Double = 15000
//        let discountedPrice: Double = 1100
//        
//        // Calculate discount
//        let discountPercent = ((realPrice - discountedPrice) / realPrice) * 100
//        
//        print("===== TEST DISCOUNT CALCULATION =====")
//        print("Rice Harvester Test: realPrice=\(realPrice), price=\(discountedPrice)")
//        print("Calculated discount: \(discountPercent)%")
//        print("Should show in Discounts section: \(discountPercent >= 20.0 ? "YES" : "NO")")
//        print("=====================================")
//    }

    // Filter equipment based on user's selected crops
    private func filterEquipmentForUserCrops(from allEquipment: [Equipment]) -> [Equipment] {
        // Get current user
        guard let currentUser = AuthManager.shared.currentUser,
              let selectedCropIds = currentUser.selectedCrops, !selectedCropIds.isEmpty else {
            print("No user or no selected crops found - returning all recommended equipment")
            return allEquipment.filter { $0.isRecommended }
        }
        
        print("User has \(selectedCropIds.count) selected crops")
        
        // First try to get specifically recommended equipment via the dataController
        var filteredEquipment: [Equipment] = []
        var matchedIds: Set<UUID> = []
        
        // For each selected crop, get equipment categories and try to match equipment
        for cropId in selectedCropIds {
            // Try to get equipment categories for this crop
            let equipmentCategories = dataController.getEquipmentCategories(forCrop: cropId)
            
            if !equipmentCategories.isEmpty {
                print("Found \(equipmentCategories.count) equipment categories for crop \(cropId.uuidString)")
                
                // For each category, gather equipment IDs
                for category in equipmentCategories {
                    // Add the equipment list IDs to our matched IDs
                    for equipment in category.equipmentList {
                        matchedIds.insert(equipment.id)
                    }
                }
            } else {
                print("No equipment categories found for crop \(cropId.uuidString)")
            }
        }
        
        // If we found specific matches, filter equipment by ID
        if !matchedIds.isEmpty {
            print("Found \(matchedIds.count) specific equipment matches from crop categories")
            
            // Match the equipment IDs with our allEquipment list
            filteredEquipment = allEquipment.filter { matchedIds.contains($0.equipmentID) }
            
            // If we found matches by ID, return them
            if !filteredEquipment.isEmpty {
                print("Matched \(filteredEquipment.count) equipment items by ID")
                return filteredEquipment
            }
        }
        
        // Fallback: Try matching by type
        print("No specific equipment matches found, trying type matching")
        
        // Get crop types from selected crop IDs
        var cropTypes: [String] = []
        for cropId in selectedCropIds {
            if let cropCategory = dataController.getCropCategory(forCrop: cropId) {
                print("Found crop category: \(cropCategory.cropName)")
                cropTypes.append(cropCategory.cropName.lowercased())
            }
        }
        
        print("Crop types from user selection: \(cropTypes)")
        
        // If we couldn't find any crop types, return all recommended equipment
        if cropTypes.isEmpty {
            print("No crop types found from selected crops - returning all recommended equipment")
            return allEquipment.filter { $0.isRecommended }
        }
        
        // Filter equipment to include only those with types matching user's crops
        filteredEquipment = allEquipment.filter { equipment in
            let equipType = equipment.type.lowercased()
            
            // Check if equipment type matches any of the user's crop types
            for cropType in cropTypes {
                // Check different variations of the name
                if equipType.contains(cropType) || cropType.contains(equipType) {
                    print("Equipment \(equipment.name) matches crop type \(cropType)")
                    return true
                }
                
                // Additional checks for common variations
                // Rice
                if (cropType.contains("rice") && (equipType.contains("paddy") || equipType.contains("harvest"))) || 
                   (equipType.contains("rice") && (cropType.contains("paddy") || cropType.contains("harvest"))) {
                    print("Equipment \(equipment.name) matches rice category")
                    return true
                }
                
                // Wheat
                if (cropType.contains("wheat") && equipType.contains("grain")) ||
                   (equipType.contains("wheat") && cropType.contains("grain")) {
                    print("Equipment \(equipment.name) matches wheat/grain category")
                    return true
                }
            }
            
            // Match general farming equipment to all crops
            if equipType.contains("tractor") || equipType.contains("plough") || 
               equipType.contains("plow") || equipType.contains("harrow") {
                print("Equipment \(equipment.name) is general farming equipment")
                return true
            }
            
            return false
        }
        
        print("Filtered \(filteredEquipment.count) equipment items matching user's crops")
        
        // If no matching equipment found, return the top rated or recommended equipment as fallback
        if filteredEquipment.isEmpty {
            print("No matching equipment found - using fallback")
            
            // First try to get recommended equipment
            let recommendedEquipment = allEquipment.filter { $0.isRecommended }
            if !recommendedEquipment.isEmpty {
                print("Using \(recommendedEquipment.count) recommended equipment items as fallback")
                return recommendedEquipment
            }
            
            // If no recommended equipment, sort by rating and get top rated
            let sortedByRating = allEquipment.sorted { $0.rating > $1.rating }
            let topRated = Array(sortedByRating.prefix(min(5, sortedByRating.count)))
            if !topRated.isEmpty {
                print("Using \(topRated.count) top-rated equipment items as fallback")
                return topRated
            }
            
            // Last resort: return a subset of all equipment
            print("Using first few equipment items as last resort fallback")
            return Array(allEquipment.prefix(min(5, allEquipment.count)))
        }
        
        return filteredEquipment
    }

    // Debug helper to log user's selected crops
    private func debugLogUserSelectedCrops() {
        guard let currentUser = AuthManager.shared.currentUser,
              let selectedCropIds = currentUser.selectedCrops else {
            print("DEBUG: No user or no selected crops found")
            return
        }
        
        print("DEBUG: User has \(selectedCropIds.count) selected crops")
        
        for (index, cropId) in selectedCropIds.enumerated() {
            print("DEBUG: Crop \(index + 1) ID: \(cropId.uuidString)")
            if let cropCategory = dataController.getCropCategory(forCrop: cropId) {
                print("DEBUG:   - Crop name: \(cropCategory.cropName)")
                print("DEBUG:   - Equipment categories: \(cropCategory.equipments.count)")
                
                for (eqIndex, eqCategory) in cropCategory.equipments.enumerated() {
                    print("DEBUG:     - Equipment category \(eqIndex + 1): \(eqCategory.title)")
                    print("DEBUG:       - Equipment items: \(eqCategory.equipmentList.count)")
                }
            } else {
                print("DEBUG:   - No crop category found for this ID")
            }
        }
        
        // Additionally verify equipment types
        let allEquipTypes = Set(dataController.getAllEquipment().map { $0.type.lowercased() })
        print("DEBUG: All equipment types in system: \(allEquipTypes)")
    }

    // MARK: - User History Management
    
    // Load user history from UserDefaults
    private func loadUserHistory() {
        // Load recent searches
        if let searches = UserDefaults.standard.array(forKey: recentSearchesKey) as? [String] {
            recentSearches = searches
            print("Loaded \(recentSearches.count) recent searches")
        }
        
        // Load recent bookings
        if let bookingIds = UserDefaults.standard.array(forKey: recentBookingsKey) as? [String] {
            recentlyBookedEquipmentIds = bookingIds.compactMap { UUID(uuidString: $0) }
            print("Loaded \(recentlyBookedEquipmentIds.count) recently booked equipment IDs")
        }
        
        // If we don't have any history yet, add some test data to demonstrate the feature
        if recentSearches.isEmpty && recentlyBookedEquipmentIds.isEmpty {
            print("No user history found - adding test data for demonstration purposes")
            addDemoUserHistory()
        }
    }
    
    // Add demo history data to show the feature working
    private func addDemoUserHistory() {
        // Add some test search terms
        let testSearchTerms = ["tractor", "rice", "harvester", "plow"]
        for term in testSearchTerms {
            saveSearchTerm(term)
        }
        
        // We'll add recently booked equipment after loading equipment data
        Task {
            // Wait a short while for equipment data to be loaded
            try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
            
            // Get some equipment IDs to use as "recently booked"
            let firstFewEquipment = Array(allEquipment.prefix(3))
            
            // Save as "recent bookings"
            for equipment in firstFewEquipment {
                saveBookedEquipment(id: equipment.equipmentID)
            }
            
            // Generate explore equipment with the new data
            generateExploreEquipment()
            
            // Reload the collection view section
            await MainActor.run {
                if hasUpcomingBookings {
                    collectionView.reloadSections(IndexSet(integer: 3))
                } else {
                    collectionView.reloadSections(IndexSet(integer: 2))
                }
            }
        }
    }
    
    // Save a search term to recent searches
    func saveSearchTerm(_ term: String) {
        // Remove if it already exists (to move it to the front)
        recentSearches.removeAll { $0.lowercased() == term.lowercased() }
        
        // Add to the beginning
        recentSearches.insert(term, at: 0)
        
        // Limit to max items
        if recentSearches.count > maxRecentItems {
            recentSearches = Array(recentSearches.prefix(maxRecentItems))
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
        print("Saved search term: \(term)")
    }
    
    // Save a booked equipment ID
    func saveBookedEquipment(id: UUID) {
        // Remove if it already exists (to move it to the front)
        recentlyBookedEquipmentIds.removeAll { $0 == id }
        
        // Add to the beginning
        recentlyBookedEquipmentIds.insert(id, at: 0)
        
        // Limit to max items
        if recentlyBookedEquipmentIds.count > maxRecentItems {
            recentlyBookedEquipmentIds = Array(recentlyBookedEquipmentIds.prefix(maxRecentItems))
        }
        
        // Save to UserDefaults
        let uuidStrings = recentlyBookedEquipmentIds.map { $0.uuidString }
        UserDefaults.standard.set(uuidStrings, forKey: recentBookingsKey)
        print("Saved booked equipment ID: \(id)")
    }
    
    // Generate explore section equipment based on user history
    private func generateExploreEquipment() {
        print("==== GENERATING EXPLORE EQUIPMENT ====")
        print("Recent searches: \(recentSearches.count) items")
        print("Recently booked equipment: \(recentlyBookedEquipmentIds.count) IDs")
        
        // Start with an empty array
        var equipmentToShow: [Equipment] = []
        
        // Keep track of equipment types we've seen to avoid duplicates
        var seenTypes = Set<String>()
        var seenEquipmentIds = Set<UUID>()
        
        // First add equipment with the same TYPE as recently booked equipment
        if !recentlyBookedEquipmentIds.isEmpty {
            print("Adding equipment with types matching previously booked equipment:")
            
            // Collect equipment types from recently booked equipment
            var bookedEquipmentTypes = Set<String>()
            
            // First, get types of all booked equipment
            for bookingId in recentlyBookedEquipmentIds {
                if let bookedEquipment = allEquipment.first(where: { $0.equipmentID == bookingId }) {
                    let equipType = bookedEquipment.type.lowercased()
                    bookedEquipmentTypes.insert(equipType)
                    print(" - Found booked equipment type: \(equipType)")
                }
            }
            
            // Then, find all equipment with matching types
            for equipType in bookedEquipmentTypes {
                print(" - Finding equipment with type: \(equipType)")
                
                let matchingTypeEquipment = allEquipment.filter {
                    let currentType = $0.type.lowercased()
                    return currentType == equipType || 
                           currentType.contains(equipType) || 
                           equipType.contains(currentType)
                }
                
                print(" - Found \(matchingTypeEquipment.count) items with type \(equipType)")
                
                // Add up to 3 equipment per type to avoid overwhelming with one type
                var addedForThisType = 0
                for equipment in matchingTypeEquipment {
                    if !seenEquipmentIds.contains(equipment.equipmentID) && addedForThisType < 3 {
                        equipmentToShow.append(equipment)
                        seenEquipmentIds.insert(equipment.equipmentID)
                        seenTypes.insert(equipment.type.lowercased())
                        addedForThisType += 1
                        print("   * Added (type match): \(equipment.name) (type: \(equipment.type))")
                    }
                }
            }
        } else {
            print("No recently booked equipment types to match")
        }
        
        // Then add equipment matching recent searches
        if !recentSearches.isEmpty {
            print("Adding equipment from recent searches:")
            for searchTerm in recentSearches {
                print(" - Processing search term: '\(searchTerm)'")
                let matchingEquipment = allEquipment.filter { 
                    $0.name.lowercased().contains(searchTerm.lowercased()) || 
                    $0.type.lowercased().contains(searchTerm.lowercased())
                }
                
                print(" - Found \(matchingEquipment.count) matches for '\(searchTerm)'")
                
                // Add up to 3 equipment per search term
                var addedForThisSearch = 0
                for equipment in matchingEquipment {
                    // Avoid duplicates
                    if !seenEquipmentIds.contains(equipment.equipmentID) && addedForThisSearch < 3 {
                        equipmentToShow.append(equipment)
                        seenEquipmentIds.insert(equipment.equipmentID)
                        seenTypes.insert(equipment.type.lowercased())
                        addedForThisSearch += 1
                        print("   * Added from search: \(equipment.name)")
                    }
                }
            }
        } else {
            print("No recent searches")
        }
        
        print("Currently have \(equipmentToShow.count) items for explore section")
        
        // If we still don't have enough, add equipment with highest ratings
        if equipmentToShow.count < 5 {
            print("Adding high-rated equipment to reach minimum count:")
            let highRatedEquipment = allEquipment
                .sorted(by: { $0.rating > $1.rating })
                .filter { equipment in
                    !seenEquipmentIds.contains(equipment.equipmentID)
                }
            
            let additionalCount = min(10 - equipmentToShow.count, highRatedEquipment.count)
            if additionalCount > 0 {
                let additionalEquipment = highRatedEquipment.prefix(additionalCount)
                for equipment in additionalEquipment {
                    equipmentToShow.append(equipment)
                    print(" - Added high-rated: \(equipment.name) (rating: \(equipment.rating))")
                }
            }
        }
        
        // If we still have nothing (unlikely but possible), use all equipment
        if equipmentToShow.isEmpty {
            print("WARNING: No equipment found for explore section - using all equipment as fallback")
            equipmentToShow = allEquipment
        }
        
        // Update the explore section equipment
        exploreEquipment = equipmentToShow
        print("Final explore equipment count: \(exploreEquipment.count) items")
        print("=====================================")
    }
}
