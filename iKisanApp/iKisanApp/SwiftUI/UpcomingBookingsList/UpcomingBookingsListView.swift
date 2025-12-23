//
//  UpcomingBookingsListView.swift
//  iKisanApp
//
//  SwiftUI View for Upcoming Bookings List Screen
//

import SwiftUI

struct UpcomingBookingsListView: View {
    @StateObject private var viewModel: UpcomingBookingsListViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initializer
    init(viewModel: UpcomingBookingsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Segmented Control
                segmentedControl
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if !viewModel.hasBookings {
                    emptyStateView
                } else {
                    bookingsListView
                }
            }
        }
        .navigationTitle("Bookings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Segmented Control
    private var segmentedControl: some View {
        Picker("Booking Filter", selection: $viewModel.selectedFilter) {
            ForEach(BookingFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Bookings List View
    private var bookingsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.displayedBookings, id: \.bookingID) { booking in
                    if let equipment = viewModel.getEquipment(for: booking) {
                        BookingCardView(
                            booking: booking,
                            equipment: equipment,
                            onViewTapped: {
                                viewModel.handleBookingTap(booking: booking, equipment: equipment)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .refreshable {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .tint(Color(red: 0.298, green: 0.498, blue: 0.345))
                .scaleEffect(1.2)
            
            Text("Loading bookings...")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: viewModel.selectedFilter == .upcoming ? "calendar.badge.clock" : "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(viewModel.selectedFilter == .upcoming ? "No Upcoming Bookings" : "No Completed Bookings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(viewModel.selectedFilter == .upcoming 
                 ? "Your upcoming bookings will appear here" 
                 : "Your completed bookings will appear here")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
}

// MARK: - Preview
#if DEBUG
struct UpcomingBookingsListView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock ViewModel with sample data
        let viewModel = UpcomingBookingsListViewModel()
        
        // Mock upcoming bookings
        viewModel.upcomingBookings = [
            Booking(
                userID: UUID(),
                equipmentID: UUID(),
                bookingType: .onDemand,
                bookingDate: Date(),
                fieldArea: 5.0,
                status: .confirmed,
                timeSlot: .morning,
                source: .home
            ),
            Booking(
                userID: UUID(),
                equipmentID: UUID(),
                bookingType: .onDemand,
                bookingDate: Date().addingTimeInterval(86400),
                fieldArea: 3.5,
                status: .pending,
                timeSlot: .afternoon,
                source: .home
            )
        ]
        
        // Mock completed bookings
        viewModel.completedBookings = [
            Booking(
                userID: UUID(),
                equipmentID: UUID(),
                bookingType: .onDemand,
                bookingDate: Date().addingTimeInterval(-86400 * 2),
                fieldArea: 4.0,
                status: .completed,
                timeSlot: .morning,
                source: .home
            )
        ]
        
        // Mock equipment
        viewModel.allEquipment = [
            Equipment(
                equipmentID: UUID(),
                equipmentImage: "Mahindra Tractor",
                name: "Mahindra Tractor",
                type: "Tractor",
                capacity: "45HP",
                pricePerHour: 1000.0,
                realPricePerHour: 1200.0,
                pricePerAcre: 0,
                realPricePerAcre: 0,
                providerID: UUID(),
                rating: 4.5,
                location: "Delhi",
                coEquipDetail: .Available,
                modelYear: "2023",
                mielage: "10 km/l"
            )
        ]
        
        return NavigationView {
            UpcomingBookingsListView(viewModel: viewModel)
        }
    }
}
#endif
