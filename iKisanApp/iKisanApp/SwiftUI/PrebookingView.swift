//
//  PrebookingView.swift
//  iKisanApp
//
//  Created on 30/12/25.
//

import SwiftUI

struct PrebookingView: View {
    @StateObject private var viewModel: PrebookingViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedEquipmentForBooking: Equipment?
    @State private var selectedEquipmentForDetails: Equipment?
    @State private var showBookingView = false
    @State private var showEquipmentDetails = false
    @State private var showCancelConfirmation = false
    @State private var bookingToCancel: (booking: Booking, equipment: Equipment)?
    @State private var showCancellationAlert = false
    @State private var cancellationAlertTitle = ""
    @State private var cancellationAlertMessage = ""
    @State private var cancellationSuccess = false
    
    // Add state for modification
    @State private var bookingToModify: Booking?
    @State private var isModifyingBooking = false
    
    init(dataController: DataController) {
        _viewModel = StateObject(wrappedValue: PrebookingViewModel(dataController: dataController))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Content
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // Recommended Section
                        Section {
                            recommendedSection
                        } header: {
                            SectionHeaderView(title: "Recommended For You")
                        }
                        
                        // Calendar Section
                        Section {
                            calendarSection
                        } header: {
                            SectionHeaderView(title: "Select Date")
                        }
                        
                        // Available Equipment Section (conditional)
                        if viewModel.hasAddPreBook {
                            Section {
                                availableEquipmentSection
                            } header: {
                                SectionHeaderView(title: viewModel.availableEquipmentTitle)
                            }
                        }
                        
                        // Your Prebookings Section (conditional)
                        if !viewModel.preBookings.isEmpty {
                            Section {
                                yourPrebookingsSection
                            } header: {
                                SectionHeaderView(title: "Your Prebookings")
                            }
                        } else {
                            // Debug: Show why section is not appearing
                            Section {
                                VStack {
                                    Text("Debug: No prebookings found")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text("Bookings count: \(viewModel.preBookings.count)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                            } header: {
                                SectionHeaderView(title: "Debug Info")
                            }
                        }
                        
                        // FAQ Section
                        Section {
                            faqSection
                        } header: {
                            SectionHeaderView(title: "Need Help?")
                        }
                    }
                    .padding(.top, 8)
                }
                .background(Color(uiColor: .systemGroupedBackground))
                
                // Search Results Overlay
                if isSearching && !searchText.isEmpty {
                    searchResultsView
                }
            }
            .navigationTitle("Pre Booking")
            .searchable(text: $searchText, isPresented: $isSearching, prompt: "Search Equipment")
            .onChange(of: searchText) { newValue in
                if (!newValue.isEmpty) {
                    viewModel.updateSearchSuggestions(query: newValue)
                } else {
                    viewModel.clearSearch()
                }
            }
            .onSubmit(of: .search) {
                if !searchText.isEmpty {
                    viewModel.performSearch(query: searchText)
                    isSearching = false
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .onAppear {
                print("🟢 PrebookingView appeared - loading data")
                viewModel.loadInitialData()
            }
            .background(
                NavigationLink(
                    destination: equipmentDetailsView,
                    isActive: $showEquipmentDetails,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .background(
                NavigationLink(
                    destination: reviewBookingView,
                    isActive: $showBookingView,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .alert("Cancel Prebooking", isPresented: $showCancelConfirmation) {
                Button("No, Keep Booking", role: .cancel) { }
                Button("Yes, Cancel", role: .destructive) {
                    if let bookingInfo = bookingToCancel {
                        viewModel.cancelBookingConfirmed(bookingInfo.booking)
                    }
                }
            } message: {
                if let equipment = bookingToCancel?.equipment {
                    Text("Are you sure you want to cancel this prebooking for \(equipment.name)?")
                }
            }
            .alert(cancellationAlertTitle, isPresented: $showCancellationAlert) {
                if cancellationSuccess {
                    Button("OK", role: .cancel) { }
                } else {
                    Button("Try Again", role: .none) {
                        Task {
                            await viewModel.refreshData()
                        }
                    }
                    Button("OK", role: .cancel) { }
                }
            } message: {
                Text(cancellationAlertMessage)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BookingCancellationComplete"))) { notification in
                if let userInfo = notification.userInfo,
                   let success = userInfo["success"] as? Bool {
                    cancellationSuccess = success
                    if success {
                        cancellationAlertTitle = "Prebooking Cancelled"
                        cancellationAlertMessage = "Your prebooking has been successfully cancelled."
                    } else {
                        cancellationAlertTitle = "Cancellation Failed"
                        cancellationAlertMessage = userInfo["error"] as? String ?? "An error occurred while canceling your booking."
                    }
                    showCancellationAlert = true
                }
            }
        }
    }
    
    // MARK: - Equipment Details View (for recommended cards)
    
    @ViewBuilder
    private var equipmentDetailsView: some View {
        if let equipment = selectedEquipmentForDetails {
            EquipmentDetailView(
                viewModel: EquipmentDetailViewModel(
                    equipment: equipment,
                    bookingSource: .prebooking,
                    dataController: viewModel.dataController,
                    navigationCoordinator: nil,
                    onBookTapped: {
                        // When Book button is tapped in details view, navigate to booking
                        selectedEquipmentForBooking = equipment
                        showEquipmentDetails = false
                        showBookingView = true
                    }
                )
            )
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Review Booking View (for pre-book buttons)
    
    @ViewBuilder
    private var reviewBookingView: some View {
        if let equipment = selectedEquipmentForBooking {
            ReviewBookingView(
                viewModel: ReviewBookingViewModel(
                    equipment: equipment,
                    bookingSource: .prebooking,
                    dataController: viewModel.dataController,
                    navigationCoordinator: nil,
                    existingBooking: bookingToModify,
                    isModifying: isModifyingBooking,
                    selectedDate: isModifyingBooking ? bookingToModify?.bookingDate : viewModel.selectedDate
                )
            )
            .onDisappear {
                // Reset modification state when view disappears
                bookingToModify = nil
                isModifyingBooking = false
                selectedEquipmentForBooking = nil
            }
        }
    }
    
    // MARK: - Search Results View
    
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            if viewModel.searchSuggestions.isEmpty {
                Text("No equipment found")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.searchSuggestions, id: \.equipmentID) { equipment in
                    Button(action: {
                        selectSearchResult(equipment)
                    }) {
                        HStack {
                            Text(equipment.name)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color(uiColor: .systemBackground))
                }
                .listStyle(.plain)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func selectSearchResult(_ equipment: Equipment) {
        // Get all equipment with the same name
        viewModel.selectSearchResult(equipment)
        searchText = equipment.name
        isSearching = false
        
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Recommended Section
    
    private var recommendedSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.recommendedEquipments, id: \.equipmentID) { equipment in
                    RecommendedEquipmentCard(equipment: equipment)
                        .onTapGesture {
                            // Navigate to equipment details screen first
                            selectedEquipmentForDetails = equipment
                            showEquipmentDetails = true
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - Calendar Section
    
    private var calendarSection: some View {
        CalendarView(
            availableEquipments: viewModel.searchedEquipments.isEmpty ? [] : viewModel.searchedEquipments,
            prebookingDates: viewModel.prebookingDates,
            onDateSelected: { date in
                viewModel.handleDateSelection(date)
            }
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    // MARK: - Available Equipment Section
    
    private var availableEquipmentSection: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.availableEquipments, id: \.equipmentID) { equipment in
                AvailableEquipmentCard(equipment: equipment) {
                    // Navigate to booking screen
                    selectedEquipmentForBooking = equipment
                    showBookingView = true
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    // MARK: - Your Prebookings Section
    
    private var yourPrebookingsSection: some View {
        VStack(spacing: 10) {
            ForEach(Array(zip(viewModel.preBookings, viewModel.preBookingEquipments)), id: \.0.bookingID) { booking, equipment in
                PrebookingCard(
                    booking: booking,
                    equipment: equipment,
                    onModify: {
                        // Navigate to booking screen for modification
                        selectedEquipmentForBooking = equipment
                        bookingToModify = booking
                        isModifyingBooking = true
                        showBookingView = true
                    },
                    onCancel: {
                        bookingToCancel = (booking, equipment)
                        showCancelConfirmation = true
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    // MARK: - FAQ Section
    
    private var faqSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.faqs.enumerated()), id: \.element.id) { index, faq in
                FAQRow(faq: faq, isFirst: index == 0, isLast: index == viewModel.faqs.count - 1)
                    .onTapGesture {
                        viewModel.selectedFAQ = faq
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .sheet(item: $viewModel.selectedFAQ) { faq in
            FAQDetailView(faq: faq)
        }
    }
}
