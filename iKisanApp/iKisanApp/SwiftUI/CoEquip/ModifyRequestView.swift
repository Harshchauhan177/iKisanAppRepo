//
//  ModifyRequestView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 03/01/26.
//

import SwiftUI

/// Modern, HIG-compliant view for modifying Co-Equip requests
/// Allows users to update field area and invite additional farmers
struct ModifyRequestView: View {
    @ObservedObject var viewModel: ModifyRequestViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAreaFieldFocused: Bool
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingOverlay()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Request Summary Card
                            requestSummarySection
                            
                            // Field Area Section
                            fieldAreaSection
                            
                            // Invite Farmers Section
                            inviteFarmersSection
                            
                            // Current Participants (if any)
                            if !viewModel.currentParticipants.isEmpty {
                                currentParticipantsSection
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Modify Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ikisanGreen)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        Task {
                            await viewModel.updateRequest()
                        }
                    }
                    .foregroundColor(ikisanGreen)
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Request updated successfully!")
            }
            .sheet(isPresented: $viewModel.showFarmerSelection) {
                FarmerSelectionView(
                    viewModel: FarmerSelectionViewModel(
                        dataController: viewModel.dataController,
                        requestId: viewModel.request.id,
                        alreadyInvitedUserIds: viewModel.alreadyInvitedUserIds,
                        onSelectionComplete: { selectedFarmers in
                            viewModel.addSelectedFarmers(selectedFarmers)
                        }
                    )
                )
            }
        }
    }
    
    // MARK: - Request Summary Section
    
    private var requestSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Equipment Image
                AsyncImage(url: URL(string: viewModel.equipmentImageURL)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Equipment Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.equipmentName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Field Area Section
    
    private var fieldAreaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Field Area")
            
            VStack(spacing: 16) {
                // Area Input
                HStack {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.brown)
                        .frame(width: 32)
                    
                    TextField("Enter area", text: $viewModel.fieldArea)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 17))
                        .focused($isAreaFieldFocused)
                    
                    Text("acres")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                )
                
                // Validation message
                if !viewModel.areaValidationMessage.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(viewModel.areaValidationMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Current total area info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.currentTotalArea)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Minimum Required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.minimumArea)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Invite Farmers Section
    
    private var inviteFarmersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Invite More Farmers")
            
            VStack(spacing: 0) {
                Button(action: {
                    viewModel.showFarmerSelection = true
                }) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 20))
                            .foregroundColor(ikisanGreen)
                            .frame(width: 32)
                        
                        Text("Add Farmers to Request")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !viewModel.selectedFarmers.isEmpty {
                            Text("\(viewModel.selectedFarmers.count)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(ikisanGreen))
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                }
                .buttonStyle(.plain)
                
                // Selected farmers preview
                if !viewModel.selectedFarmers.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(viewModel.selectedFarmers) { farmer in
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(farmer.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text(farmer.phone)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.removeFarmer(farmer)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                            )
                        }
                    }
                    .padding(.top, 12)
                }
            }
        }
    }
    
    // MARK: - Current Participants Section
    
    private var currentParticipantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Current Participants (\(viewModel.currentParticipants.count))")
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.currentParticipants.enumerated()), id: \.element.userId) { index, participant in
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(statusColor(for: participant.status))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(participant.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            if let area = participant.area {
                                Text(String(format: "%.2f acres", area))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Status badge
                        Text(participant.status.rawValue.capitalized)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(statusColor(for: participant.status))
                            )
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    
                    if index < viewModel.currentParticipants.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func statusColor(for status: ParticipantStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .accepted:
            return ikisanGreen
        case .done:
            return ikisanGreen
        case .rejected:
            return .red
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ModifyRequestView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyRequestView(
            viewModel: ModifyRequestViewModel.preview()
        )
    }
}
#endif
