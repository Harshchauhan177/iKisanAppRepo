//
//  RequestDetailView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 26/12/25.
//

import SwiftUI

/// Modern, HIG-compliant Request Detail view for Co-Equip feature
/// Displays comprehensive request information with native iOS design patterns
struct RequestDetailView: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrollable content
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Equipment Image
                    heroImageSection
                    
                    // Main content in native inset grouped list style
                    VStack(spacing: 20) {
                        // Status and Title
                        headerSection
                        
                        // Request Details
                        requestDetailsSection
                        
                        // Schedule Information
                        scheduleSection
                        
                        // Requester Information
                        requesterSection
                        
                        // Invited/Joined Farmers - Show real participants from database
                        if !viewModel.fetchedParticipants.isEmpty {
                            invitedFarmersSection
                        }
                        
                        // Legacy: Joined Farmers Section (for My Requests only)
                        if viewModel.hasJoinedFarmers && viewModel.fetchedParticipants.isEmpty {
                            joinedFarmersSection
                        }
                        
                        // Legacy: Participants Section (if any)
                        if viewModel.hasParticipants && viewModel.fetchedParticipants.isEmpty {
                            participantsSection
                        }
                        
                        // Area and Pricing
                        areaPricingSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, -30) // Overlap the image slightly
                    .padding(.bottom, 100) // Space for action buttons
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Sticky action footer
            if viewModel.showActions {
                actionFooter
            }
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Confirm Delete", isPresented: $viewModel.showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button(
                viewModel.confirmationAction == .delete ? "Delete" : (viewModel.confirmationAction == .accept ? "Accept" : "Decline"),
                role: viewModel.confirmationAction == .delete || viewModel.confirmationAction == .decline ? .destructive : nil
            ) {
                viewModel.confirmAction()
            }
        } message: {
            Text(viewModel.confirmationMessage)
        }
        .sheet(isPresented: $viewModel.showModifySheet) {
            if let dataController = viewModel.dataController {
                ModifyRequestView(
                    viewModel: ModifyRequestViewModel(
                        request: viewModel.request,
                        dataController: dataController
                    )
                )
                .interactiveDismissDisabled(false)
            }
        }
        .navigationDestination(isPresented: $viewModel.showEquipmentDetail) {
            if let equipment = viewModel.cachedEquipment {
                EquipmentDetailView(
                    viewModel: EquipmentDetailViewModel(
                        equipment: equipment,
                        bookingSource: .coEquipViewOnly,
                        dataController: viewModel.dataController,
                        navigationCoordinator: nil,
                        isReadOnly: true
                    )
                )
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
    }
    
    // MARK: - Hero Image Section
    
    private var heroImageSection: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: viewModel.equipmentImageURL)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 280)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Image not available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: geometry.size.width, height: 280)
        }
        .frame(height: 280)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status Badge
            HStack {
                statusBadge
                Spacer()
            }
            
            // Equipment Title
            Text(viewModel.equipmentName)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
    
    private var statusBadge: some View {
        Text(viewModel.statusText)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(viewModel.statusColor)
            )
    }
    
    // MARK: - Request Details Section
    
    private var requestDetailsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Equipment Details")
            
            VStack(spacing: 0) {
                DetailRow(
                    icon: "wrench.and.screwdriver.fill",
                    label: "Equipment Type",
                    value: viewModel.equipmentType,
                    iconColor: .orange
                )
                
                Divider()
                    .padding(.leading, 52)
                
                DetailRow(
                    icon: "speedometer",
                    label: "Capacity",
                    value: viewModel.equipmentCapacity,
                    iconColor: .blue
                )
                
                Divider()
                    .padding(.leading, 52)
                
                DetailRow(
                    icon: "mappin.circle.fill",
                    label: "Location",
                    value: viewModel.location,
                    iconColor: .red
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Schedule Section
    
    private var scheduleSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Schedule")
            
            VStack(spacing: 0) {
                DetailRow(
                    icon: "calendar",
                    label: "Date",
                    value: viewModel.formattedDate,
                    iconColor: ikisanGreen
                )
                
                Divider()
                    .padding(.leading, 52)
                
                DetailRow(
                    icon: "clock.fill",
                    label: "Time Slot",
                    value: viewModel.timeSlotText,
                    iconColor: .purple
                )
                
                if let timePeriod = viewModel.timePeriod {
                    Divider()
                        .padding(.leading, 52)
                    
                    DetailRow(
                        icon: "timer",
                        label: "Duration",
                        value: timePeriod,
                        iconColor: .indigo
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Requester Section
    
    private var requesterSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: viewModel.isMyRequest ? "Created By" : "Requester")
            
            VStack(spacing: 0) {
                DetailRow(
                    icon: "person.fill",
                    label: "Name",
                    value: viewModel.requesterName,
                    iconColor: .cyan
                )
                
                if let providerName = viewModel.equipmentProviderName {
                    Divider()
                        .padding(.leading, 52)
                    
                    DetailRow(
                        icon: "person.crop.circle.badge.checkmark",
                        label: "Equipment Owner",
                        value: providerName,
                        iconColor: .green
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Joined Farmers Section
    
    private var joinedFarmersSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Joined Farmers (\(viewModel.joinedFarmersCount))")
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.joinedFarmers.enumerated()), id: \.element.id) { index, farmer in
                    JoinedFarmerRow(farmer: farmer)
                    
                    if index < viewModel.joinedFarmers.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Invited Farmers Section (New)
    
    private var invitedFarmersSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Invited Farmers (\(viewModel.fetchedParticipants.count))")
            
            if viewModel.isLoadingParticipants {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 20)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.fetchedParticipants.enumerated()), id: \.element.id) { index, participant in
                        InvitedFarmerRow(participant: participant)
                        
                        if index < viewModel.fetchedParticipants.count - 1 {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
            }
        }
    }
    
    // MARK: - Participants Section
    
    private var participantsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Participants (\(viewModel.participantCount))")
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.participants.enumerated()), id: \.element.id) { index, participant in
                    ParticipantRow(participant: participant)
                    
                    if index < viewModel.participants.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Area and Pricing Section
    
    private var areaPricingSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Details")
            
            VStack(spacing: 0) {
                if viewModel.isMyRequest {
                    DetailRow(
                        icon: "square.grid.3x3.fill",
                        label: "Minimum Area",
                        value: viewModel.minimumAreaText,
                        iconColor: .brown
                    )
                    
                    Divider()
                        .padding(.leading, 52)
                    
                    DetailRow(
                        icon: "square.stack.3d.up.fill",
                        label: "Current Total Area",
                        value: viewModel.currentTotalAreaText,
                        iconColor: .teal
                    )
                } else {
                    DetailRow(
                        icon: "square.grid.3x3.fill",
                        label: "Your Area",
                        value: viewModel.yourAreaText ?? "Not set",
                        iconColor: .brown
                    )
                }
                
                Divider()
                    .padding(.leading, 52)
                
                DetailRow(
                    icon: "indianrupeesign.circle.fill",
                    label: "Price per Acre",
                    value: viewModel.pricePerAcreText,
                    iconColor: ikisanGreen
                )
                
                if let totalPrice = viewModel.estimatedTotalPrice {
                    Divider()
                        .padding(.leading, 52)
                    
                    DetailRow(
                        icon: "creditcard.fill",
                        label: "Estimated Total",
                        value: totalPrice,
                        iconColor: .green,
                        valueWeight: .semibold
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Action Footer
    
    private var actionFooter: some View {
        VStack(spacing: 12) {
            if viewModel.canModify {
                // Primary action button
                Button(action: {
                    viewModel.modifyRequest()
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Modify Request")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(ikisanGreen)
            } else if viewModel.canAccept {
                // Accept button
                Button(action: {
                    viewModel.presentAcceptConfirmation()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Accept Request")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(ikisanGreen)
            }
            
            // Secondary actions
            HStack(spacing: 12) {
                if viewModel.canViewEquipment {
                    Button(action: {
                        viewModel.viewEquipmentDetails()
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("View Equipment")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .buttonStyle(.bordered)
                    .tint(ikisanGreen)
                }
                
                if viewModel.canDelete {
                    Button(role: .destructive, action: {
                        viewModel.presentDeleteConfirmation()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .buttonStyle(.bordered)
                } else if viewModel.canDecline {
                    Button(role: .destructive, action: {
                        viewModel.presentDeclineConfirmation()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("Decline")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 0, style: .continuous)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
    }
}

// MARK: - Supporting Views

/// Section header with native iOS styling
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

/// Detailed row with SF Symbol, label, and value
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var iconColor: Color = .blue
    var valueWeight: Font.Weight = .regular
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            // Label
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(size: 15, weight: valueWeight))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

/// Participant row displaying user info
struct ParticipantRow: View {
    let participant: RequestDetailViewModel.ParticipantInfo
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // User avatar
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                )
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(participant.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                if let area = participant.area {
                    Text("\(String(format: "%.2f", area)) acres")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Time slot or status
            if let timeSlot = participant.timeSlot {
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(timeSlot)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

/// Joined farmer row displaying farmer who accepted/joined the request
struct JoinedFarmerRow: View {
    let farmer: RequestDetailViewModel.ParticipantInfo
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // User avatar with checkmark
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(ikisanGreen.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(ikisanGreen)
                    )
                
                // Checkmark badge
                Circle()
                    .fill(ikisanGreen)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 2, y: 2)
            }
            
            // Farmer info
            VStack(alignment: .leading, spacing: 4) {
                Text(farmer.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    // Area badge
                    if let area = farmer.area {
                        HStack(spacing: 4) {
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.1f", area)) acres")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    
                    // Time slot badge
                    if let timeSlot = farmer.timeSlot {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(timeSlot)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                }
            }
            
            Spacer()
            
            // Status indicator
            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: statusIcon(for: farmer.status))
                    .font(.system(size: 20))
                    .foregroundColor(statusColor(for: farmer.status))
                
                Text(statusText(for: farmer.status))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(statusColor(for: farmer.status))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // Helper methods for status display
    private func statusIcon(for status: ParticipantStatus) -> String {
        switch status {
        case .pending:
            return "clock.fill"
        case .accepted:
            return "checkmark.circle.fill"
        case .done:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        }
    }
    
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
    
    private func statusText(for status: ParticipantStatus) -> String {
        switch status {
        case .pending:
            return "Pending"
        case .accepted:
            return "Accepted"
        case .done:
            return "Joined"
        case .rejected:
            return "Rejected"
        }
    }
}

// MARK: - Invited Farmer Row (New Component)

struct InvitedFarmerRow: View {
    let participant: RequestDetailViewModel.ParticipantDisplayInfo
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // User avatar with status indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(statusBackgroundColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(statusBackgroundColor)
                    )
                
                // Status badge
                Circle()
                    .fill(statusBackgroundColor)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: participant.statusIcon)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 2, y: 2)
            }
            
            // Farmer info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(participant.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Status badge
                    Text(participant.statusText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(statusBackgroundColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(statusBackgroundColor.opacity(0.15))
                        )
                }
                
                // Phone number if available
                if let phone = participant.phone {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(phone)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 8) {
                    // Area badge (if provided)
                    if let area = participant.area, area > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.1f", area)) acres")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    
                    // Time slot badge (if provided)
                    if let timeSlot = participant.timeSlot, !timeSlot.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(timeSlot)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var statusBackgroundColor: Color {
        switch participant.status {
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

/// Loading overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                Text("Processing...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RequestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RequestDetailView(
                viewModel: RequestDetailViewModel.preview()
            )
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            RequestDetailView(
                viewModel: RequestDetailViewModel.preview()
            )
        }
        .preferredColorScheme(.dark)
    }
}
#endif
