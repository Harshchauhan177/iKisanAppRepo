//
//  ReviewBookingViewModel.swift
//  iKisanApp
//
//  ViewModel for Review Booking Screen
//

import Foundation
import Combine
import SwiftUI
import UIKit
import Razorpay

@MainActor
class ReviewBookingViewModel: ObservableObject, RazorpayPaymentCompletionProtocol {
    // MARK: - Published Properties
    
    @Published var selectedDate: Date = Date()
    @Published var fieldArea: String = ""
    @Published var selectedFieldAreaUnit: FieldAreaUnit = .acre
    @Published var selectedTimeSlot: TimeSlot = .morning
    @Published var bookingLocation: Location?
    @Published var locationText: String = "Tap to select location"
    @Published var isEquipmentAvailable: Bool = true
    @Published var showLocationPicker: Bool = false
    @Published var showDatePicker: Bool = false
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var payableAmount: Double = 0
    
    // Razorpay instance
    private var razorpay: RazorpayCheckout?
    private var pendingBooking: Booking?
    
    // MARK: - Dependencies
    
    let equipment: Equipment
    let bookingSource: BookingSource
    weak var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    // MARK: - Computed Properties
    
    var pricePerHour: Double {
        equipment.pricePerHour
    }
    
    var formattedPrice: String {
        "₹\(String(format: "%.1f", pricePerHour))"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var equipmentLocation: String {
        equipment.location
    }
    
    var isFormValid: Bool {
        guard let area = Double(fieldArea), area > 0 else {
            return false
        }
        return bookingLocation != nil && isEquipmentAvailable
    }
    
    /// Field area converted to acres (base unit for calculations)
    var fieldAreaInAcres: Double? {
        guard let area = Double(fieldArea), area > 0 else {
            return nil
        }
        return selectedFieldAreaUnit.convertToAcres(area)
    }
    
    /// Formatted field area with unit
    var formattedFieldArea: String {
        guard let area = Double(fieldArea), area > 0 else {
            return "Not specified"
        }
        return "\(String(format: "%.2f", area)) \(selectedFieldAreaUnit.symbol)"
    }
    
    /// Calculated total price based on field area and equipment price per hour
    var totalPrice: Double {
        guard let areaInAcres = fieldAreaInAcres else {
            return 0.0
        }
        return equipment.pricePerHour * areaInAcres
    }
    
    /// Formatted total price string
    var formattedTotalPrice: String {
        if totalPrice > 0 {
            return "₹\(String(format: "%.2f", totalPrice))"
        } else {
            return "Price per hour: ₹\(String(format: "%.1f", pricePerHour))"
        }
    }
    
    // MARK: - Initialization
    
    init(
        equipment: Equipment,
        bookingSource: BookingSource,
        dataController: DataController?,
        navigationCoordinator: HomeNavigationCoordinator?,
        existingBooking: Booking? = nil
    ) {
        self.equipment = equipment
        self.bookingSource = bookingSource
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        
        // Initialize Razorpay
        self.razorpay = RazorpayCheckout.initWithKey("rzp_test_A9W91a51kUjKmX", andDelegate: self)
        
        // Load existing booking data if modifying
        if let booking = existingBooking {
            self.selectedDate = booking.bookingDate
            self.fieldArea = String(booking.fieldArea)
            self.selectedTimeSlot = booking.timeSlot
            if let loc = booking.bookingLocation {
                self.bookingLocation = loc
                self.locationText = loc.address ?? "Location selected"
            }
        } else {
            // Try to load user's default location
            loadUserDefaultLocation()
        }
        
        // Check initial availability
        checkAvailability()
        
        // Update available time slots
        updateAvailableTimeSlots()
    }
    
    // MARK: - Private Helper Methods
    
    private func loadUserDefaultLocation() {
        // Try to get user's location from profile
        if let userLocation = AuthManager.shared.currentUser?.location {
            self.bookingLocation = userLocation
            self.locationText = userLocation.address ?? "Current location"
        } else if let user = AuthManager.shared.currentUser, 
                  (user.latitude != 0.0 || user.longitude != 0.0) {
            let location = Location(
                latitude: user.latitude,
                longitude: user.longitude,
                address: user.address
            )
            self.bookingLocation = location
            self.locationText = user.address ?? "Current location"
        }
    }
    
    private func updateAvailableTimeSlots() {
        guard let dataController = dataController else { return }
        
        // Get available time slots for the selected date
        let availableSlots = dataController.getAvailableTimeSlots(
            equipmentID: equipment.equipmentID,
            date: selectedDate
        )
        
        // If current time slot is not available, reset it
        if !availableSlots.contains(selectedTimeSlot) && !availableSlots.isEmpty {
            selectedTimeSlot = availableSlots[0]
        }
    }
    
    // MARK: - Actions
    
    func selectTimeSlot(_ timeSlot: TimeSlot) {
        selectedTimeSlot = timeSlot
        checkAvailability()
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func updateLocation(_ location: Location) {
        bookingLocation = location
        locationText = location.address ?? "Location: \(location.latitude), \(location.longitude)"
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func checkAvailability() {
        guard let dataController = dataController else {
            isEquipmentAvailable = true
            return
        }
        
        // Check if equipment is available for selected date and time
        isEquipmentAvailable = dataController.isEquipmentAvailable(
            equipmentID: equipment.equipmentID,
            date: selectedDate,
            timeSlot: selectedTimeSlot
        )
        
        // Update available time slots when date changes
        updateAvailableTimeSlots()
    }
    
    func proceedToPayment() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        guard let areaInAcres = fieldAreaInAcres else {
            errorMessage = "Please enter a valid field area"
            showError = true
            return
        }
        
        guard bookingLocation != nil else {
            errorMessage = "Please select a location for booking"
            showError = true
            return
        }
        
        // Check equipment availability one more time
        if !isEquipmentAvailable {
            errorMessage = "This equipment is not available for the selected date and time slot. Please choose a different date or time slot."
            showError = true
            return
        }
        
        isProcessing = true
        
        // Calculate payable amount (using price per hour as base)
        payableAmount = equipment.pricePerHour * areaInAcres
        
        // Determine booking type based on source
        let bookingType: BookingType
        switch bookingSource {
        case .home:
            bookingType = .onDemand
        case .prebooking:
            bookingType = .prebooking
        case .coEquip, .coEquipViewOnly:
            bookingType = .coEquip
        }
        
        // Check if user is logged in using AuthManager (consistent with UIKit implementation)
        guard let currentUser = AuthManager.shared.currentUser else {
            errorMessage = "User not logged in"
            showError = true
            isProcessing = false
            return
        }
        
        let userID = currentUser.id
        
        let newBooking = Booking(
            bookingID: UUID(),
            userID: userID,
            equipmentID: equipment.equipmentID,
            bookingType: bookingType,
            bookingDate: selectedDate,
            fieldArea: areaInAcres, // Store in acres for consistency
            status: .pending,
            timeSlot: selectedTimeSlot,
            source: bookingSource,
            bookingLocation: bookingLocation
        )
        
        // Store booking temporarily
        pendingBooking = newBooking
        
        // Prepare Razorpay options
        let options: [String: Any] = [
            "amount": String(Int(payableAmount * 100)), // Amount in paise
            "currency": "INR",
            "description": "Equipment Booking - \(equipment.name)",
            "image": equipment.equipmentImage,
            "name": "iKisan",
            "prefill": [
                "email": AuthManager.shared.currentUser?.email ?? ""
            ],
            "theme": [
                "color": "#4C7F5F" // iKisan green
            ],
            "notes": [
                "bookingId": newBooking.bookingID.uuidString,
                "equipmentName": equipment.name
            ]
        ]
        
        // Open Razorpay payment
        razorpay?.open(options)
        
        // Reset processing after a short delay (Razorpay takes control)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isProcessing = false
        }
    }
    
    // MARK: - Razorpay Payment Completion Protocol
    
    nonisolated func onPaymentError(_ code: Int32, description str: String) {
        Task { @MainActor in
            isProcessing = false
            errorMessage = "Payment failed: \(str)"
            showError = true
            
            // Log error
            print("❌ Payment Error: \(str) (Code: \(code))")
        }
    }
    
    nonisolated func onPaymentSuccess(_ payment_id: String) {
        Task { @MainActor in
            guard let booking = pendingBooking else {
                print("❌ No pending booking found")
                return
            }
            
            print("✅ Payment Success: \(payment_id)")
            
            // Add booking to data controller
            if let dataController = dataController {
                _ = dataController.addBooking(booking)
            }
            
            // Update booking status in database
            struct StatusUpdate: Codable {
                var status: BookingStatus = .confirmed
            }
            
            do {
                try await SupabaseManager.shared.client
                    .from("bookings")
                    .update(StatusUpdate())
                    .eq("bookingID", value: booking.bookingID)
                    .execute()
                
                print("✅ Booking status updated to confirmed")
            } catch {
                print("⚠️ Error updating booking status: \(error)")
                // Continue anyway - booking is already added locally
            }
            
            // Post notification based on booking source
            switch booking.source {
            case .prebooking:
                NotificationCenter.default.post(
                    name: Notification.Name.preBookingAdded,
                    object: nil,
                    userInfo: ["booking": booking]
                )
            default:
                NotificationCenter.default.post(
                    name: .bookingAdded,
                    object: nil
                )
            }
            
            // Navigate back to appropriate screen
            navigateAfterPaymentSuccess()
        }
    }
    
    private func navigateAfterPaymentSuccess() {
        // Get the navigation controller and navigate back
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController else {
            return
        }
        
        // Determine which tab to switch to based on booking source
        let targetTabIndex: Int
        switch bookingSource {
        case .home:
            targetTabIndex = 0 // Home tab
        case .prebooking:
            // Find prebooking tab
            if let viewControllers = tabBarController.viewControllers {
                targetTabIndex = viewControllers.firstIndex(where: { vc in
                    if let navController = vc as? UINavigationController {
                        return navController.viewControllers.first is PrebookingViewController
                    }
                    return false
                }) ?? 0
            } else {
                targetTabIndex = 0
            }
        default:
            targetTabIndex = 0
        }
        
        // Switch to target tab
        tabBarController.selectedIndex = targetTabIndex
        
        // Pop to root view controller in that tab
        if let navController = tabBarController.selectedViewController as? UINavigationController {
            navController.popToRootViewController(animated: true)
        }
        
        // Show success message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showSuccessAlert()
        }
    }
    
    private func showSuccessAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let topController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "Booking Confirmed",
            message: "Your booking has been confirmed successfully!",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        okAction.setValue(UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        alert.addAction(okAction)
        
        topController.present(alert, animated: true)
    }
}
