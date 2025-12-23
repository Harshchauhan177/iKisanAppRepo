//
//  UpcomingBookingsListViewModel.swift
//  iKisanApp
//
//  SwiftUI ViewModel for Upcoming Bookings List Screen
//

import Foundation
import Combine

// MARK: - Booking Filter Enum
enum BookingFilter: String, CaseIterable {
    case upcoming = "Upcoming"
    case completed = "Completed"
}

@MainActor
class UpcomingBookingsListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedFilter: BookingFilter = .upcoming
    @Published var upcomingBookings: [Booking] = []
    @Published var completedBookings: [Booking] = []
    @Published var allEquipment: [Equipment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    // MARK: - Computed Properties
    var displayedBookings: [Booking] {
        switch selectedFilter {
        case .upcoming:
            return upcomingBookings
        case .completed:
            return completedBookings
        }
    }
    
    var hasBookings: Bool {
        !displayedBookings.isEmpty
    }
    
    // MARK: - Initialization
    init(dataController: DataController? = nil, navigationCoordinator: HomeNavigationCoordinator? = nil) {
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        
        // Register for notifications
        setupNotificationObservers()
    }
    
    // MARK: - Setup
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RefreshBookingsList"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.loadData()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("BookingCancelled"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.loadData()
            }
        }
    }
    
    // MARK: - Data Loading
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        print("🔄 UpcomingBookingsListViewModel - Starting to load data...")
        
        guard let dataController = dataController else {
            print("❌ Error: DataController is nil in UpcomingBookingsListViewModel")
            isLoading = false
            errorMessage = "Unable to load data"
            return
        }
        
        // Fetch directly from backend like UIKit version does
        let fetchedBookings = await RequestManager.shared.fetchBookings()
        let fetchedEquipment = await RequestManager.shared.fetchEquipments()
        
        print("📦 Fetched from backend: \(fetchedBookings.count) bookings, \(fetchedEquipment.count) equipment")
        
        // Store equipment
        allEquipment = fetchedEquipment
        
        // If backend fetch is empty, try dataController as fallback
        if fetchedBookings.isEmpty {
            print("⚠️ No bookings from backend, trying dataController fallback...")
            allEquipment = dataController.getAllEquipment()
            let dataControllerBookings = dataController.getUpcomingBookings()
            
            // Separate into upcoming and completed
            let today = Calendar.current.startOfDay(for: Date())
            upcomingBookings = dataControllerBookings.filter { booking in
                let bookingDate = Calendar.current.startOfDay(for: booking.bookingDate)
                return bookingDate >= today && 
                       (booking.status == .pending || booking.status == .confirmed)
            }.sorted { $0.bookingDate < $1.bookingDate }
            
            completedBookings = dataControllerBookings.filter { booking in
                booking.status == .completed
            }.sorted { $0.bookingDate > $1.bookingDate }
            
            print("📊 From dataController: \(upcomingBookings.count) upcoming, \(completedBookings.count) completed")
        } else {
            // Use backend data - separate into upcoming and completed
            let today = Calendar.current.startOfDay(for: Date())
            
            // Upcoming: future bookings with pending or confirmed status
            upcomingBookings = fetchedBookings.filter { booking in
                let bookingDate = Calendar.current.startOfDay(for: booking.bookingDate)
                let isUpcoming = bookingDate >= today
                let hasUpcomingStatus = booking.status == .pending || booking.status == .confirmed
                return isUpcoming && hasUpcomingStatus
            }.sorted { $0.bookingDate < $1.bookingDate }
            
            // Completed: bookings with completed status
            completedBookings = fetchedBookings.filter { booking in
                booking.status == .completed
            }.sorted { $0.bookingDate > $1.bookingDate } // Most recent first
            
            print("✅ From backend: \(upcomingBookings.count) upcoming, \(completedBookings.count) completed (from \(fetchedBookings.count) total)")
        }
        
        // Log bookings for debugging with booking type and source
        print("📅 Upcoming Bookings:")
        for (index, booking) in upcomingBookings.enumerated() {
            print("  \(index + 1). Equipment: \(booking.equipmentID)")
            print("      Date: \(booking.bookingDate), Status: \(booking.status)")
            print("      Type: \(booking.bookingType.rawValue), Source: \(booking.source)")
        }
        
        print("✅ Completed Bookings:")
        for (index, booking) in completedBookings.enumerated() {
            print("  \(index + 1). Equipment: \(booking.equipmentID)")
            print("      Date: \(booking.bookingDate), Status: \(booking.status)")
            print("      Type: \(booking.bookingType.rawValue), Source: \(booking.source)")
        }
        
        print("\n🔍 All Fetched Bookings Breakdown by Type:")
        let onDemandCount = fetchedBookings.filter { $0.bookingType == .onDemand }.count
        let prebookingCount = fetchedBookings.filter { $0.bookingType == .prebooking }.count
        let coEquipCount = fetchedBookings.filter { $0.bookingType == .coEquip }.count
        print("  - On-Demand: \(onDemandCount)")
        print("  - Prebooking: \(prebookingCount)")
        print("  - Co-Equip: \(coEquipCount)")
        print("  - Total: \(fetchedBookings.count)")
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    func getEquipment(for booking: Booking) -> Equipment? {
        // First try exact ID match
        if let equipment = allEquipment.first(where: { equip in
            equip.equipmentID.uuidString.lowercased() == booking.equipmentID.uuidString.lowercased()
        }) {
            return equipment
        }
        
        // Fallback: Try to find by name or other criteria
        // This handles cases where equipment might be referenced differently
        return allEquipment.first
    }
    
    // MARK: - Navigation
    func handleBookingTap(booking: Booking, equipment: Equipment) {
        print("📱 Booking tapped: \(equipment.name)")
        navigationCoordinator?.navigateToBookingDetails(booking: booking, equipment: equipment)
    }
    
    // MARK: - Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
