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
                if !newValue.isEmpty {
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
                viewModel.loadInitialData()
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
                            viewModel.selectEquipment(equipment)
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
                    viewModel.preBookEquipment(equipment)
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
                        viewModel.modifyBooking(booking, equipment: equipment)
                    },
                    onCancel: {
                        viewModel.cancelBooking(booking, equipment: equipment)
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
