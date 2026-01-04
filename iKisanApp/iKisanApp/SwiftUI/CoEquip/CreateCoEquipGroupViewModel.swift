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
    
    // MARK: - Dependencies
    
    let equipment: Equipment
    weak var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
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
        navigationCoordinator: HomeNavigationCoordinator? = nil
    ) {
        self.equipment = equipment
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        
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
        
        isProcessing = true
        
        // TODO: Implement Co-Equip group creation logic
        // This will be integrated with backend API
        
        Task {
            do {
                // Simulate API call
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Success
                await MainActor.run {
                    isProcessing = false
                    
                    // Show success feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    print("✅ Co-Equip group created successfully")
                    print("📍 Location: \(bookingLocation?.address ?? "Unknown")")
                    print("📏 Field Area: \(formattedFieldArea)")
                    print("📅 Date: \(selectedDate)")
                    print("⏰ Time Slot: \(formattedTimeSlot)")
                    print("👥 Farmers: \(selectedFarmers.count)")
                    
                    // Navigate back or to confirmation screen
                    // navigationCoordinator?.popToRoot()
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
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
    let location: Location?
    let distance: Double? // Distance from booking location in km
    
    static func == (lhs: Farmer, rhs: Farmer) -> Bool {
        lhs.id == rhs.id
    }
}
