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
    
    func navigateToAllUpcomingBookings() {
        print("🚀 HomeNavigationCoordinator - Navigating to all upcoming bookings")
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "UpcomingBookingsListViewController") as? UpcomingBookingsListViewController else {
            print("❌ Failed to instantiate UpcomingBookingsListViewController")
            return
        }
        
        // Pass the data controller
        viewController.dataController = dataController
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func navigateToReviewBooking(equipment: Equipment, bookingSource: BookingSource) {
        print("🚀 HomeNavigationCoordinator - Navigating to review booking: \(equipment.name)")
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewBookingTableViewController") as? ReviewBookingTableViewController else {
            print("❌ Failed to instantiate ReviewBookingTableViewController")
            return
        }
        
        // Pass the equipment data
        viewController.equipment = equipment
        viewController.bookingSource = bookingSource
        
        navigationController?.pushViewController(viewController, animated: true)
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
}
