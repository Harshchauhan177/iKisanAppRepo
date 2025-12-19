//
//  HomeView.swift
//  iKisanApp
//
//  SwiftUI Main Home Screen View
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showingProfile = false
    @State private var showLocationPermissionAlert = false
    
    // Remove SwiftUI navigation states - we're using UIKit navigation now
    // @State private var selectedEquipment: Equipment?
    // @State private var selectedBooking: Booking?
    
    // MARK: - Initializer
    
    /// Initialize with optional pre-configured ViewModel for dependency injection
    init(viewModel: HomeViewModel? = nil) {
        if let viewModel = viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: HomeViewModel())
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    // Loading State
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(Color(red: 0.298, green: 0.498, blue: 0.345))
                } else {
                    // Main Content
                    ScrollView {
                        LazyVStack(spacing: 24, pinnedViews: []) {
                            // Search Bar
                            searchSection
                                .padding(.top, 4)
                            
                            // Discounts Section
                            if !viewModel.discountedEquipment.isEmpty {
                                discountsSection
                            }
                            
                            // Upcoming Bookings Section (conditional)
                            if viewModel.hasUpcomingBookings {
                                upcomingBookingsSection
                            }
                            
                            // Suggestions Section
                            if !viewModel.suggestions.isEmpty {
                                suggestionsSection
                            }
                            
                            // Recent & Recommended Section
                            exploreSection
                        }
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                }
            }
            .navigationTitle("iKisan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Use navigation coordinator instead of sheet
                        viewModel.navigationCoordinator?.navigateToProfile()
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if let location = viewModel.userLocation {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                            Text(location)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .alert("Improve Your Experience", isPresented: $showLocationPermissionAlert) {
                Button("Not Now", role: .cancel) {}
                Button("Allow") {
                    viewModel.requestLocationPermission()
                }
            } message: {
                Text("iKisan works best with your location to find nearby equipment and provide personalized recommendations. Would you like to share your location?")
            }
            .task {
                await viewModel.loadData()
                
                // Show location permission alert if needed
                if AuthManager.shared.isLoggedIn && !UserDefaults.standard.bool(forKey: "didRequestLocationPermission") {
                    showLocationPermissionAlert = true
                }
            }
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Search equipment", text: $viewModel.searchText)
                    .font(.system(size: 16))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            
            // Search Results
            if viewModel.isSearching && !viewModel.filteredSearchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(viewModel.filteredSearchResults.prefix(5), id: \.self) { result in
                        Button(action: {
                            viewModel.selectSearchResult(result)
                            
                            // Find and navigate to equipment using coordinator
                            if let equipment = viewModel.allEquipment.first(where: { $0.name == result }) {
                                viewModel.navigationCoordinator?.navigateToEquipmentDetails(
                                    equipment: equipment,
                                    bookingSource: .home
                                )
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Text(result)
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.left")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if result != viewModel.filteredSearchResults.prefix(5).last {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Discounts Section
    private var discountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Discounts")
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.discountedEquipment, id: \.equipmentID) { equipment in
                        Button(action: {
                            // Use navigation coordinator to navigate to equipment details
                            viewModel.navigationCoordinator?.navigateToEquipmentDetails(
                                equipment: equipment,
                                bookingSource: .home
                            )
                        }) {
                            DiscountCardView(
                                equipment: equipment,
                                averageRating: viewModel.getAverageRating(for: equipment)
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Upcoming Bookings Section
    private var upcomingBookingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Upcoming Bookings",
                showViewAll: true,
                onViewAllTapped: {
                    // Use navigation coordinator to navigate to all bookings
                    viewModel.navigationCoordinator?.navigateToAllUpcomingBookings()
                }
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.upcomingBookings, id: \.bookingID) { booking in
                        if let equipment = viewModel.getEquipment(for: booking) {
                            BookingCardView(
                                booking: booking,
                                equipment: equipment,
                                onViewTapped: {
                                    // Use navigation coordinator
                                    viewModel.navigationCoordinator?.navigateToBookingDetails(
                                        booking: booking,
                                        equipment: equipment
                                    )
                                }
                            )
                            .frame(width: UIScreen.main.bounds.width - 32)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Suggestions Section
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Suggestions")
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.suggestions, id: \.equipmentID) { equipment in
                        Button(action: {
                            // Use navigation coordinator
                            viewModel.navigationCoordinator?.navigateToEquipmentDetails(
                                equipment: equipment,
                                bookingSource: .home
                            )
                        }) {
                            SuggestionCardView(equipment: equipment)
                                .frame(width: UIScreen.main.bounds.width - 32)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Explore Section
    private var exploreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Recent & Recommended")
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(viewModel.exploreEquipment, id: \.equipmentID) { equipment in
                    Button(action: {
                        // Use navigation coordinator for card tap
                        viewModel.navigationCoordinator?.navigateToEquipmentDetails(
                            equipment: equipment,
                            bookingSource: .home
                        )
                    }) {
                        ExploreCardView(
                            equipment: equipment,
                            averageRating: viewModel.getAverageRating(for: equipment),
                            onBookNow: {
                                // Use navigation coordinator for "Book Now" button
                                viewModel.navigationCoordinator?.navigateToReviewBooking(
                                    equipment: equipment,
                                    bookingSource: .home
                                )
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Preview
#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
