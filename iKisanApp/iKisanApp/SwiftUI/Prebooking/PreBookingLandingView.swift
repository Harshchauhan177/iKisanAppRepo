//
//  PreBookingLandingView.swift
//  iKisanApp
//
//  SwiftUI Pre Booking landing screen.
//  Replaces PrebookingViewController with clean MVVM architecture.
//  Sections: Search (pinned), Recommended, Calendar (with colored dots),
//            Available Equipment, Your Prebookings (Modify/Delete), FAQ.
//

import SwiftUI

struct PreBookingLandingView: View {
    @StateObject var viewModel: PreBookingLandingViewModel
    
    // Dummy router for EquipmentDetailView's @EnvironmentObject requirement
    @StateObject private var router = CoEquipNavigationRouter()
    
    // Search focus state
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Pinned Search Bar (always visible)
                    searchBarSection
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 6)
                        .background(
                            Color(.systemGroupedBackground)
                                .ignoresSafeArea(edges: .top)
                        )
                    
                    // Active search chip (pinned below search bar)
                    if viewModel.hasActiveSearch {
                        activeSearchChip
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                            .background(Color(.systemGroupedBackground))
                    }
                    
                    // MARK: - Scrollable Content
                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: - Recommended Section
                            recommendedSection
                            
                            // MARK: - Select Date Section (calendar with dots)
                            calendarSection
                                .padding(.horizontal, 16)
                            
                            // MARK: - Available Equipment Section (conditional)
                            if viewModel.showAvailableSection {
                                availableEquipmentSection
                            }
                            
                            // MARK: - Your Prebookings Section (conditional)
                            if viewModel.hasPreBookings {
                                yourPrebookingsSection
                            }
                            
                            // MARK: - FAQ Section
                            faqSection
                            
                            // Bottom padding for tab bar
                            Spacer()
                                .frame(height: 20)
                        }
                        .padding(.top, 4)
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
                
                // MARK: - Search Suggestions Overlay
                if viewModel.isShowingSuggestions {
                    searchSuggestionsOverlay
                }
            }
            .navigationTitle("Pre Booking")
            .navigationBarTitleDisplayMode(.large)
            // MARK: - Navigation Destinations
            .navigationDestination(isPresented: $viewModel.navigateToEquipmentDetail) {
                if let equipment = viewModel.selectedEquipmentForDetail {
                    EquipmentDetailView(
                        viewModel: EquipmentDetailViewModel(
                            equipment: equipment,
                            bookingSource: .prebooking,
                            dataController: viewModel.dataController,
                            navigationCoordinator: viewModel.navigationCoordinator
                        )
                    )
                    .environmentObject(router)
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToReviewBooking) {
                if let equipment = viewModel.selectedEquipmentForBooking {
                    ReviewBookingView(
                        viewModel: ReviewBookingViewModel(
                            equipment: equipment,
                            bookingSource: .prebooking,
                            dataController: viewModel.dataController,
                            navigationCoordinator: viewModel.navigationCoordinator,
                            preselectedDate: viewModel.selectedDate
                        )
                    )
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToModifyBooking) {
                if let booking = viewModel.bookingToModify,
                   let equipment = viewModel.equipmentForModify {
                    ReviewBookingView(
                        viewModel: ReviewBookingViewModel(
                            equipment: equipment,
                            bookingSource: .prebooking,
                            dataController: viewModel.dataController,
                            navigationCoordinator: viewModel.navigationCoordinator,
                            existingBooking: booking,
                            isModifying: true
                        )
                    )
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToFAQDetail) {
                if let faq = viewModel.selectedFAQ {
                    FAQDetailView(faq: faq)
                }
            }
            // MARK: - Delete Confirmation Alert
            .alert("Delete Prebooking", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.bookingToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    viewModel.executeDeletePreBooking()
                }
            } message: {
                Text("Are you sure you want to delete this prebooking? This action cannot be undone.")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .preBookingAdded)) { _ in
            viewModel.handlePreBookingAdded()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshBookingsList"))) { _ in
            viewModel.loadPreBookings()
        }
        .onChange(of: isSearchFieldFocused) { focused in
            viewModel.isSearchFocused = focused
            if !focused {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if !self.viewModel.isSearchFocused {
                        self.viewModel.isShowingSuggestions = false
                    }
                }
            }
        }
    }
    
    // MARK: - Search Bar (Pinned, HIG style)
    
    private var searchBarSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(.placeholderText))
            
            TextField("Search Equipment", text: $viewModel.searchText)
                .font(.body)
                .foregroundColor(.primary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .focused($isSearchFieldFocused)
                .onSubmit {
                    viewModel.submitSearch()
                }
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.updateSearchSuggestions()
                }
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundColor(Color(.placeholderText))
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.tertiarySystemFill))
        )
    }
    
    // MARK: - Active Search Chip
    
    private var activeSearchChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.ikisanGreen)
            
            Text("Showing results for \"\(viewModel.searchText)\"")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                viewModel.clearSearch()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel("Clear search filter")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.ikisanGreen.opacity(0.08))
        )
    }
    
    // MARK: - Search Suggestions Overlay
    
    private var searchSuggestionsOverlay: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Offset: nav bar height (~96) + search bar (~44) + chip if shown
                let topOffset: CGFloat = viewModel.hasActiveSearch ? 90 : 52
                
                Color.clear
                    .frame(height: topOffset)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.searchSuggestions, id: \.equipmentID) { equipment in
                            Button(action: {
                                viewModel.selectSearchSuggestion(equipment)
                                isSearchFieldFocused = false
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(equipment.name)
                                            .font(.system(size: 16))
                                            .foregroundColor(.primary)
                                        
                                        Text(equipment.type)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.left")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(.tertiaryLabel))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if equipment.equipmentID != viewModel.searchSuggestions.last?.equipmentID {
                                Divider()
                                    .padding(.leading, 44)
                            }
                        }
                    }
                }
                .frame(maxHeight: min(CGFloat(viewModel.searchSuggestions.count) * 52, 260))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .background(
            Color.black.opacity(0.001)
                .onTapGesture {
                    viewModel.isShowingSuggestions = false
                    isSearchFieldFocused = false
                }
                .ignoresSafeArea()
        )
        .zIndex(100)
    }
    
    // MARK: - Recommended Section
    
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            if viewModel.recommendedEquipments.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                        Text("No recommendations yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                    Spacer()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.recommendedEquipments, id: \.equipmentID) { equipment in
                            RecommendedEquipmentCard(equipment: equipment)
                                .frame(width: UIScreen.main.bounds.width * 0.82)
                                .clipped()
                                .clipShape(RoundedRectangle (cornerRadius: 12, style: .continuous))
                                .onTapGesture {
                                    viewModel.showEquipmentDetail(equipment)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    // MARK: - Calendar Section (UICalendarView with colored dots)
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Date")
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                PreBookingCalendarView(
                    searchedEquipments: viewModel.searchedEquipments,
                    bookingDates: viewModel.userBookingDates,
                    selectedDate: $viewModel.selectedDate,
                    onDateSelected: { date in
                        viewModel.onDateSelected(date)
                    }
                )
                .padding(.horizontal, 4)
                
                // Legend (inside card, below calendar)
                if viewModel.hasActiveSearch || !viewModel.userBookingDates.isEmpty {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack(spacing: 20) {
                        Spacer()
                        legendItem(color: Color.ikisanGreen, label: "Available")
                        legendItem(color: .blue, label: "Booked")
                        legendItem(color: .purple, label: "Both")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                
                // Hint text
                if viewModel.hasActiveSearch {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(Color.ikisanGreen)
                        
                        Text("Tap a date to see available \(viewModel.searchedEquipments.first?.name ?? "equipment")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("Search for equipment, then select a date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.3), lineWidth: 1 / UIScreen.main.scale)
            )
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Available Equipment Section
    
    private var availableEquipmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.availableSectionTitle)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            LazyVStack(spacing: 10) {
                ForEach(viewModel.availableEquipments, id: \.equipmentID) { equipment in
                    PreBookingEquipmentCard(
                        equipment: equipment,
                        onPreBook: {
                            viewModel.preBookEquipment(equipment)
                        },
                        onCardTap: {
                            viewModel.showEquipmentDetail(equipment)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showAvailableSection)
    }
    
    // MARK: - Your Prebookings Section (Modify / Delete)
    
    private var yourPrebookingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Prebookings")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(zip(viewModel.preBookings.indices, viewModel.preBookings)), id: \.0) { index, booking in
                    if index < viewModel.preBookingEquipments.count {
                        YourPrebookingCard(
                            booking: booking,
                            equipment: viewModel.preBookingEquipments[index],
                            onModify: {
                                viewModel.modifyPreBooking(booking, equipment: viewModel.preBookingEquipments[index])
                            },
                            onDelete: {
                                viewModel.confirmDeletePreBooking(booking)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - FAQ Section
    
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FAQ")
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            if viewModel.faqs.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                        Text("No FAQs available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 30)
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.faqs.enumerated()), id: \.element.id) { index, faq in
                        FAQCardView(
                            faq: faq,
                            isFirst: index == 0,
                            isLast: index == viewModel.faqs.count - 1,
                            onTap: {
                                viewModel.showFAQDetail(faq)
                            }
                        )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct PreBookingLandingView_Previews: PreviewProvider {
    static var previews: some View {
        PreBookingLandingView(
            viewModel: PreBookingLandingViewModel(
                dataController: nil,
                navigationCoordinator: nil
            )
        )
    }
}
#endif
