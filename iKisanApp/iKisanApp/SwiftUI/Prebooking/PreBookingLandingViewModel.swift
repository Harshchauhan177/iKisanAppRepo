//
//  PreBookingLandingViewModel.swift
//  iKisanApp
//
//  ViewModel for the Pre Booking landing screen.
//  Binds to existing DataController for all data operations.
//  Manages search, date selection, available equipment filtering, and prebooking state.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PreBookingLandingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Search text entered by user
    @Published var searchText: String = ""
    
    /// Currently selected date on the calendar
    @Published var selectedDate: Date = Date()
    
    /// Whether a date has been explicitly selected by the user
    @Published var hasSelectedDate: Bool = false
    
    /// Recommended equipment from the backend
    @Published var recommendedEquipments: [Equipment] = []
    
    /// FAQs loaded from the backend
    @Published var faqs: [FAQ] = []
    
    /// Equipment available on the selected date (after search + date filter)
    @Published var availableEquipments: [Equipment] = []
    
    /// Equipment matching the current search term (all instances, grouped by name)
    @Published var searchedEquipments: [Equipment] = []
    
    /// Existing prebookings by the user
    @Published var preBookings: [Booking] = []
    
    /// Equipment details for each prebooking
    @Published var preBookingEquipments: [Equipment] = []
    
    /// All equipment available for search
    @Published var allEquipments: [Equipment] = []
    
    /// Search suggestions (representative equipment per name group)
    @Published var searchSuggestions: [Equipment] = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Whether to show the search suggestions overlay
    @Published var isShowingSuggestions: Bool = false
    
    /// Whether the available equipment section should be shown
    @Published var showAvailableSection: Bool = false
    
    /// User's existing booking dates (for calendar blue dots)
    @Published var userBookingDates: Set<Date> = []
    
    // MARK: - Navigation State
    
    /// Navigation state for equipment detail
    @Published var selectedEquipmentForDetail: Equipment?
    @Published var navigateToEquipmentDetail: Bool = false
    
    /// Navigation state for review booking (pre-book button)
    @Published var selectedEquipmentForBooking: Equipment?
    @Published var selectedDateForBooking: Date?
    @Published var navigateToReviewBooking: Bool = false
    
    /// Navigation state for FAQ detail
    @Published var selectedFAQ: FAQ?
    @Published var navigateToFAQDetail: Bool = false
    
    /// Navigation state for modify booking
    @Published var bookingToModify: Booking?
    @Published var equipmentForModify: Equipment?
    @Published var navigateToModifyBooking: Bool = false
    
    /// Delete confirmation
    @Published var bookingToDelete: Booking?
    @Published var showDeleteConfirmation: Bool = false
    
    // MARK: - Search Focus
    
    /// Whether the search field is actively focused
    @Published var isSearchFocused: Bool = false
    
    // MARK: - Computed Properties
    
    var hasPreBookings: Bool {
        !preBookings.isEmpty
    }
    
    var hasActiveSearch: Bool {
        !searchedEquipments.isEmpty
    }
    
    var availableSectionTitle: String {
        if let firstName = searchedEquipments.first?.name {
            return "Available \(firstName)"
        }
        return "Available Equipment"
    }
    
    // MARK: - Dependencies
    
    weak var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    // Grouped search results for quick lookup
    private var groupedSearchResults: [String: [Equipment]] = [:]
    
    // MARK: - Initialization
    
    init(dataController: DataController?, navigationCoordinator: HomeNavigationCoordinator?) {
        self.dataController = dataController
        self.navigationCoordinator = navigationCoordinator
        
        loadData()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        guard let dataController = dataController else { return }
        
        recommendedEquipments = dataController.getRecommendedEquipments()
        faqs = dataController.getPreBookingFAQs()
        allEquipments = dataController.getAllEquipment()
        
        loadPreBookings()
        loadUserBookingDates()
    }
    
    func loadPreBookings() {
        guard let dataController = dataController else { return }
        
        let allBookings = dataController.getUpcomingBookings()
        preBookings = allBookings.filter {
            $0.bookingType == .prebooking && $0.source == .prebooking
        }
        
        preBookingEquipments = preBookings.compactMap { booking in
            dataController.getEquipment(byId: booking.equipmentID)
        }
        
        // Refresh booking dates for calendar
        loadUserBookingDates()
    }
    
    /// Load all user booking dates for calendar blue dots
    private func loadUserBookingDates() {
        guard let dataController = dataController else { return }
        
        let allBookings = dataController.getUpcomingBookings()
        let calendar = Calendar.current
        userBookingDates = Set(allBookings.map { calendar.startOfDay(for: $0.bookingDate) })
    }
    
    /// Full async refresh from Supabase
    func refreshData() async {
        guard let dataController = dataController else { return }
        
        isLoading = true
        
        await dataController.refreshFAQsFromDatabase()
        await dataController.refreshBookingsFromDatabase()
        
        await MainActor.run {
            loadData()
            
            // If there's an active search, reapply it
            if hasActiveSearch {
                updateAvailableEquipment()
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Search Logic
    
    /// Updates search suggestions as the user types
    func updateSearchSuggestions() {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard !query.isEmpty else {
            searchSuggestions = []
            isShowingSuggestions = false
            return
        }
        
        // If we have few equipment items, try to reload
        if allEquipments.count < 5 {
            if let dc = dataController {
                allEquipments = dc.getAllEquipment()
            }
        }
        
        // Comprehensive search across all equipment fields
        let matchingEquipments = allEquipments.filter { equipment in
            equipment.name.lowercased().contains(query) ||
            equipment.type.lowercased().contains(query) ||
            equipment.description?.lowercased().contains(query) == true ||
            equipment.location.lowercased().contains(query)
        }
        
        // Group by name and show only one representative per group
        let grouped = Dictionary(grouping: matchingEquipments) { $0.name }
        groupedSearchResults = grouped
        
        searchSuggestions = Array(grouped.keys).sorted().compactMap { name in
            grouped[name]?.first
        }
        
        isShowingSuggestions = !searchSuggestions.isEmpty
    }
    
    /// Called when user selects a search suggestion
    func selectSearchSuggestion(_ equipment: Equipment) {
        // Select the entire group of equipment with the same name
        searchedEquipments = groupedSearchResults[equipment.name] ?? [equipment]
        searchText = equipment.name
        isShowingSuggestions = false
        isSearchFocused = false
        
        // Reset availability state
        showAvailableSection = false
        availableEquipments = []
        hasSelectedDate = false
        
        // Immediately check availability for currently selected date
        updateAvailableEquipment()
        
        print("Search selection: \(equipment.name), found \(searchedEquipments.count) equipment entities")
    }
    
    /// Called when user submits search via keyboard
    func submitSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        
        let rawResults = dataController?.searchEquipment(query: query) ?? []
        let grouped = Dictionary(grouping: rawResults) { $0.name }
        groupedSearchResults = grouped
        
        searchedEquipments = Array(grouped.values.flatMap { $0 })
        isShowingSuggestions = false
        isSearchFocused = false
        
        // Reset availability state
        showAvailableSection = false
        availableEquipments = []
        hasSelectedDate = false
        
        // Immediately check availability for currently selected date
        updateAvailableEquipment()
        
        print("Search submitted: Found \(searchedEquipments.count) equipments for query: \(query)")
    }
    
    /// Clears search state
    func clearSearch() {
        searchText = ""
        searchedEquipments = []
        searchSuggestions = []
        groupedSearchResults = [:]
        isShowingSuggestions = false
        showAvailableSection = false
        availableEquipments = []
        hasSelectedDate = false
    }
    
    // MARK: - Date Selection
    
    /// Called when the user selects a date on the calendar
    func onDateSelected(_ date: Date) {
        selectedDate = date
        hasSelectedDate = true
        updateAvailableEquipment()
    }
    
    /// Filters searched equipment by availability on selected date
    private func updateAvailableEquipment() {
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
        
        guard selectedDay >= today, hasActiveSearch else {
            showAvailableSection = false
            availableEquipments = []
            return
        }
        
        availableEquipments = searchedEquipments.filter { equipment in
            equipment.isAvailable(on: selectedDate)
        }
        
        showAvailableSection = !availableEquipments.isEmpty
    }
    
    // MARK: - Navigation Actions
    
    /// Navigate to equipment detail
    func showEquipmentDetail(_ equipment: Equipment) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        selectedEquipmentForDetail = equipment
        navigateToEquipmentDetail = true
    }
    
    /// Navigate to review booking (Pre Book button tap)
    func preBookEquipment(_ equipment: Equipment) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        selectedEquipmentForBooking = equipment
        selectedDateForBooking = selectedDate
        navigateToReviewBooking = true
    }
    
    /// Navigate to FAQ detail
    func showFAQDetail(_ faq: FAQ) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        selectedFAQ = faq
        navigateToFAQDetail = true
    }
    
    // MARK: - Modify / Delete Actions
    
    /// Navigate to modify a prebooking (reuses ReviewBookingView with isModifying flag)
    func modifyPreBooking(_ booking: Booking, equipment: Equipment) {
        guard booking.status != .confirmed && booking.status != .completed else {
            print("Cannot modify confirmed/completed booking")
            return
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        bookingToModify = booking
        equipmentForModify = equipment
        navigateToModifyBooking = true
    }
    
    /// Show delete confirmation for a prebooking
    func confirmDeletePreBooking(_ booking: Booking) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        bookingToDelete = booking
        showDeleteConfirmation = true
    }
    
    /// Execute the deletion after user confirms
    func executeDeletePreBooking() {
        guard let booking = bookingToDelete,
              let dataController = dataController else { return }
        
        // Update booking status to completed (effectively deleting it)
        var updatedBooking = booking
        updatedBooking.status = .completed
        dataController.updateBooking(updatedBooking)
        
        // Refresh
        loadPreBookings()
        
        // Reset state
        bookingToDelete = nil
        showDeleteConfirmation = false
        
        print("Deleted prebooking: \(booking.bookingID)")
    }
    
    // MARK: - Notification Handling
    
    func handlePreBookingAdded() {
        loadPreBookings()
    }
}
