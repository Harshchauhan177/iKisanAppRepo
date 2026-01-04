//
//  CreateCoEquipGroupView.swift
//  iKisanApp
//
//  SwiftUI Create Co-Equip Group Screen - HIG-compliant minimalistic design
//

import SwiftUI

struct CreateCoEquipGroupView: View {
    @StateObject var viewModel: CreateCoEquipGroupViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFieldAreaFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background - System Gray 6 (matching Review Booking)
            Color(.systemGray6)
                .ignoresSafeArea()
            
            // Main Scrollable Content
            ScrollView {
                VStack(spacing: 0) {
                    // Single White Card Container
                    VStack(spacing: 0) {
                        // Location Row
                        Button(action: {
                            viewModel.showLocationPicker = true
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.ikisanGreen)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Location")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text(viewModel.locationText)
                                        .font(.system(size: 15))
                                        .foregroundColor(viewModel.bookingLocation == nil ? .secondary : .primary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.leading, 52)
                        
                        // Date Row
                        Button(action: {
                            viewModel.showDatePicker = true
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "calendar.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.ikisanGreen)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
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
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.leading, 52)
                        
                        // Field Area Row
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "ruler.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.ikisanGreen)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Your Field Area")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 12) {
                                        TextField("Enter area", text: $viewModel.fieldArea)
                                            .keyboardType(.decimalPad)
                                            .focused($isFieldAreaFocused)
                                            .font(.system(size: 15))
                                            .padding(12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        
                                        Menu {
                                            ForEach(FieldAreaUnit.allCases, id: \.self) { unit in
                                                Button(action: {
                                                    viewModel.selectedFieldAreaUnit = unit
                                                    
                                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                                    generator.impactOccurred()
                                                }) {
                                                    HStack {
                                                        Text(unit.displayName)
                                                        if viewModel.selectedFieldAreaUnit == unit {
                                                            Image(systemName: "checkmark")
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text(viewModel.selectedFieldAreaUnit.displayName)
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.primary)
                                                
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        
                        Divider()
                            .padding(.leading, 52)
                        
                        // Time Slot Row (Calculated)
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.ikisanGreen)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Time Slot")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(viewModel.formattedTimeSlot)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                
                                if let timeSlot = viewModel.calculatedTimeSlots.first {
                                    Text("Calculated for \(String(format: "%.2f", timeSlot.areaInAcres)) acres (≈ \(String(format: "%.1f", timeSlot.durationHours)) hours)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.leading, 52)
                        
                        // Farmers Row
                        Button(action: {
                            viewModel.showFarmerSelection = true
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.ikisanGreen)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Farmers")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Add nearby farmers")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(viewModel.selectedFarmersText)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Footer hint text
                    Text("Invite nearby farmers to join your Co-Equip group and share equipment costs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        .padding(.bottom, 100) // Space for sticky button
                }
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Sticky Footer Button
            VStack(spacing: 0) {
                // Subtle divider
                Divider()
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    viewModel.createGroup()
                }) {
                    HStack {
                        Spacer()
                        
                        if viewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create Group")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        
                        Spacer()
                    }
                    .frame(height: 50)
                    .background(
                        viewModel.isFormValid && !viewModel.isProcessing
                            ? Color.ikisanGreen
                            : Color.gray.opacity(0.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(
                        color: viewModel.isFormValid ? Color.ikisanGreen.opacity(0.3) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .disabled(!viewModel.isFormValid || viewModel.isProcessing)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
            .background(
                Color.white
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .navigationTitle("Create Group")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showLocationPicker) {
            CoEquipLocationPickerView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            CoEquipDatePickerSheet(selectedDate: $viewModel.selectedDate)
        }
        .sheet(isPresented: $viewModel.showFarmerSelection) {
            CoEquipFarmerSelectionView(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Location Picker Sheet

struct CoEquipLocationPickerView: View {
    @ObservedObject var viewModel: CreateCoEquipGroupViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        CoEquipLocationPickerWrapper(viewModel: viewModel, dismiss: dismiss)
            .ignoresSafeArea()
    }
}

// UIKit wrapper for BookingLocationPickerViewController
struct CoEquipLocationPickerWrapper: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CreateCoEquipGroupViewModel
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
        let viewModel: CreateCoEquipGroupViewModel
        let dismiss: DismissAction
        
        init(viewModel: CreateCoEquipGroupViewModel, dismiss: DismissAction) {
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

struct CoEquipDatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Farmer Selection Sheet (Placeholder)

struct CoEquipFarmerSelectionView: View {
    @ObservedObject var viewModel: CreateCoEquipGroupViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "person.2.crop.square.stack.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.ikisanGreen)
                    
                    VStack(spacing: 12) {
                        Text("Nearby Farmers")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Coming Soon")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("This feature will show nearby farmers who can join your Co-Equip group. You'll be able to invite them and share equipment costs.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .navigationTitle("Select Farmers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CreateCoEquipGroupView(
            viewModel: CreateCoEquipGroupViewModel(
                equipment: Equipment.sampleEquipment
            )
        )
    }
}
