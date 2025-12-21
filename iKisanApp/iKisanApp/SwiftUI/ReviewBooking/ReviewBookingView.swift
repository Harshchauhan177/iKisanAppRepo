//
//  ReviewBookingView.swift
//  iKisanApp
//
//  SwiftUI Review Booking Screen - Pixel-perfect recreation following HIG principles
//

import SwiftUI

struct ReviewBookingView: View {
    @StateObject var viewModel: ReviewBookingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.screenBackground
                .ignoresSafeArea()
            
            // Main Content
            ScrollView {
                VStack(spacing: 0) {
                    // Main Card Container
                    VStack(spacing: 0) {
                        // Location Row
                        BookingInfoRow(
                            icon: "mappin.circle.fill",
                            title: "Location",
                            showChevron: true,
                            action: {
                                viewModel.showLocationPicker = true
                            }
                        ) {
                            Text(viewModel.locationText)
                                .lineLimit(2)
                                .foregroundColor(viewModel.bookingLocation == nil ? .secondary : .primary)
                        }
                        .accessibilityLabel("Location: \(viewModel.locationText)")
                        .accessibilityHint("Double tap to select booking location")
                        
                        Divider()
                            .padding(.leading, 48)
                        
                        // Date Row
                        BookingInfoRow(
                            icon: "calendar.circle.fill",
                            title: "Date",
                            showChevron: true,
                            action: {
                                viewModel.showDatePicker = true
                            }
                        ) {
                            HStack(spacing: 6) {
                                Text(viewModel.formattedDate)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .accessibilityLabel("Date: \(viewModel.formattedDate)")
                        .accessibilityHint("Double tap to change date")
                        
                        Divider()
                            .padding(.leading, 48)
                        
                        // Field Area Input with Unit Picker
                        FieldAreaInputRow(
                            icon: "ruler.fill",
                            title: "Your Field Area",
                            text: $viewModel.fieldArea,
                            selectedUnit: $viewModel.selectedFieldAreaUnit,
                            placeholder: "Enter field area"
                        )
                        
                        // Show conversion info if user entered a value and unit is not acres
                        if let areaInAcres = viewModel.fieldAreaInAcres,
                           viewModel.selectedFieldAreaUnit != .acre,
                           !viewModel.fieldArea.isEmpty {
                            HStack(spacing: 8) {
                                Spacer()
                                    .frame(width: 36) // Align with content
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "equal.circle.fill")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.ikisanGreen)
                                    
                                    Text("\(String(format: "%.2f", areaInAcres)) acres")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.ikisanGreen)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.ikisanGreenLight)
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.ikisanGreen.opacity(0.3), lineWidth: 1)
                                )
                                
                                Spacer()
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                            .transition(.scale.combined(with: .opacity))
                            .accessibilityLabel("Equivalent to \(String(format: "%.2f", areaInAcres)) acres")
                        }
                        
                        Divider()
                            .padding(.leading, 48)
                        
                        // Time Slot Picker
                        TimeSlotPicker(
                            icon: "clock.fill",
                            title: "Time",
                            selectedTimeSlot: $viewModel.selectedTimeSlot
                        )
                        .accessibilityLabel("Time: \(viewModel.selectedTimeSlot.rawValue)")
                        .accessibilityHint("Use up and down arrows to change time slot")
                        .onChange(of: viewModel.selectedTimeSlot) { _ in
                            viewModel.checkAvailability()
                        }
                        
                        Divider()
                            .padding(.leading, 48)
                        
                        // Price Display with dynamic calculation
                        BookingInfoRow(
                            icon: "indianrupeesign.circle.fill",
                            title: "Price",
                            showChevron: false,
                            action: nil
                        ) {
                            VStack(alignment: .trailing, spacing: 4) {
                                // Show price per hour
                                Text("₹\(String(format: "%.1f", viewModel.pricePerHour))/hour")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                // Show total price if field area is entered
                                if viewModel.totalPrice > 0 {
                                    HStack(spacing: 4) {
                                        Text("Total:")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text("₹\(String(format: "%.2f", viewModel.totalPrice))")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(.ikisanGreen)
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .accessibilityLabel(viewModel.totalPrice > 0 ? "Total price: ₹\(String(format: "%.2f", viewModel.totalPrice))" : "Price per hour: \(viewModel.formattedPrice)")
                        .animation(.spring(response: 0.3), value: viewModel.totalPrice)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Bottom spacing for button
                    Spacer()
                        .frame(height: 100)
                }
            }
            
            // Proceed to Pay Button (Fixed at bottom)
            VStack(spacing: 0) {
                // Gradient fade for better visual separation
                LinearGradient(
                    colors: [Color.screenBackground.opacity(0), Color.screenBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
                
                Button(action: {
                    viewModel.proceedToPayment()
                }) {
                    HStack(spacing: 8) {
                        Spacer()
                        
                        if viewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        }
                        
                        Text("Proceed To Pay")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                viewModel.isFormValid && !viewModel.isProcessing
                                    ? Color.ikisanGreen
                                    : Color.gray.opacity(0.5)
                            )
                            .shadow(
                                color: viewModel.isFormValid ? Color.ikisanGreen.opacity(0.3) : Color.clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                    .padding(.horizontal, 16)
                }
                .disabled(!viewModel.isFormValid || viewModel.isProcessing)
                .scaleEffect(viewModel.isFormValid ? 1.0 : 0.98)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isFormValid)
                .accessibilityLabel("Proceed to payment")
                .accessibilityHint(viewModel.isFormValid ? "Double tap to continue to payment" : "Fill in all required fields to continue")
                
                Color.screenBackground
                    .frame(height: 8)
            }
            .background(Color.screenBackground)
        }
        .navigationTitle("Review Booking")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.fieldArea)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedFieldAreaUnit)
        .sheet(isPresented: $viewModel.showLocationPicker) {
            LocationPickerView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            DatePickerSheet(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onChange(of: viewModel.selectedDate) { _ in
            viewModel.checkAvailability()
        }
    }
}

// MARK: - Location Picker Sheet

struct LocationPickerView: View {
    @ObservedObject var viewModel: ReviewBookingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        LocationPickerWrapper(viewModel: viewModel, dismiss: dismiss)
            .ignoresSafeArea()
    }
}

// UIKit wrapper for BookingLocationPickerViewController
struct LocationPickerWrapper: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ReviewBookingViewModel
    let dismiss: DismissAction
    
    func makeUIViewController(context: Context) -> UINavigationController {
        // Get initial coordinates
        var initialLat: Double = 0.0
        var initialLong: Double = 0.0
        var initialAddress: String? = nil
        
        // Try to use existing booking location first
        if let existingLocation = viewModel.bookingLocation {
            initialLat = existingLocation.latitude
            initialLong = existingLocation.longitude
            initialAddress = existingLocation.address
        }
        // Otherwise use user's location from profile if available
        else if let userLocation = AuthManager.shared.currentUser?.location {
            initialLat = userLocation.latitude
            initialLong = userLocation.longitude
            initialAddress = userLocation.address
        }
        // Last resort - use user's direct coordinates if available
        else if let user = AuthManager.shared.currentUser, 
                user.latitude != 0.0 || user.longitude != 0.0 {
            initialLat = user.latitude
            initialLong = user.longitude
            initialAddress = user.address
        }
        
        // Create location picker
        let picker = BookingLocationPickerViewController(
            latitude: initialLat,
            longitude: initialLong,
            address: initialAddress,
            purpose: .bookingLocation
        )
        
        // Set delegate
        picker.delegate = context.coordinator
        
        // Add Cancel button on the left per HIG
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: context.coordinator,
            action: #selector(Coordinator.cancelTapped)
        )
        picker.navigationItem.leftBarButtonItem = cancelButton
        
        // Wrap in navigation controller for proper presentation
        let navController = UINavigationController(rootViewController: picker)
        navController.modalPresentationStyle = .formSheet
        
        // Configure navigation bar appearance
        if let navigationBar = navController.navigationBar as UINavigationBar? {
            navigationBar.prefersLargeTitles = false
        }
        
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, BookingLocationPickerDelegate {
        let viewModel: ReviewBookingViewModel
        let dismiss: DismissAction
        
        init(viewModel: ReviewBookingViewModel, dismiss: DismissAction) {
            self.viewModel = viewModel
            self.dismiss = dismiss
        }
        
        func didUpdateLocation(latitude: Double, longitude: Double, address: String?) {
            let location = Location(
                latitude: latitude,
                longitude: longitude,
                address: address
            )
            
            Task { @MainActor in
                viewModel.updateLocation(location)
                dismiss()
            }
        }
        
        @objc func cancelTapped() {
            Task { @MainActor in
                dismiss()
            }
        }
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @ObservedObject var viewModel: ReviewBookingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                if !viewModel.isEquipmentAvailable {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Equipment not available on this date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.ikisanGreen)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ReviewBookingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReviewBookingView(
                viewModel: ReviewBookingViewModel(
                    equipment: Equipment(
                        equipmentID: UUID(),
                        equipmentImage: "tractor",
                        name: "John Deere Tractor",
                        type: "Tractor",
                        capacity: "50 HP",
                        pricePerHour: 1100.0,
                        realPricePerHour: 1100.0,
                        pricePerAcre: 500.0,
                        realPricePerAcre: 500.0,
                        providerID: UUID(),
                        rating: 4.5,
                        location: "San Francisco, CA",
                        coEquipDetail: .Available,
                        modelYear: "2023",
                        mielage: "1000 km"
                    ),
                    bookingSource: .home,
                    dataController: nil,
                    navigationCoordinator: nil
                )
            )
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            ReviewBookingView(
                viewModel: ReviewBookingViewModel(
                    equipment: Equipment(
                        equipmentID: UUID(),
                        equipmentImage: "tractor",
                        name: "John Deere Tractor",
                        type: "Tractor",
                        capacity: "50 HP",
                        pricePerHour: 1100.0,
                        realPricePerHour: 1100.0,
                        pricePerAcre: 500.0,
                        realPricePerAcre: 500.0,
                        providerID: UUID(),
                        rating: 4.5,
                        location: "San Francisco, CA",
                        coEquipDetail: .Available,
                        modelYear: "2023",
                        mielage: "1000 km"
                    ),
                    bookingSource: .home,
                    dataController: nil,
                    navigationCoordinator: nil
                )
            )
        }
        .preferredColorScheme(.dark)
    }
}
#endif
