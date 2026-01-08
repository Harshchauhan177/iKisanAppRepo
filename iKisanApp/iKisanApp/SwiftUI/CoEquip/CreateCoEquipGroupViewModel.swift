//
//  CreateCoEquipGroupViewModel.swift
//  iKisanApp
//
//  ViewModel for Create Co-Equip Group Screen
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CreateCoEquipGroupViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedDate: Date = Date()
    @Published var fieldArea: String = ""
    @Published var selectedFieldAreaUnit: FieldAreaUnit = .acre
    @Published var bookingLocation: Location?
    @Published var locationText: String = "Tap to select location"
    @Published var selectedFarmers: [Farmer] = []
    @Published var showLocationPicker: Bool = false
    @Published var showFarmerSelection: Bool = false
    @Published var showDatePicker: Bool = false
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var creationSuccess: Bool = false
    
    // MARK: - Dependencies
    
    let equipment: Equipment
    weak var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    var router: CoEquipNavigationRouter?
    var onDismiss: (() -> Void)?
    
    // MARK: - Computed Properties
    
    /// Field area converted to acres (base unit for calculations)
    var fieldAreaInAcres: Double? {
        guard let area = Double(fieldArea), area > 0 else { return nil }
        return selectedFieldAreaUnit.convertToAcres(area)
    }
    
    /// Formatted field area with unit
    var formattedFieldArea: String {
        guard let area = Double(fieldArea), area > 0 else { return "Not set" }
        return "\(String(format: "%.2f", area)) \(selectedFieldAreaUnit.symbol)"
    }
    
    /// Formatted date string for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    /// Calculate time slots based on field area
    /// Rule: 0.5 hours per acre, starting at 8:00 AM
    var calculatedTimeSlots: [TimeSlotInfo] {
        guard let areaInAcres = fieldAreaInAcres, areaInAcres > 0 else {
            return []
        }
        
        // Calculate duration in hours (0.5 hours per acre)
        let durationInHours = areaInAcres * 0.5
        
        // Round up to nearest 0.5 hour increment
        let roundedDuration = ceil(durationInHours * 2) / 2
        
        // Start time: 8:00 AM
        let startHour = 8
        let startMinute = 0
        
        // Calculate end time
        let totalMinutes = Int(roundedDuration * 60)
        let endHour = startHour + (totalMinutes / 60)
        let endMinute = startMinute + (totalMinutes % 60)
        
        // Create time slot info
        let startTime = String(format: "%d:%02d", startHour, startMinute)
        let endTime = String(format: "%d:%02d", endHour, endMinute)
        
        return [TimeSlotInfo(
            startTime: startTime,
            endTime: endTime,
            durationHours: roundedDuration,
            areaInAcres: areaInAcres
        )]
    }
    
    /// Formatted time slot string for display
    var formattedTimeSlot: String {
        guard let timeSlot = calculatedTimeSlots.first else {
            return "Enter field area to calculate"
        }
        
        return "\(timeSlot.startTime) - \(timeSlot.endTime) (\(String(format: "%.1f", timeSlot.durationHours))h)"
    }
    
    /// Selected farmers count text
    var selectedFarmersText: String {
        if selectedFarmers.isEmpty {
            return "0 Selected"
        } else if selectedFarmers.count == 1 {
            return selectedFarmers[0].name
        } else if selectedFarmers.count == 2 {
            return "\(selectedFarmers[0].name), \(selectedFarmers[1].name)"
        } else {
            return "\(selectedFarmers.count) Selected"
        }
    }
    
    /// Form validation
    var isFormValid: Bool {
        // Must have location
        guard bookingLocation != nil else { return false }
        
        // Must have valid field area
        guard let area = Double(fieldArea), area > 0 else { return false }
        
        // Must have valid date (not in the past)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)
        guard selectedDay >= today else { return false }
        
        return true
    }
    
    // MARK: - Initialization
    
    init(
        equipment: Equipment,
        dataController: DataController? = nil,
        navigationCoordinator: HomeNavigationCoordinator? = nil,
        router: CoEquipNavigationRouter? = nil
    ) {
        self.equipment = equipment
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        self.router = router
        
        // Set minimum date to today
        let calendar = Calendar.current
        self.selectedDate = calendar.startOfDay(for: Date())
        
        // Load user's default location
        loadUserDefaultLocation()
    }
    
    // MARK: - Private Helper Methods
    
    private func loadUserDefaultLocation() {
        // Try to get user's location from profile
        if let userLocation = AuthManager.shared.currentUser?.location {
            self.bookingLocation = userLocation
            self.locationText = userLocation.address ?? "Current location"
        } else if let user = AuthManager.shared.currentUser,
                  user.latitude != 0.0 || user.longitude != 0.0 {
            let location = Location(
                latitude: user.latitude,
                longitude: user.longitude,
                address: user.address
            )
            self.bookingLocation = location
            self.locationText = user.address ?? "Current location"
        }
    }
    
    // MARK: - Actions
    
    func updateLocation(_ location: Location) {
        bookingLocation = location
        locationText = location.address ?? "Location: \(location.latitude), \(location.longitude)"
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func addFarmer(_ farmer: Farmer) {
        if !selectedFarmers.contains(where: { $0.id == farmer.id }) {
            selectedFarmers.append(farmer)
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func removeFarmer(_ farmer: Farmer) {
        selectedFarmers.removeAll(where: { $0.id == farmer.id })
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func createGroup() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        guard let currentUser = AuthManager.shared.currentUser else {
            errorMessage = "Please log in to continue"
            showError = true
            return
        }
        
        guard let location = bookingLocation else {
            errorMessage = "Please select a location"
            showError = true
            return
        }
        
        guard let fieldAreaValue = Double(fieldArea), fieldAreaValue > 0 else {
            errorMessage = "Please enter a valid field area"
            showError = true
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                print("🚀 Starting Co-Equip group creation...")
                
                // Convert field area to acres
                let areaInAcres = selectedFieldAreaUnit.convertToAcres(fieldAreaValue)
                
                // Get time slot
                guard let timeSlotInfo = calculatedTimeSlots.first else {
                    throw NSError(domain: "CreateGroup", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to calculate time slot"])
                }
                
                let timeSlot: TimeSlot = .morning
                
                // 1. Create the main request for the group creator (owner)
                let creatorRequestId = UUID()
                
                let creatorRequest = Request(
                    id: creatorRequestId,
                    userId: currentUser.id,
                    equipmentId: equipment.equipmentID,
                    requestedDate: selectedDate,
                    status: .pending, // Creator's request starts as pending
                    type: .coEquip,
                    area: areaInAcres,
                    timeSlot: timeSlot,
                    timePeriod: "\(timeSlotInfo.startTime) - \(timeSlotInfo.endTime)",
                    location: location.address ?? "\(location.latitude), \(location.longitude)",
                    typeOfRequest: .myRequest, // This is the creator's own request
                    participants: [],
                    acceptedUsers: nil // Don't include acceptedUsers in database
                )
                
                // Insert creator's request into Supabase using RequestManager
                print("📝 Creating group creator's request...")
                let success = await RequestManager.shared.createRequest(creatorRequest)
                if !success {
                    throw NSError(domain: "CreateGroup", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create creator request"])
                }
                print("✅ Creator request saved to Supabase")
                
                // 2. Create participant entries for the creator's request (invited farmers)
                if !selectedFarmers.isEmpty {
                    print("📤 Creating \(selectedFarmers.count) participant entries for creator's request...")
                    
                    for farmer in selectedFarmers {
                        guard let farmerUserId = UUID(uuidString: farmer.id) else {
                            print("⚠️ Invalid farmer ID: \(farmer.id)")
                            continue
                        }
                        
                        // Create participant entry linked to CREATOR'S request
                        let participant = RequestParticipant(
                            id: UUID(),
                            requestId: creatorRequestId, // Link to creator's request, not invite request
                            userId: farmerUserId,
                            status: .pending,
                            area: nil,
                            timeSlot: nil,
                            joinedAt: Date()
                        )
                        
                        do {
                            if let dataController = dataController {
                                try await dataController.createRequestParticipant(participant)
                                print("✅ Participant entry created for \(farmer.name) linked to creator's request")
                            }
                        } catch {
                            print("❌ Failed to create participant entry for \(farmer.name): \(error)")
                        }
                    }
                }
                
                // 3. Send invites to selected farmers (notification requests only, NO duplicate participants)
                if !selectedFarmers.isEmpty {
                    print("📤 Sending invite notifications to \(selectedFarmers.count) farmers...")
                    
                    var successCount = 0
                    var failedCount = 0
                    
                    for farmer in selectedFarmers {
                        guard let farmerUserId = UUID(uuidString: farmer.id) else {
                            print("⚠️ Invalid farmer ID: \(farmer.id)")
                            failedCount += 1
                            continue
                        }
                        
                        let inviteRequestId = UUID()
                        
                        // Create invite request (notification for the invited farmer)
                        // NOTE: No participants array - this is just a pointer/notification
                        let inviteRequest = Request(
                            id: inviteRequestId,
                            userId: currentUser.id, // Creator
                            equipmentId: equipment.equipmentID,
                            requestedDate: selectedDate,
                            status: .pending,
                            type: .coEquip,
                            area: areaInAcres,
                            timeSlot: timeSlot,
                            timePeriod: "\(timeSlotInfo.startTime) - \(timeSlotInfo.endTime)",
                            location: location.address ?? "\(location.latitude), \(location.longitude)",
                            typeOfRequest: .sentRequest,
                            participants: [], // Empty - no duplicate participants
                            acceptedUsers: nil
                        )
                        
                        // Insert invite into Supabase using RequestManager
                        let success = await RequestManager.shared.createRequest(inviteRequest)
                        if success {
                            print("✅ Invite notification sent to \(farmer.name)")
                            successCount += 1
                        } else {
                            print("❌ Failed to send invite to \(farmer.name)")
                            failedCount += 1
                        }
                    }
                    
                    print("📊 Invite summary: \(successCount) successful, \(failedCount) failed")
                }
                
                // Success!
                await MainActor.run {
                    isProcessing = false
                    creationSuccess = true
                    
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    print("✅ Co-Equip group created successfully")
                    print("📍 Location: \(location.address ?? "Unknown")")
                    print("📏 Field Area: \(formattedFieldArea)")
                    print("📅 Date: \(selectedDate)")
                    print("⏰ Time Slot: \(formattedTimeSlot)")
                    print("👥 Farmers invited: \(selectedFarmers.count)")
                }
                
                // Force refresh the cache from database BEFORE posting notification
                if let dataController = dataController {
                    print("🔄 Refreshing Co-Equip requests from database...")
                    await dataController.refreshCoEquipRequests()
                    print("✅ Cache refreshed with new request")
                }
                
                await MainActor.run {
                    // Post notification to refresh CoEquipViewModel UI
                    NotificationCenter.default.post(name: .requestsUpdated, object: nil)
                    print("🔔 Posted .requestsUpdated notification")
                }
                
                // Small delay to ensure notification is processed
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                await MainActor.run {
                    // Navigate back to root
                    print("🧭 Navigation options:")
                    print("   Router: \(router != nil ? "exists" : "nil")")
                    print("   Coordinator: \(navigationCoordinator != nil ? "exists" : "nil")")
                    print("   Dismiss callback: \(onDismiss != nil ? "exists" : "nil")")
                    
                    if let router = router {
                        // Preferred: Use router to pop to root
                        router.popToRoot()
                        print("🔙 Called router.popToRoot()")
                    } else if let navigationCoordinator = navigationCoordinator {
                        // Fallback: Use navigation coordinator
                        navigationCoordinator.popToRoot()
                        print("🔙 Called coordinator.popToRoot()")
                    } else if let onDismiss = onDismiss {
                        // Last resort: Use dismiss callback
                        onDismiss()
                        print("🔙 Called dismiss callback")
                    } else {
                        print("⚠️ No navigation method available")
                    }
                }
                
            } catch {
                print("❌ Error creating group: \(error)")
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Failed to create group: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Supporting Types

/// Time slot information calculated based on field area
struct TimeSlotInfo: Identifiable {
    let id = UUID()
    let startTime: String
    let endTime: String
    let durationHours: Double
    let areaInAcres: Double
}

/// Farmer model for participant selection
struct Farmer: Identifiable, Equatable {
    let id: String
    let name: String
    let phoneNumber: String?
    let location: Location // Required for distance calculation
    var distance: Double = 0.0 // Distance from current user in km (calculated dynamically)
    
    static func == (lhs: Farmer, rhs: Farmer) -> Bool {
        lhs.id == rhs.id
    }
}
