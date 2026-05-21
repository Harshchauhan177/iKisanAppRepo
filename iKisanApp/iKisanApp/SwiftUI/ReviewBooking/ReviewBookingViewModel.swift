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
    
    /// Set to true after booking is placed/updated — observed by the view to trigger dismiss
    @Published var shouldDismiss: Bool = false
    
    /// Selected payment method — defaults to COD when Razorpay is disabled
    @Published var selectedPaymentMethod: PaymentMethod = FeatureFlags.isRazorpayEnabled ? .razorpay : .cashOnDelivery
    
    // MARK: - Future Razorpay Integration
    // Razorpay instance - strong reference to prevent deallocation during payment
    private var razorpay: RazorpayCheckout?
    private var pendingBooking: Booking?
    
    // MARK: - Dependencies
    
    let equipment: Equipment
    let bookingSource: BookingSource
    weak var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    /// Whether this is modifying an existing booking (vs. creating new)
    let isModifying: Bool
    /// The existing booking being modified (nil for new bookings)
    private let existingBookingData: Booking?
    
    // Strong references to prevent deallocation during async operations
    private var retainedDataController: DataController?
    private var isPaymentInProgress: Bool = false
    
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
        existingBooking: Booking? = nil,
        isModifying: Bool = false,
        preselectedDate: Date? = nil
    ) {
        self.equipment = equipment
        self.bookingSource = bookingSource
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        self.retainedDataController = dataController
        self.isModifying = isModifying
        self.existingBookingData = existingBooking
        
        // MARK: - Future Razorpay Integration
        // Initialize Razorpay only when the feature is enabled
        if FeatureFlags.isRazorpayEnabled {
            self.razorpay = RazorpayCheckout.initWithKey("rzp_test_A9W91a51kUjKmX", andDelegate: self)
        }
        
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
            // Use preselected date if provided (e.g. from prebooking calendar)
            if let preDate = preselectedDate {
                self.selectedDate = preDate
            }
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
        
        // Prevent multiple simultaneous payment attempts
        guard !isPaymentInProgress else {
            print("⚠️ Payment already in progress")
            return
        }
        
        isProcessing = true
        isPaymentInProgress = true
        
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
        
        // Use existing booking ID when modifying, otherwise generate new
        let bookingID = (isModifying ? existingBookingData?.bookingID : nil) ?? UUID()
        
        let newBooking = Booking(
            bookingID: bookingID,
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
        
        // MARK: - COD Payment Path
        // When Razorpay is disabled, process as Cash on Delivery
        if selectedPaymentMethod == .cashOnDelivery || !FeatureFlags.isRazorpayEnabled {
            print("💵 Processing Cash on Delivery order...")
            placeCODOrder(booking: newBooking)
            return
        }
        
        // MARK: - Future Razorpay Integration
        // The following Razorpay payment flow is preserved for future releases.
        // Set FeatureFlags.isRazorpayEnabled = true to re-enable.
        
        // Ensure Razorpay is initialized
        guard let razorpayInstance = razorpay else {
            errorMessage = "Payment system is not initialized. Please try again."
            showError = true
            isProcessing = false
            isPaymentInProgress = false
            return
        }
        
        // Prepare Razorpay options
        let options: [String: Any] = [
            "amount": String(Int(payableAmount * 100)), // Amount in paise
            "currency": "INR",
            "description": "Equipment Booking - \(equipment.name)",
            "image": equipment.equipmentImage,
            "name": "iKisan",
            "prefill": [
                "email": AuthManager.shared.currentUser?.email ?? "",
                "contact": AuthManager.shared.currentUser?.phone ?? ""
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
        razorpayInstance.open(options)
        
        // Reset processing after a short delay (Razorpay takes control)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isProcessing = false
        }
    }
    
    // MARK: - Cash on Delivery Order Placement
    
    /// Places the order directly as COD, bypassing the Razorpay payment gateway.
    /// The booking is created, marked as confirmed, and the user is navigated to success.
    private func placeCODOrder(booking: Booking) {
        Task { @MainActor in
            // 1. Add or update booking in local data controller
            if let dataController = self.retainedDataController ?? self.dataController {
                if isModifying {
                    dataController.updateBooking(booking)
                    print("📝 Updated existing booking locally: \(booking.bookingID)")
                } else {
                    _ = dataController.addBooking(booking)
                    print("➕ Added new booking locally: \(booking.bookingID)")
                }
            }
            
            // 2. Update/insert booking in Supabase
            struct CODStatusUpdate: Codable {
                var status: BookingStatus = .confirmed
                var paymentMethod: String = "cod"
            }
            
            do {
                if isModifying {
                    // For modify: update the existing booking fields in Supabase
                    struct BookingUpdate: Codable {
                        let bookingDate: Date
                        let fieldArea: Double
                        let timeSlot: TimeSlot
                        var status: BookingStatus = .pending
                        var paymentMethod: String = "cod"
                    }
                    
                    try await SupabaseManager.shared.client
                        .from("bookings")
                        .update(BookingUpdate(
                            bookingDate: booking.bookingDate,
                            fieldArea: booking.fieldArea,
                            timeSlot: booking.timeSlot
                        ))
                        .eq("bookingID", value: booking.bookingID)
                        .execute()
                    
                    print("✅ COD Booking updated in backend")
                } else {
                    try await SupabaseManager.shared.client
                        .from("bookings")
                        .update(CODStatusUpdate())
                        .eq("bookingID", value: booking.bookingID)
                        .execute()
                    
                    print("✅ COD Booking confirmed in backend")
                }
            } catch {
                print("⚠️ Error updating COD booking status: \(error)")
                // Continue anyway — booking is already saved locally
            }
            
            // 3. Post notification based on booking source
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
            
            // 4. Reset payment flags
            self.isPaymentInProgress = false
            self.isProcessing = false
            
            // 5. Navigate to success
            let action = isModifying ? "updated" : "placed"
            print("✅ COD order \(action) successfully — navigating to confirmation")
            self.navigateAfterPaymentSuccess()
        }
    }
    
    // MARK: - Future Razorpay Integration — Payment Completion Protocol
    // These callbacks are invoked by the Razorpay SDK when payment completes.
    // They remain fully functional for when FeatureFlags.isRazorpayEnabled is set to true.
    
    nonisolated func onPaymentError(_ code: Int32, description str: String) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            self.isProcessing = false
            self.isPaymentInProgress = false
            
            // Provide user-friendly error messages based on error code
            let userFriendlyMessage: String
            switch code {
            case 0:
                userFriendlyMessage = "Payment was cancelled. Please try again when ready."
            case 2:
                userFriendlyMessage = "Network error. Please check your connection and try again."
            default:
                userFriendlyMessage = "Payment failed. Please try again."
            }
            
            self.errorMessage = userFriendlyMessage
            self.showError = true
            
            // Log detailed error for debugging
            print("❌ Payment Error: \(str) (Code: \(code))")
        }
    }
    
    nonisolated func onPaymentSuccess(_ payment_id: String) {
        Task { @MainActor [weak self] in
            guard let self = self else {
                print("❌ ViewModel deallocated during payment")
                return
            }
            
            guard let booking = self.pendingBooking else {
                print("❌ No pending booking found")
                self.isPaymentInProgress = false
                return
            }
            
            print("✅ Payment Success: \(payment_id)")
            
            // Add booking to data controller (use retained reference)
            if let dataController = self.retainedDataController ?? self.dataController {
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
            
            // Reset payment flag
            self.isPaymentInProgress = false
            
            // Navigate back to appropriate screen
            self.navigateAfterPaymentSuccess()
        }
    }
    
    private func navigateAfterPaymentSuccess() {
        // Get the navigation controller and navigate back
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = window.rootViewController as? UITabBarController else {
            print("⚠️ Unable to access tab bar controller for navigation")
            // Still show success alert even if navigation fails
            showSuccessAlert()
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
                        let firstVC = navController.viewControllers.first
                        return firstVC is PrebookingViewController || firstVC is PrebookingViewControllerSwiftUI
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
        
        // Signal SwiftUI views to dismiss (for NavigationStack-pushed views)
        self.shouldDismiss = true
        
        // Show success message after navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showSuccessAlert()
        }
    }
    
    private func showSuccessAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let topController = window.rootViewController else {
            print("⚠️ Unable to present success alert - no root view controller")
            return
        }
        
        // Find the topmost presented view controller
        var presentedController = topController
        while let presented = presentedController.presentedViewController {
            presentedController = presented
        }
        
        // HIG: Use positive confirmation with clear messaging
        let alert = UIAlertController(
            title: "Booking Confirmed",
            message: "Your equipment booking has been confirmed successfully!",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Clean up retained references after confirmation
            self?.retainedDataController = nil
        }
        
        // HIG: Use system colors for consistency
        if #available(iOS 13.0, *) {
            okAction.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        } else {
            okAction.setValue(UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        }
        
        alert.addAction(okAction)
        
        presentedController.present(alert, animated: true)
    }
    
    // MARK: - Cleanup
    
    deinit {
        // Clean up to prevent memory leaks
        razorpay = nil
        retainedDataController = nil
        pendingBooking = nil
        print("✅ ReviewBookingViewModel deallocated")
    }
}
