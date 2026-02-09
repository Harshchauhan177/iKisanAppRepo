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
                        
                        // Participants Section - Single source of truth
                        participantsSection
                        
                        // Payment Section (if collecting payment)
                        if viewModel.request.status == .collectingPayment {
                            paymentSection
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
    


    // MARK: - Participants Section
    
    private var participantsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Invited Farmers (\(viewModel.participantCount))")
            
            if viewModel.isLoadingParticipants {
                // Loading state
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ikisanGreen))
                        Text("Loading farmers...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
            } else if viewModel.participants.isEmpty {
                // Empty state
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No farmers have joined yet")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
            } else {
                // Display participants
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.participants.enumerated()), id: \.element.id) { index, participant in
                        ParticipantDetailRow(participant: participant, dataController: viewModel.dataController)
                        
                        if index < viewModel.participants.count - 1 {
                            Divider()
                                .padding(.leading, 60)
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
    
    // MARK: - Area and Pricing Section
    
    private var areaPricingSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Details")
            
            VStack(spacing: 0) {
                // Row 1: Minimum Required Area (Hardcoded to 5.0 acres)
                DetailRow(
                    icon: "flag.fill",
                    label: "Minimum Required Area",
                    value: viewModel.minimumAreaText,
                    iconColor: .orange
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Row 2: Current Total Area (Sum of all participants)
                DetailRow(
                    icon: "square.stack.3d.up.fill",
                    label: "Current Total Area",
                    value: viewModel.currentTotalAreaText,
                    iconColor: .teal
                )
                
                Divider()
                    .padding(.leading, 52)
                
                // Row 3: Your Area (Host's contribution for creator, or participant's area)
                if viewModel.isMyRequest {
                    DetailRow(
                        icon: "map.fill",
                        label: "Your Area",
                        value: viewModel.hostAreaText,
                        iconColor: .brown
                    )
                } else {
                    DetailRow(
                        icon: "map.fill",
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
    
    // MARK: - Payment Section
    
    private var paymentSection: some View {
        VStack(spacing: 12) {
            NavigationLink {
                if let equipment = viewModel.cachedEquipment {
                    GroupPaymentView(
                        request: viewModel.request,
                        equipment: equipment
                    )
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.orange)
                            Text("Payment Required")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        if let deadline = viewModel.request.paymentDeadline {
                            let remaining = deadline.timeIntervalSinceNow
                            if remaining > 0 {
                                Text("\(Int(remaining / 3600))h \(Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60))m remaining")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            } else {
                                Text("Payment deadline expired")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
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

// MARK: - Participant Detail Row (New Component for RequestParticipant)

struct ParticipantDetailRow: View {
    let participant: RequestParticipant
    let dataController: DataController?
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    private var user: User? {
        dataController?.getUserById(participant.userId)
    }
    
    private var userName: String {
        user?.name ?? "Unknown"
    }
    
    private var userPhone: String? {
        user?.phone
    }
    
    private var statusColor: Color {
        switch participant.status {
        case .pending: return .orange
        case .accepted: return ikisanGreen
        case .done: return ikisanGreen
        case .rejected: return .red
        }
    }
    
    private var statusIcon: String {
        switch participant.status {
        case .pending: return "clock.fill"
        case .accepted: return "checkmark.circle.fill"
        case .done: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch participant.status {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .done: return "Joined"
        case .rejected: return "Declined"
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // User avatar with status indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(statusColor)
                    )
                
                // Status badge
                Circle()
                    .fill(statusColor)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: statusIcon)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: 2, y: 2)
            }
            
            // Farmer info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(userName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Status badge
                    Text(statusText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.15))
                        )
                }
                
                // Phone number if available
                if let phone = userPhone {
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
        .padding(.vertical, 14)
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
