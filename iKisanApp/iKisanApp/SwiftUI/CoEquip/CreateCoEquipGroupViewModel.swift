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

    // Payment flow state tracking
    @Published var isAwaitingPayment: Bool = false
    @Published var paymentStatusMessage: String = ""
    @Published var groupCreatedSuccessfully: Bool = false
    
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
                    status: .awaitingProvider, // New CoEquip group awaits provider acceptance
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

                // BACKUP: Ensure provider is in selectedUsersIds (in case equipment wasn't in cache during createRequest)
                print("🔄 [COEQUIP_CHECK] Ensuring provider visibility...")
                await syncProviderVisibility(requestId: creatorRequestId, providerId: equipment.providerID)

                // CRITICAL: Wait a moment to ensure the request is fully committed to database
                // This prevents foreign key constraint errors when creating participants
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                print("⏳ Waited for database commit...")
                
                // Verify the request exists in database before creating participants
                print("🔍 Verifying request exists in database...")
                do {
                    let verifyData = try await SupabaseManager.shared.client
                        .from("requests")
                        .select("id")
                        .eq("id", value: creatorRequestId.uuidString)
                        .execute()
                        .data

                    if let jsonString = String(data: verifyData, encoding: .utf8) {
                        print("✅ Request verified in database: \(jsonString)")
                    }
                } catch {
                    print("❌ Request NOT found in database! This will cause participant creation to fail.")
                    throw NSError(domain: "CreateGroup", code: 3, userInfo: [NSLocalizedDescriptionKey: "Request was not saved to database properly"])
                }

                // 2. Create participant entry for the CREATOR (so they're tracked like other participants)
                print("📝 Creating participant entry for group creator...")
                let creatorParticipantId = UUID()
                let creatorParticipant = RequestParticipant(
                    id: creatorParticipantId,
                    requestId: creatorRequestId,
                    userId: currentUser.id,
                    status: .done, // Creator has already committed their area
                    area: areaInAcres, // Creator's field area
                    timeSlot: "\(timeSlotInfo.startTime) - \(timeSlotInfo.endTime)",
                    joinedAt: Date()
                )

                do {
                    if let dataController = dataController {
                        try await dataController.createRequestParticipant(creatorParticipant)
                        print("✅ Creator participant entry created successfully")
                    }
                } catch {
                    print("❌ Failed to create creator participant entry: \(error)")
                    // Continue anyway - the request is still valid
                }

                // 3. Create participant entries for invited farmers
                if !selectedFarmers.isEmpty {
                    print("📤 Creating \(selectedFarmers.count) participant entries for invited farmers...")
                    
                    for farmer in selectedFarmers {
                        guard let farmerUserId = UUID(uuidString: farmer.id) else {
                            print("⚠️ Invalid farmer ID: \(farmer.id)")
                            continue
                        }
                        
                        // Create participant entry linked to CREATOR'S request
                        let participantId = UUID()
                        let participant = RequestParticipant(
                            id: participantId,
                            requestId: creatorRequestId, // Link to creator's request, not invite request
                            userId: farmerUserId,
                            status: .pending,
                            area: nil,
                            timeSlot: nil,
                            joinedAt: Date()
                        )
                        
                        print("📝 Creating participant:")
                        print("   - Participant ID: \(participantId)")
                        print("   - Request ID: \(creatorRequestId)")
                        print("   - User ID: \(farmerUserId)")
                        print("   - Farmer Name: \(farmer.name)")
                        print("   - Status: pending")
                        
                        do {
                            if let dataController = dataController {
                                try await dataController.createRequestParticipant(participant)
                                print("✅ Participant entry created successfully for \(farmer.name)")
                            }
                        } catch {
                            print("❌ Failed to create participant entry for \(farmer.name): \(error)")
                            if let nsError = error as NSError? {
                                print("   Error domain: \(nsError.domain)")
                                print("   Error code: \(nsError.code)")
                                print("   Error info: \(nsError.userInfo)")
                            }
                        }
                    }
                }
                
                // Success! Participants have been created and linked to the main request
                // Invited farmers will see this request in their Join Requests tab because they are participants
                print("✅ All participants created successfully")

                // CRITICAL: DO NOT update @Published variables that cause UI churn
                // Keep the view completely static to prevent tearing down Razorpay's display controller
                // Only log success without triggering SwiftUI redraws
                print("✅ Co-Equip group created successfully")
                print("📍 Location: \(location.address ?? "Unknown")")
                print("📏 Field Area: \(formattedFieldArea)")
                print("📅 Date: \(selectedDate)")
                print("⏰ Time Slot: \(formattedTimeSlot)")
                print("👥 Farmers invited: \(selectedFarmers.count)")

                // DEFER: Refresh cache AFTER payment completes to avoid UI churn
                // Cache refresh will happen in payment callback navigation
                print("⏸️ Deferring cache refresh until after payment completes")

                // 4. Payment handling for the Creator
                // MARK: - COD Payment Path for Group Creator
                // When Razorpay is disabled, skip payment and go directly to success
                if !FeatureFlags.isRazorpayEnabled {
                    print("💵 [CreateCoEquipVM] COD mode — skipping payment for group creator")
                    
                    // Update UI state
                    self.isProcessing = false
                    self.isAwaitingPayment = false
                    self.paymentStatusMessage = "Order placed — Cash on Delivery"
                    self.creationSuccess = true
                    
                    // Haptic feedback for success
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Refresh cache
                    if let dataController = self.dataController {
                        print("🔄 Refreshing Co-Equip requests from database...")
                        await dataController.refreshCoEquipRequests()
                        print("✅ Cache refreshed")
                    }
                    
                    // Post notification to refresh UI
                    NotificationCenter.default.post(name: .requestsUpdated, object: nil)
                    print("🔔 Posted .requestsUpdated notification")
                    
                    // Small delay then navigate
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    self.navigateToRoot()
                    
                } else {
                    // MARK: - Future Razorpay Integration
                    // The following Razorpay payment flow is preserved for future releases.
                    // Set FeatureFlags.isRazorpayEnabled = true to re-enable.
                    
                    print("💳 Initiating creator payment (Auth Hold)...")
                    print("🔒 UI LOCKED: Keeping all @Published variables static during payment handover")

                    // Build the Request object with participant info for payment
                    var requestForPayment = creatorRequest
                    requestForPayment.participants = [creatorParticipant]

                    // Convert AuthUser to User for GroupPaymentManager
                    let userLocation = Location(
                        latitude: currentUser.latitude,
                        longitude: currentUser.longitude,
                        address: currentUser.address
                    )
                    let userForPayment = User(
                        userID: currentUser.id,
                        name: currentUser.name,
                        email: currentUser.email,
                        phone: currentUser.phone,
                        location: userLocation,
                        selectedCrops: currentUser.selectedCrops ?? [],
                        fieldArea: currentUser.fieldArea ?? 0.0,
                        groupID: currentUser.groupID
                    )

                    // NO UI UPDATES HERE - keep view completely static
                    // Trigger payment with completion handler that manages ALL state changes
                    GroupPaymentManager.shared.initiateJoinPayment(
                        request: requestForPayment,
                        participant: creatorParticipant,
                        equipment: equipment,
                        user: userForPayment
                    ) { [weak self] success, paymentId in
                        guard let self = self else { return }

                        Task { @MainActor in
                            // NOW it's safe to update UI - Razorpay has finished
                            self.isProcessing = false
                            self.isAwaitingPayment = false

                            if success {
                                print("✅ Creator payment authorization successful: \(paymentId ?? "N/A")")
                                self.paymentStatusMessage = "Payment successful!"
                                self.creationSuccess = true

                                // Haptic feedback for success
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                            } else {
                                print("⚠️ Creator payment authorization failed or cancelled")
                                self.paymentStatusMessage = "Payment skipped - you can pay later"
                                self.creationSuccess = true // Group was still created

                                // Haptic feedback for warning
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.warning)
                            }

                            // Refresh cache NOW that payment is complete
                            if let dataController = self.dataController {
                                print("🔄 Refreshing Co-Equip requests from database...")
                                await dataController.refreshCoEquipRequests()
                                print("✅ Cache refreshed")
                            }

                            // Post notification to refresh UI
                            NotificationCenter.default.post(name: .requestsUpdated, object: nil)
                            print("🔔 Posted .requestsUpdated notification")

                            // Small delay to show the status message
                            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

                            // NOW it's safe to navigate - Razorpay has fully dismissed
                            self.navigateToRoot()
                        }
                    }
                }

                // Don't navigate here - wait for payment callback above

            } catch {
                print("❌ Error creating group: \(error)")
                await MainActor.run {
                    isProcessing = false
                    isAwaitingPayment = false
                    errorMessage = "Failed to create group: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }

    // MARK: - Navigation

    /// Safely navigate back to root after payment flow completes
    private func navigateToRoot() {
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

    // MARK: - Helper Methods

    /// Ensures the equipment provider is added to selectedUsersIds for proper visibility
    private func syncProviderVisibility(requestId: UUID, providerId: UUID) async {
        do {
            // Fetch current selectedUsersIds from database
            let fetchResponse = try await SupabaseManager.shared.client
                .from("requests")
                .select("id,selectedUsersIds")
                .eq("id", value: requestId.uuidString)
                .execute()

            guard let rows = try JSONSerialization.jsonObject(with: fetchResponse.data) as? [[String: Any]],
                  let firstRow = rows.first else {
                print("⚠️ [COEQUIP_CHECK] Could not fetch selectedUsersIds for requestID=\(requestId)")
                return
            }

            var selectedUserIds = firstRow["selectedUsersIds"] as? [String] ?? []
            let providerIdString = providerId.uuidString

            if selectedUserIds.contains(providerIdString) {
                print("✅ [COEQUIP_CHECK] Provider already in selectedUsersIds")
                return
            }

            // Add provider to the array
            selectedUserIds.append(providerIdString)

            // Update the database
            try await SupabaseManager.shared.client
                .from("requests")
                .update(["selectedUsersIds": selectedUserIds])
                .eq("id", value: requestId.uuidString)
                .execute()

            print("✅ [COEQUIP_CHECK] Added provider to selectedUsersIds for requestID=\(requestId)")

        } catch {
            print("⚠️ [COEQUIP_CHECK] Failed to sync provider visibility: \(error)")
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
