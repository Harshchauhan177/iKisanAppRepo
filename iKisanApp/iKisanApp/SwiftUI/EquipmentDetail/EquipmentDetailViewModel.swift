//
//  EquipmentDetailViewModel.swift
//  iKisanApp
//
//  ViewModel for Equipment Detail Screen following MVVM architecture
//

import Foundation
import SwiftUI
import Combine
import UIKit
import MapKit
import CoreLocation

@MainActor
class EquipmentDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var equipment: Equipment
    @Published var reviews: [ReviewData] = []
    @Published var filteredReviews: [ReviewData] = []
    @Published var userCanWriteReview: Bool = false
    @Published var isLoading: Bool = false
    @Published var showingImageGallery: Bool = false
    @Published var selectedImageIndex: Int = 0
    
    // Navigation state for SwiftUI native navigation
    @Published var showBookingOptions: Bool = false
    @Published var navigateToReviewBooking: Bool = false
    
    // MARK: - Computed Properties
    
    var displayImages: [String] {
        var images = [equipment.equipmentImage]
        images.append(contentsOf: equipment.equipmentMoreImages.images)
        return images
    }
    
    var visibleImages: [String] {
        Array(displayImages.prefix(4))
    }
    
    var remainingImagesCount: Int {
        max(0, displayImages.count - 4)
    }
    
    var averageRating: Double {
        guard !filteredReviews.isEmpty else { return 0.0 }
        let sum = filteredReviews.reduce(0.0) { $0 + $1.rating }
        return sum / Double(filteredReviews.count)
    }
    
    var formattedAverageRating: String {
        String(format: "%.1f", averageRating)
    }
    
    var reviewCountText: String {
        let count = filteredReviews.count
        return "\(count) review\(count != 1 ? "s" : "")"
    }
    
    var pricePerHourText: String {
        "₹\(Int(equipment.pricePerHour))/hr"
    }
    
    var originalPricePerHourText: String {
        "₹\(Int(equipment.realPricePerHour))/hr"
    }
    
    var pricePerAcreText: String {
        "₹\(Int(equipment.pricePerAcre))/ac"
    }
    
    var originalPricePerAcreText: String {
        "₹\(Int(equipment.realPricePerAcre))/ac"
    }
    
    var hasDiscount: Bool {
        equipment.pricePerHour < equipment.realPricePerHour
    }
    
    var locationText: String {
        equipment.location
    }
    
    var ratingText: String {
        // Use average rating from reviews if available, otherwise fall back to equipment rating
        let rating = filteredReviews.isEmpty ? equipment.rating : averageRating
        return String(format: "%.1f", rating)
    }
    
    var coEquipText: String {
        "\(equipment.coEquipDetail.rawValue) For CoEquip"
    }
    
    var providerNameText: String {
        equipment.providerName ?? "Provider"
    }
    
    var hostedByText: String {
        "Hosted by: \(providerNameText)"
    }
    
    // MARK: - Dependencies
    
    let dataController: DataController?
    var bookingSource: BookingSource
    weak var navigationCoordinator: HomeNavigationCoordinator?
    var router: CoEquipNavigationRouter? // Router for navigation
    let isReadOnly: Bool // New property for read-only mode
    
    // MARK: - Initialization
    
    init(
        equipment: Equipment,
        bookingSource: BookingSource,
        dataController: DataController?,
        navigationCoordinator: HomeNavigationCoordinator?,
        router: CoEquipNavigationRouter? = nil,
        isReadOnly: Bool = false
    ) {
        self.equipment = equipment
        self.bookingSource = bookingSource
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        self.router = router
        self.isReadOnly = isReadOnly
        
        loadReviews()
        checkUserBookingStatus()
    }
    
    // MARK: - Data Loading
    
    func loadReviews() {
        // Filter reviews for this equipment
        filteredReviews = ReviewDataClass.reviews.filter { review in
            review.equipmentID?.lowercased() == equipment.equipmentID.uuidString.lowercased()
        }
        
        print("📝 Loaded \(filteredReviews.count) reviews for \(equipment.name)")
    }
    
    private func checkUserBookingStatus() {
        guard let dataController = dataController else {
            userCanWriteReview = false
            return
        }
        
        // Get current user to check their bookings
        guard let currentUser = dataController.getCurrentUser() else {
            userCanWriteReview = false
            print("📝 Review eligibility: No current user found")
            return
        }
        
        // Check if user has ANY bookings for this equipment (matching UIKit implementation)
        let userBookings = dataController.getUserBookings(userID: currentUser.userID, equipmentID: equipment.equipmentID)
        
        userCanWriteReview = !userBookings.isEmpty
        
        print("📝 Review eligibility check:")
        print("   Equipment: \(equipment.name)")
        print("   Current User ID: \(currentUser.userID)")
        print("   User bookings for this equipment: \(userBookings.count)")
        print("   Can write review: \(userCanWriteReview)")
    }
    
    // MARK: - Actions
    
    func bookEquipment() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        print("� EquipmentDetailViewModel - bookEquipment() called")
        print("   Equipment: \(equipment.name)")
        print("   Booking Source: \(bookingSource)")
        print("   Navigation Coordinator exists: \(navigationCoordinator != nil)")
        print("   Navigation Controller exists: \(navigationController != nil)")
        
        // Check if coming from co-equip view-only flow and prevent booking
        if bookingSource == .coEquipViewOnly {
            print("⚠️ Blocked: View-only mode from Co-Equip request")
            showAlert(
                title: "View Only Mode",
                message: "This equipment is being viewed from a Co-Equip request card. This is for viewing purposes only and booking is not available from this screen."
            )
            return
        }
        
        // Check if coming from co-equip search flow and prevent booking
        if bookingSource == .coEquip {
            print("⚠️ Blocked: View-only mode from Co-Equip section")
            showAlert(
                title: "View Only Mode",
                message: "This equipment is being viewed from the Co-Equip section. To book this equipment, please navigate to it from the Home tab."
            )
            return
        }
        
        // Check the booking source to determine the flow
        if bookingSource == .prebooking {
            print("➡️ Navigating directly to ReviewBooking (Prebooking flow)")
            // If coming from Prebooking tab, go directly to ReviewBooking with prebooking flow
            handleIndividualBooking()
        } else {
            print("➡️ Showing native SwiftUI booking alert (centered card)")
            // For other sources (like Home tab), show the native booking alert
            showBookingOptions = true
        }
    }
    
    /// Handle Individual Booking selection
    func handleIndividualBooking() {
        print("📝 User selected: Book as Individual")
        
        // Use SwiftUI navigation if available, fallback to coordinator
        if navigationCoordinator != nil {
            // UIKit flow - use existing coordinator
            performNavigationToReviewBooking()
        } else {
            // Pure SwiftUI flow - set navigation state
            navigateToReviewBooking = true
        }
    }
    
    /// Handle Co-Equip Booking selection
    func handleCoEquipBooking() {
        print("🤝 User selected: Book with Co-Equip")
        
        // Use router to navigate to CreateCoEquipGroupView
        router?.navigate(to: CoEquipDestination.createGroup(equipment))
    }
    
    // MARK: - Legacy UIKit Navigation (Deprecated - Keep for backward compatibility)
    
    private func showLegacyBookingOptionsAlert() {
        guard let topViewController = navigationController?.topViewController else {
            print("❌ showLegacyBookingOptionsAlert: No top view controller found")
            print("   Navigation Controller: \(navigationController != nil ? "exists" : "nil")")
            // Fallback to SwiftUI navigation
            showBookingOptions = true
            return
        }
        
        print("✅ Showing booking options alert (Legacy UIKit)")
        
        let alertController = UIAlertController(
            title: "Choose Your Booking Type",
            message: "Book individually or join with nearby farmers for reduced costs.",
            preferredStyle: .alert
        )
        
        let individualAction = UIAlertAction(title: "Book as Individual", style: .default) { [weak self] _ in
            print("📝 User selected: Book as Individual")
            self?.handleIndividualBooking()
        }
        
        let coEquipAction = UIAlertAction(title: "Book with Co-Equip", style: .default) { [weak self] _ in
            print("🤝 User selected: Book with Co-Equip")
            self?.handleCoEquipBooking()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("❌ User cancelled booking")
        }
        
        // Set action colors to iKisan green following HIG
        let ikisanGreen = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        individualAction.setValue(ikisanGreen, forKey: "titleTextColor")
        coEquipAction.setValue(ikisanGreen, forKey: "titleTextColor")
        cancelAction.setValue(ikisanGreen, forKey: "titleTextColor")
        
        alertController.addAction(individualAction)
        alertController.addAction(coEquipAction)
        alertController.addAction(cancelAction)
        
        topViewController.present(alertController, animated: true) {
            print("✅ Booking options alert presented successfully")
        }
    }
    
    private func performNavigationToReviewBooking() {
        print("🔄 Navigating to Review Booking via coordinator")
        print("   Equipment: \(equipment.name)")
        print("   Booking Source: \(bookingSource)")
        
        guard let coordinator = navigationCoordinator else {
            print("❌ Navigation coordinator is nil!")
            return
        }
        
        print("✅ Calling navigationCoordinator.navigateToReviewBooking()")
        coordinator.navigateToReviewBooking(
            equipment: equipment,
            bookingSource: bookingSource
        )
    }
    
    private func navigateToCoEquipBooking() {
        print("🔄 Navigating to Co-Equip Booking")
        print("   Equipment: \(equipment.name)")
        
        guard let navigationController = navigationController,
              let topViewController = navigationController.topViewController else {
            print("❌ No navigation controller or top view controller found")
            return
        }
        
        let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
            // Pass the equipment data
            viewController.cardData = equipment
            // Set the data controller if needed
            if let dataController = dataController {
                viewController.dataController = dataController
            }
            print("✅ Pushing InfoTableViewController to navigation stack")
            navigationController.pushViewController(viewController, animated: true)
        } else {
            print("❌ Failed to instantiate InfoTableViewController")
        }
    }
    
    private func showAlert(title: String, message: String) {
        guard let topViewController = navigationController?.topViewController else {
            print("❌ No top view controller found")
            return
        }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topViewController.present(alert, animated: true)
    }
    
    private var navigationController: UINavigationController? {
        // Helper to get navigation controller from the coordinator
        return (navigationCoordinator as? UIKitHomeNavigationCoordinator)?.navigationController
    }
    
    func writeReview() {
        // Haptic feedback following HIG
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        print("✍️ EquipmentDetailViewModel - writeReview() called")
        print("   Equipment: \(equipment.name)")
        print("   User can write review: \(userCanWriteReview)")
        print("   Navigation Coordinator exists: \(navigationCoordinator != nil)")
        
        // Use a slight delay to ensure smooth UI transition
        // This prevents any visual glitches when presenting alerts/modals
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Navigate to review writing screen with callback
            self.navigationCoordinator?.navigateToWriteReview(
                equipment: self.equipment,
                canUserWriteReview: self.userCanWriteReview
            ) { [weak self] newReview in
                guard let self = self else { return }
                print("📝 New review received from WriteReviewViewController")
                // Add new review to the list
                self.reviews.append(newReview)
                self.filteredReviews.append(newReview)
                // Reload reviews to update UI
                self.loadReviews()
            }
        }
    }
    
    func showAllReviews() {
        // Haptic feedback following HIG
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        print("📋 EquipmentDetailViewModel - showAllReviews() called")
        print("   Equipment: \(equipment.name)")
        print("   Total reviews: \(filteredReviews.count)")
        print("   Navigation Coordinator exists: \(navigationCoordinator != nil)")
        
        guard !filteredReviews.isEmpty else {
            print("⚠️ No reviews to show")
            return
        }
        
        navigationCoordinator?.navigateToAllReviews(
            equipment: equipment,
            reviews: filteredReviews
        )
    }
    
    func showAllPhotos() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        showingImageGallery = true
        selectedImageIndex = 0
    }
    
    func selectImage(at index: Int) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        selectedImageIndex = index
        showingImageGallery = true
    }
    
    func openLocationInMaps() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        print("🗺️ Opening location in Maps: \(equipment.location)")
        
        // Create a geocoding request for the location
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(equipment.location) { placemarks, error in
            if let error = error {
                print("❌ Geocoding error: \(error.localizedDescription)")
                // Fallback: Open Maps with search query
                self.openMapsWithSearchQuery()
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                // Open Maps with coordinate
                self.openMapsWithCoordinate(location.coordinate, name: self.equipment.location)
            } else {
                // Fallback: Open Maps with search query
                self.openMapsWithSearchQuery()
            }
        }
    }
    
    private func openMapsWithCoordinate(_ coordinate: CLLocationCoordinate2D, name: String) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    private func openMapsWithSearchQuery() {
        let searchQuery = equipment.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(searchQuery)") {
            UIApplication.shared.open(url)
        }
    }
}
