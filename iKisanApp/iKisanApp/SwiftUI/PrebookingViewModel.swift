//
//  PrebookingViewModel.swift
//  iKisanApp
//
//  Created on 30/12/25.
//

import SwiftUI
import Combine

@MainActor
class PrebookingViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var recommendedEquipments: [Equipment] = []
    @Published var availableEquipments: [Equipment] = []
    @Published var searchedEquipments: [Equipment] = []
    @Published var allEquipments: [Equipment] = []
    @Published var faqs: [FAQ] = []
    @Published var preBookings: [Booking] = []
    @Published var preBookingEquipments: [Equipment] = []
    @Published var prebookingDates: [Date] = []
    @Published var selectedFAQ: FAQ?
    @Published var selectedDate: Date?
    @Published var hasAddPreBook: Bool = false
    @Published var isLoading: Bool = false
    @Published var searchSuggestions: [Equipment] = []
    
    // MARK: - Public Properties
    
    let dataController: DataController // Changed from private to public
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var groupedEquipments: [String: [Equipment]] = [:]
    private var groupedSearchResults: [String: [Equipment]] = [:]
    
    // MARK: - Computed Properties
    
    var availableEquipmentTitle: String {
        guard let firstEquipment = availableEquipments.first else {
            return "Available Equipment"
        }
        return "Available \(firstEquipment.name)"
    }
    
    // MARK: - Initialization
    
    init(dataController: DataController) {
        self.dataController = dataController
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() {
        recommendedEquipments = dataController.getRecommendedEquipments()
        faqs = dataController.getPreBookingFAQs()
        
        print("🔵 PrebookingView - loadInitialData called")
        print("📊 Recommended: \(recommendedEquipments.count), FAQs: \(faqs.count)")
        
        Task {
            await loadAllEquipment()
            await loadPreBookings()
            
            print("📊 After loading - PreBookings: \(preBookings.count), Equipment: \(preBookingEquipments.count)")
        }
    }
    
    func refreshData() async {
        isLoading = true
        await loadAllEquipment()
        await loadPreBookings()
        isLoading = false
    }
    
    func updateSearchSuggestions(query: String) {
        guard !query.isEmpty else {
            searchSuggestions = []
            return
        }
        
        // Search through all equipment
        let matchingEquipments = allEquipments.filter { equipment in
            equipment.name.localizedCaseInsensitiveContains(query) ||
            equipment.type.localizedCaseInsensitiveContains(query) ||
            (equipment.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
        
        // Group by name and show only one representative per group
        let grouped = groupEquipmentByName(matchingEquipments)
        searchSuggestions = getRepresentativeEquipment(from: grouped)
    }
    
    func selectSearchResult(_ equipment: Equipment) {
        // Get all equipment with the same name
        let grouped = groupEquipmentByName(allEquipments)
        searchedEquipments = grouped[equipment.name] ?? [equipment]
        groupedSearchResults = grouped
        
        print("Search selection: \(equipment.name), found \(searchedEquipments.count) equipment entities")
        
        // Clear search suggestions
        searchSuggestions = []
        
        // Reset state
        hasAddPreBook = false
        availableEquipments = []
        selectedDate = nil
    }
    
    func performSearch(query: String) {
        guard !query.isEmpty else {
            clearSearch()
            return
        }
        
        // Search through all equipment
        let matchingEquipments = allEquipments.filter { equipment in
            equipment.name.localizedCaseInsensitiveContains(query) ||
            equipment.type.localizedCaseInsensitiveContains(query) ||
            (equipment.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
        
        // Group by name and get all equipment in matching groups
        let grouped = groupEquipmentByName(matchingEquipments)
        searchedEquipments = Array(grouped.values.flatMap { $0 })
        groupedSearchResults = grouped
        
        // Update UI state
        hasAddPreBook = false
        availableEquipments = []
        searchSuggestions = []
    }
    
    func clearSearch() {
        searchedEquipments = []
        groupedSearchResults = [:]
        hasAddPreBook = false
        availableEquipments = []
        selectedDate = nil
        searchSuggestions = []
    }
    
    func handleDateSelection(_ date: Date) {
        selectedDate = date
        
        // Check if this is a prebooking date
        let startOfDay = Calendar.current.startOfDay(for: date)
        let hasPreBooking = prebookingDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: startOfDay) })
        
        if hasPreBooking {
            // Scroll to prebooking section (handled by view)
            return
        }
        
        // Check for available equipment
        let availableForDate = searchedEquipments.filter { equipment in
            equipment.isAvailable(on: date)
        }
        
        if !availableForDate.isEmpty {
            availableEquipments = availableForDate
            hasAddPreBook = true
        } else {
            availableEquipments = []
            hasAddPreBook = false
        }
    }
    
    func selectEquipment(_ equipment: Equipment) {
        // Navigate to equipment detail or booking
        // This will be handled by navigation in the view
    }
    
    func preBookEquipment(_ equipment: Equipment) {
        // Navigate to review booking screen
        // This will be handled by navigation in the view
    }
    
    func modifyBooking(_ booking: Booking, equipment: Equipment) {
        // Set modification state - this will be used by the view to navigate
        // The view will pass this booking to ReviewBookingView for modification
    }
    
    func cancelBooking(_ booking: Booking, equipment: Equipment) {
        // This will be handled by the view with proper alerts
        // The view will call cancelBookingConfirmed after user confirmation
    }
    
    func cancelBookingConfirmed(_ booking: Booking) {
        Task {
            var deletionSuccessful = false
            var errorMessage = "An unknown error occurred while canceling your booking."
            
            do {
                // Delete the booking record completely
                let response = try await SupabaseManager.shared.client
                    .from("bookings")
                    .delete()
                    .eq("bookingID", value: booking.bookingID.uuidString)
                    .execute()
                
                // Check if the deletion was successful by verifying the response
                let data = response.data
                if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   !jsonArray.isEmpty {
                    // If we got a non-empty response, the deletion was successful
                    deletionSuccessful = true
                    print("Booking deletion successful with response: \(jsonArray)")
                } else {
                    // Empty response might indicate no records were found/deleted
                    errorMessage = "Could not find the booking to cancel. It may have already been removed."
                    print("Booking deletion returned empty response - no records found/deleted")
                }
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                print("Error during booking deletion API call: \(error)")
            }
            
            // Update UI based on result
            if deletionSuccessful {
                // Refresh bookings
                await loadPreBookings()
                
                // Post notification for success
                NotificationCenter.default.post(
                    name: NSNotification.Name("RefreshBookingsList"),
                    object: nil
                )
                
                // Post notification with success status
                NotificationCenter.default.post(
                    name: NSNotification.Name("BookingCancellationComplete"),
                    object: nil,
                    userInfo: ["success": true]
                )
            } else {
                // Post notification with error
                NotificationCenter.default.post(
                    name: NSNotification.Name("BookingCancellationComplete"),
                    object: nil,
                    userInfo: ["success": false, "error": errorMessage]
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadAllEquipment() async {
        do {
            let equipments: [Equipment] = try await SupabaseManager.shared.client
                .from("equipment")
                .select("*")
                .execute()
                .value
            
            allEquipments = equipments
            
            // Update last fetch time
            UserDefaults.standard.set(Date(), forKey: "lastEquipmentFetchTime")
        } catch {
            print("Error loading equipment: \(error)")
        }
    }
    
    private func loadPreBookings() async {
        // Get user ID from session
        guard let session = try? await SupabaseManager.shared.client.auth.session,
              let userID = UUID(uuidString: session.user.id.uuidString) else {
            print("❌ Could not get user session for loading prebookings")
            return
        }
        
        do {
            // Fetch all bookings for the user (don't filter by type in query)
            let bookings: [Booking] = try await SupabaseManager.shared.client
                .from("bookings")
                .select("*")
                .eq("userID", value: userID.uuidString)
                .execute()
                .value
            
            print("📦 Fetched \(bookings.count) total bookings from Supabase")
            
            // Filter prebookings locally (matching UIKit implementation exactly)
            preBookings = bookings.filter { booking in
                let isPrebooking = booking.bookingType == .prebooking && booking.source == .prebooking
                let isActiveStatus = booking.status == .pending || booking.status == .confirmed
                return isPrebooking && isActiveStatus
            }
            
            print("✅ Filtered to \(preBookings.count) active prebookings")
            
            // Get equipment for each booking
            preBookingEquipments = preBookings.compactMap { booking in
                let equipment = dataController.getEquipment(byId: booking.equipmentID)
                if equipment == nil {
                    print("⚠️ Could not find equipment with ID: \(booking.equipmentID)")
                }
                return equipment
            }
            
            print("✅ Loaded \(preBookingEquipments.count) equipment items for prebookings")
            
            // Extract prebooking dates
            prebookingDates = preBookings.map { Calendar.current.startOfDay(for: $0.bookingDate) }
            
            print("📅 Prebooking dates: \(prebookingDates)")
            
        } catch {
            print("❌ Error loading prebookings: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: NSNotification.Name("preBookingAdded"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.loadPreBookings()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("RefreshBookingsList"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.loadPreBookings()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func groupEquipmentByName(_ equipments: [Equipment]) -> [String: [Equipment]] {
        Dictionary(grouping: equipments) { $0.name }
    }
    
    private func getRepresentativeEquipment(from groupedEquipments: [String: [Equipment]]) -> [Equipment] {
        groupedEquipments.compactMap { _, equipments in
            equipments.first
        }
    }
}
