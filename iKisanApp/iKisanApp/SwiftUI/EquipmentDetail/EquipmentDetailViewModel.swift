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
    
    private let dataController: DataController?
    private var bookingSource: BookingSource
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    // MARK: - Initialization
    
    init(
        equipment: Equipment,
        bookingSource: BookingSource,
        dataController: DataController?,
        navigationCoordinator: HomeNavigationCoordinator?
    ) {
        self.equipment = equipment
        self.bookingSource = bookingSource
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        
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
        
        // Check if user has completed bookings for this equipment
        let allBookings = dataController.getUpcomingBookings()
        let completedBookings = allBookings.filter { booking in
            booking.equipmentID == equipment.equipmentID &&
            booking.status == .completed &&
            booking.bookingDate < Date()
        }
        
        userCanWriteReview = !completedBookings.isEmpty
    }
    
    // MARK: - Actions
    
    func bookEquipment() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        print("📱 Booking equipment: \(equipment.name)")
        navigationCoordinator?.navigateToReviewBooking(
            equipment: equipment,
            bookingSource: bookingSource
        )
    }
    
    func writeReview() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        print("✍️ Writing review for: \(equipment.name)")
        // Navigate to review writing screen
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
