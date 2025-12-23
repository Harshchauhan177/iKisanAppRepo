//
//  HomeNavigationCoordinator.swift
//  iKisanApp
//
//  Bridge between SwiftUI HomeView and UIKit Navigation
//

import Foundation
import UIKit
import SwiftUI

/// Protocol defining navigation actions from SwiftUI to UIKit
protocol HomeNavigationCoordinator: AnyObject {
    /// Navigate to equipment details screen
    /// - Parameters:
    ///   - equipment: The equipment to display
    ///   - bookingSource: The source context for booking flow
    func navigateToEquipmentDetails(equipment: Equipment, bookingSource: BookingSource)
    
    /// Navigate to booking details screen
    /// - Parameters:
    ///   - booking: The booking to display
    ///   - equipment: The associated equipment
    func navigateToBookingDetails(booking: Booking, equipment: Equipment)
    
    /// Navigate to all upcoming bookings list
    func navigateToAllUpcomingBookings()
    
    /// Navigate to review booking screen (for "Book Now" actions)
    /// - Parameters:
    ///   - equipment: The equipment to book
    ///   - bookingSource: The source context for booking flow
    func navigateToReviewBooking(equipment: Equipment, bookingSource: BookingSource)
    
    /// Navigate to profile screen
    func navigateToProfile()
    
    /// Navigate to search results (if needed for future enhancement)
    /// - Parameter searchQuery: The search term
    func navigateToSearchResults(searchQuery: String)
    
    /// Navigate to write review screen
    /// - Parameters:
    ///   - equipment: The equipment to review
    ///   - canUserWriteReview: Whether user is eligible to write review
    ///   - onReviewSubmitted: Callback when review is submitted
    func navigateToWriteReview(equipment: Equipment, canUserWriteReview: Bool, onReviewSubmitted: @escaping (ReviewData) -> Void)
    
    /// Navigate to all reviews screen
    /// - Parameters:
    ///   - equipment: The equipment whose reviews to display
    ///   - reviews: List of reviews to display
    func navigateToAllReviews(equipment: Equipment, reviews: [ReviewData])
}

/// Default implementation for UIKit-based navigation coordinator
class UIKitHomeNavigationCoordinator: HomeNavigationCoordinator {
    
    weak var navigationController: UINavigationController?
    weak var dataController: DataController?
    
    init(navigationController: UINavigationController?, dataController: DataController?) {
        self.navigationController = navigationController
        self.dataController = dataController
    }
    
    // MARK: - Navigation Methods
    
    @MainActor
    func navigateToEquipmentDetails(equipment: Equipment, bookingSource: BookingSource) {
        print("🚀 HomeNavigationCoordinator - Navigating to equipment details: \(equipment.name)")
        
        // Use SwiftUI EquipmentDetailView
        let viewModel = EquipmentDetailViewModel(
            equipment: equipment,
            bookingSource: bookingSource,
            dataController: dataController,
            navigationCoordinator: self
        )
        
        let detailView = EquipmentDetailView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: detailView)
        
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func navigateToBookingDetails(booking: Booking, equipment: Equipment) {
        print("🚀 HomeNavigationCoordinator - Navigating to booking details: \(booking.bookingID)")
        
        // Create BookingDetailsViewController programmatically
        let viewController = BookingDetailsViewController(equipment: equipment, booking: booking)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @MainActor
    func navigateToAllUpcomingBookings() {
        print("🚀 HomeNavigationCoordinator - Navigating to all upcoming bookings")
        
        // Use the new SwiftUI UpcomingBookingsListView
        let viewModel = UpcomingBookingsListViewModel(
            dataController: dataController,
            navigationCoordinator: self
        )
        
        let upcomingBookingsView = UpcomingBookingsListView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: upcomingBookingsView)
        
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @MainActor
    func navigateToReviewBooking(equipment: Equipment, bookingSource: BookingSource) {
        print("🚀 HomeNavigationCoordinator - Navigating to review booking: \(equipment.name)")
        
        // Ensure navigation bar is visible before pushing
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Use the new SwiftUI ReviewBookingView
        let viewModel = ReviewBookingViewModel(
            equipment: equipment,
            bookingSource: bookingSource,
            dataController: dataController,
            navigationCoordinator: self
        )
        
        let reviewBookingView = ReviewBookingView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: reviewBookingView)
        
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func navigateToProfile() {
        print("🚀 HomeNavigationCoordinator - Navigating to profile")
        
        // Use the SwiftUI ProfileView wrapped in a UIHostingController
        let profileVC = ProfileHostingController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func navigateToSearchResults(searchQuery: String) {
        print("🚀 HomeNavigationCoordinator - Search: \(searchQuery)")
        // Future enhancement: Navigate to dedicated search results screen
    }
    
    func navigateToWriteReview(equipment: Equipment, canUserWriteReview: Bool, onReviewSubmitted: @escaping (ReviewData) -> Void) {
        print("🚀 HomeNavigationCoordinator - Navigating to write review: \(equipment.name)")
        
        // Check if user can write a review before showing the review sheet
        guard let topViewController = navigationController?.topViewController else {
            print("❌ No top view controller found")
            return
        }
        
        if !canUserWriteReview {
            // Show HIG-compliant alert explaining why they can't write a review
            let alert = UIAlertController(
                title: "Booking Required",
                message: "Book this equipment to share your experience with the community.",
                preferredStyle: .alert
            )
            
            // OK action with proper completion to ensure UI is restored
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                print("✅ User acknowledged booking requirement alert")
                // Ensure view state is properly restored after dismissal
                DispatchQueue.main.async {
                    topViewController.view.setNeedsLayout()
                    topViewController.view.layoutIfNeeded()
                }
            }
            
            alert.addAction(okAction)
            
            // Present with completion handler for smooth animation
            topViewController.present(alert, animated: true) {
                print("✅ Alert presented successfully")
            }
            return
        }
        
        // Create the write review view controller
        let writeReviewVC = WriteReviewViewController()
        writeReviewVC.equipment = equipment
        writeReviewVC.dataController = dataController
        
        // Set up callback for when review is submitted
        writeReviewVC.onReviewSubmitted = onReviewSubmitted
        
        // Create a navigation controller to wrap the review view controller
        let navController = UINavigationController(rootViewController: writeReviewVC)
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            // For iOS 15+ use sheet presentation controller for better appearance
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        // Present the modal - this is a modal presentation, not a push, so navigation bar state doesn't matter
        topViewController.present(navController, animated: true)
    }
    
    func navigateToAllReviews(equipment: Equipment, reviews: [ReviewData]) {
        print("🚀 HomeNavigationCoordinator - Navigating to all reviews: \(equipment.name)")
        
        // Ensure navigation bar is visible before pushing
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Create AllReviewsViewController programmatically
        let allReviewsVC = AllReviewsViewController()
        allReviewsVC.equipment = equipment
        allReviewsVC.reviews = reviews
        
        navigationController?.pushViewController(allReviewsVC, animated: true)
    }
}
