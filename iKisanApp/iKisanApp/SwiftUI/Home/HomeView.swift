//
//  HomeView.swift
//  iKisanApp
//
//  SwiftUI Main Home Screen View
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingProfile = false
    @State private var selectedEquipment: Equipment?
    @State private var selectedBooking: Booking?
    @State private var showLocationPermissionAlert = false
    
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
                        showingProfile = true
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
            .sheet(isPresented: $showingProfile) {
                // Profile View (to be implemented)
                Text("Profile View")
            }
            .sheet(item: $selectedEquipment) { equipment in
                // Equipment Details View (to be implemented)
                NavigationView {
                    EquipmentDetailsPlaceholder(equipment: equipment)
                }
            }
            .sheet(item: $selectedBooking) { booking in
                // Booking Details View (to be implemented)
                NavigationView {
                    BookingDetailsPlaceholder(booking: booking)
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
                            
                            // Find and show equipment
                            if let equipment = viewModel.allEquipment.first(where: { $0.name == result }) {
                                selectedEquipment = equipment
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
                            selectedEquipment = equipment
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
                    // Navigate to all bookings
                    // TODO: Implement navigation
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
                                    selectedBooking = booking
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
                            selectedEquipment = equipment
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
                        selectedEquipment = equipment
                    }) {
                        ExploreCardView(
                            equipment: equipment,
                            averageRating: viewModel.getAverageRating(for: equipment),
                            onBookNow: {
                                selectedEquipment = equipment
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

// MARK: - Placeholder Views
private struct EquipmentDetailsPlaceholder: View {
    let equipment: Equipment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: equipment.equipmentImage)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                default:
                    Color.gray.opacity(0.3)
                }
            }
            .frame(height: 200)
            
            Text(equipment.name)
                .font(.title)
                .bold()
            
            Text("Details coming soon...")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Equipment Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .padding()
    }
}

private struct BookingDetailsPlaceholder: View {
    let booking: Booking
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Booking ID: \(booking.bookingID.uuidString)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Status: \(booking.status.rawValue)")
                .font(.title2)
                .bold()
            
            Text("Details coming soon...")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .padding()
    }
}

// Make Equipment and Booking Identifiable for sheets
extension Equipment: Identifiable {
    var id: UUID { equipmentID }
}

extension Booking: Identifiable {
    var id: UUID { bookingID }
}

// MARK: - Preview
#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
