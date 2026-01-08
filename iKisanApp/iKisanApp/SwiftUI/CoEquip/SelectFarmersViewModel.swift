//
//  SelectFarmersViewModel.swift
//  iKisanApp
//
//  ViewModel for Farmer Selection Screen
//  Handles search, distance filtering, and selection logic with real CoreLocation
//

import Foundation
import SwiftUI
import Combine
import CoreLocation

@MainActor
class SelectFarmersViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var searchText: String = ""
    @Published var selectedDistanceFilter: DistanceFilter = .all
    @Published var selectedFarmerIds: Set<String> = []
    @Published var allFarmers: [Farmer] = [] // Changed to @Published for dynamic updates
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    weak var parentViewModel: CreateCoEquipGroupViewModel?
    private let dataController: DataController?
    
    // MARK: - Current User Location
    
    private var currentUserLocation: Location?
    
    // MARK: - Computed Properties
    
    /// Filtered farmers based on search text and distance filter
    var filteredFarmers: [Farmer] {
        var result = allFarmers
        
        // Apply distance filter first - using actual calculated distances
        switch selectedDistanceFilter {
        case .all:
            // Show all farmers within 50km (default max range)
            result = result.filter { $0.distance <= 50.0 }
        case .oneKm:
            result = result.filter { $0.distance <= 1.0 }
        case .twoKm:
            result = result.filter { $0.distance <= 2.0 }
        }
        
        // Apply search filter if search text is not empty
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            result = result.filter { farmer in
                // Search by name
                if farmer.name.lowercased().contains(lowercasedSearch) {
                    return true
                }
                
                // Search by phone number (remove spaces and special characters)
                if let phone = farmer.phoneNumber {
                    let cleanPhone = phone.replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: "+", with: "")
                        .replacingOccurrences(of: "-", with: "")
                    let cleanSearch = lowercasedSearch.replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: "+", with: "")
                        .replacingOccurrences(of: "-", with: "")
                    
                    if cleanPhone.contains(cleanSearch) {
                        return true
                    }
                }
                
                return false
            }
        }
        
        // Sort by distance (nearest first)
        result.sort { $0.distance < $1.distance }
        
        return result
    }
    
    // MARK: - Initialization
    
    init(parentViewModel: CreateCoEquipGroupViewModel) {
        self.parentViewModel = parentViewModel
        self.dataController = parentViewModel.dataController
        
        // Pre-select farmers that were already selected in parent
        self.selectedFarmerIds = Set(parentViewModel.selectedFarmers.map { $0.id })
        
        // Load current user location and farmers
        Task {
            await loadCurrentUserLocation()
            await loadFarmersWithDistances()
        }
    }
    
    // MARK: - Data Loading
    
    /// Load current user's location from AuthManager
    private func loadCurrentUserLocation() async {
        guard let currentUser = AuthManager.shared.currentUser else {
            print("❌ No current user found")
            await MainActor.run {
                self.errorMessage = "Please log in to continue"
            }
            return
        }
        
        // Use user's location if available
        if let userLocation = currentUser.location {
            self.currentUserLocation = userLocation
            print("✅ Current user location: \(userLocation.latitude), \(userLocation.longitude)")
            if let address = userLocation.address {
                print("   Address: \(address)")
            }
        } else if currentUser.latitude != 0.0 || currentUser.longitude != 0.0 {
            // Fallback to direct coordinates
            self.currentUserLocation = Location(
                latitude: currentUser.latitude,
                longitude: currentUser.longitude,
                address: currentUser.address
            )
            print("✅ Current user location (direct): \(currentUser.latitude), \(currentUser.longitude)")
        } else {
            print("❌ User has no location data. Please update your profile location.")
            await MainActor.run {
                self.errorMessage = "Please set your location in your profile to find nearby farmers"
            }
        }
    }
    
    /// Fetch real nearby farmers from Supabase backend
    private func loadFarmersWithDistances() async {
        // Set loading state
        await MainActor.run {
            self.isLoading = true
        }
        
        guard let userLocation = currentUserLocation else {
            print("❌ Cannot load farmers - no user location")
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Unable to get your location"
            }
            return
        }
        
        guard let currentUser = AuthManager.shared.currentUser else {
            print("❌ Cannot load farmers - no current user")
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Please log in to continue"
            }
            return
        }
        
        print("🔍 Fetching real data for user at: \(userLocation.latitude), \(userLocation.longitude)")
        
        do {
            // Fetch all users from Supabase (excluding current user)
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("userID, name, phone, latitude, longitude, address")
                .neq("userID", value: currentUser.id.uuidString)
                .execute()
            
            // Decode response
            let usersData = response.data
            let fetchedUsers = try JSONDecoder().decode([FarmerDTO].self, from: usersData)
            
            print("✅ Fetched \(fetchedUsers.count) users from database")
            
            // Convert to Farmer objects and calculate distances
            var farmers: [Farmer] = []
            
            let userCLLocation = CLLocation(
                latitude: userLocation.latitude,
                longitude: userLocation.longitude
            )
            
            for userDTO in fetchedUsers {
                // Skip users with invalid/missing location data
                guard userDTO.latitude != 0.0 || userDTO.longitude != 0.0,
                      !userDTO.latitude.isNaN,
                      !userDTO.longitude.isNaN else {
                    print("⚠️ Skipping user \(userDTO.name) - invalid location")
                    continue
                }
                
                // Calculate distance
                let farmerCLLocation = CLLocation(
                    latitude: userDTO.latitude,
                    longitude: userDTO.longitude
                )
                
                let distanceInMeters = userCLLocation.distance(from: farmerCLLocation)
                let distanceInKm = distanceInMeters / 1000.0
                
                // Only include farmers within 50km radius (to keep list manageable)
                guard distanceInKm <= 50.0 else {
                    continue
                }
                
                let farmer = Farmer(
                    id: userDTO.userID,
                    name: userDTO.name,
                    phoneNumber: userDTO.phone,
                    location: Location(
                        latitude: userDTO.latitude,
                        longitude: userDTO.longitude,
                        address: userDTO.address
                    ),
                    distance: distanceInKm
                )
                
                farmers.append(farmer)
                
                print("📍 Farmer: \(farmer.name), Distance: \(String(format: "%.2f", distanceInKm)) km")
            }
            
            // Sort by distance (nearest first)
            farmers.sort { $0.distance < $1.distance }
            
            // Update published property
            await MainActor.run {
                self.allFarmers = farmers
                self.isLoading = false
                self.errorMessage = nil
            }
            
            print("✅ Loaded \(farmers.count) farmers within 50km with calculated distances")
            
            if farmers.isEmpty {
                await MainActor.run {
                    self.errorMessage = "No farmers found within 50km of your location"
                }
            }
            
        } catch {
            print("❌ Error fetching farmers from Supabase: \(error)")
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load nearby farmers: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Selection Methods
    
    func isSelected(_ farmer: Farmer) -> Bool {
        selectedFarmerIds.contains(farmer.id)
    }
    
    func toggleSelection(for farmer: Farmer) {
        if selectedFarmerIds.contains(farmer.id) {
            selectedFarmerIds.remove(farmer.id)
        } else {
            selectedFarmerIds.insert(farmer.id)
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func confirmSelection() {
        // Get selected farmers from all farmers
        let selected = allFarmers.filter { selectedFarmerIds.contains($0.id) }
        
        // Update parent view model
        parentViewModel?.selectedFarmers = selected
        
        // Note: Invites are sent when the actual group is created in CreateCoEquipGroupViewModel
        // Not here during selection, as the group doesn't exist yet
        
        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Invite/Request Logic
    
    /// Send Co-Equip invites to selected farmers via Supabase
    /// Creates incoming requests that appear in each farmer's "Join Requests" tab
    private func sendInvites(to farmers: [Farmer]) async {
        guard let dataController = dataController,
              let currentUser = AuthManager.shared.currentUser,
              let parentVM = parentViewModel,
              let bookingLocation = parentVM.bookingLocation else {
            print("❌ Cannot send invites - missing required data")
            return
        }
        
        print("📤 Sending invites to \(farmers.count) farmers via Supabase...")
        
        // Get equipment details
        let equipment = parentVM.equipment
        
        // Convert field area to acres if needed
        guard let fieldAreaInAcres = parentVM.fieldAreaInAcres else {
            print("❌ Invalid field area")
            return
        }
        
        // Get time slot info
        guard let timeSlotInfo = parentVM.calculatedTimeSlots.first else {
            print("❌ No time slot calculated")
            return
        }
        
        // Create time slot - use enum value (morning/afternoon/evening)
        // For Co-Equip, we'll default to morning for now
        // In a full implementation, you could determine this from the start time
        let timeSlot: TimeSlot = .morning
        
        // Track successful invites
        var successCount = 0
        var failedCount = 0
        
        // For each farmer, create a Request with them as a participant
        for farmer in farmers {
            // Create unique request ID
            let requestId = UUID()
            
            // Get farmer's user ID from their farmer id (assuming farmer.id is a UUID string)
            guard let farmerUserId = UUID(uuidString: farmer.id) else {
                print("⚠️ Invalid farmer ID: \(farmer.id)")
                failedCount += 1
                continue
            }
            
            // Create participant entry for the invited farmer
            let participant = RequestParticipant(
                id: UUID(),
                requestId: requestId,
                userId: farmerUserId,
                status: .pending, // Pending invitation
                area: nil, // They will enter this when accepting
                timeSlot: nil, // They will select this when accepting
                joinedAt: Date()
            )
            
            // Create the request object
            let request = Request(
                id: requestId,
                userId: currentUser.id, // Creator of the request
                equipmentId: equipment.equipmentID,
                requestedDate: parentVM.selectedDate,
                status: .pending,
                type: .coEquip, // Co-Equip booking type
                area: fieldAreaInAcres,
                timeSlot: timeSlot,
                timePeriod: nil,
                location: bookingLocation.address ?? "\(bookingLocation.latitude), \(bookingLocation.longitude)",
                typeOfRequest: .sentRequest, // Sent from current user
                participants: [participant],
                acceptedUsers: nil // Don't include in database - not a database column
            )
            
            // Insert request into Supabase using RequestManager
            let success = await RequestManager.shared.createRequest(request)
            
            if success {
                print("✅ Invite sent to \(farmer.name) (ID: \(farmerUserId))")
                successCount += 1
            } else {
                print("❌ Failed to send invite to \(farmer.name)")
                failedCount += 1
            }
        }
        
        // Post notification to refresh requests
        NotificationCenter.default.post(name: .requestsUpdated, object: nil)
        
        print("✅ Invites sent: \(successCount) successful, \(failedCount) failed")
        
        // Show feedback to user
        await MainActor.run {
            if successCount > 0 {
                // Success feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
            if failedCount > 0 {
                self.errorMessage = "Some invites failed to send. Please try again."
            }
        }
    }
}

// MARK: - Distance Filter Enum

enum DistanceFilter: String, CaseIterable {
    case all = "All"
    case oneKm = "1 km"
    case twoKm = "2 km"
    
    var displayText: String {
        self.rawValue
    }
}

// MARK: - Supabase DTO

/// Data Transfer Object for decoding users from Supabase
struct FarmerDTO: Codable {
    let userID: String
    let name: String
    let phone: String?
    let latitude: Double
    let longitude: Double
    let address: String?
    
    enum CodingKeys: String, CodingKey {
        case userID
        case name
        case phone
        case latitude
        case longitude
        case address
    }
}
