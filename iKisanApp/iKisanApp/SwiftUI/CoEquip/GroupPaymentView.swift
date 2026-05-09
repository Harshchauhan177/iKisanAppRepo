//
//  GroupPaymentView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 13/01/26.
//  SwiftUI view for group payment workflow
//

import SwiftUI

/// View displayed when group is in payment collection phase
struct GroupPaymentView: View {
    @StateObject private var viewModel: GroupPaymentViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(request: Request, equipment: Equipment) {
        _viewModel = StateObject(wrappedValue: GroupPaymentViewModel(request: request, equipment: equipment))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Countdown Timer
                    if viewModel.showCountdown {
                        countdownSection
                    }
                    
                    // Payment Status
                    paymentStatusSection
                    
                    // Participants List
                    participantsSection
                    
                    // Payment Action Button
                    if viewModel.canPay {
                        paymentButtonSection
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Group Payment")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Payment Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Payment Successful!", isPresented: $viewModel.showSuccess) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your payment has been recorded. Waiting for other participants.")
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Equipment Image
            AsyncImage(url: URL(string: viewModel.equipment.equipmentImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        ProgressView()
                    )
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Equipment Name
            Text(viewModel.equipment.name)
                .font(.title2)
                .fontWeight(.bold)
            
            // Group Info
            HStack(spacing: 16) {
                InfoChip(icon: "calendar", text: viewModel.formattedDate)
                InfoChip(icon: "map", text: viewModel.request.location)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    // MARK: - Countdown Section
    
    private var countdownSection: some View {
        VStack(spacing: 12) {
            Text("Time Remaining to Pay")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Countdown Display
            HStack(spacing: 4) {
                TimeUnit(value: viewModel.hoursRemaining, label: "hours")
                Text(":")
                    .font(.system(size: 32, weight: .bold))
                TimeUnit(value: viewModel.minutesRemaining, label: "min")
                Text(":")
                    .font(.system(size: 32, weight: .bold))
                TimeUnit(value: viewModel.secondsRemaining, label: "sec")
            }
            
            // Progress Bar
            ProgressView(value: viewModel.timeProgress)
                .tint(viewModel.timeRemainingColor)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(viewModel.timeRemainingColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Payment Status Section
    
    private var paymentStatusSection: some View {
        VStack(spacing: 16) {
            Text("Payment Status")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Total Amount
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Share")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(String(format: "%.2f", viewModel.paymentAmount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ikisanGreen)
                }
                
                Spacer()
                
                // Payment Status Badge
                HStack(spacing: 6) {
                    Image(systemName: viewModel.currentUserPaymentStatus.iconName)
                    Text(viewModel.currentUserPaymentStatus.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(viewModel.paymentStatusColor.opacity(0.2))
                .foregroundColor(viewModel.paymentStatusColor)
                .cornerRadius(8)
            }
            
            // Group Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Group Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.paidCount)/\(viewModel.totalCount) Paid")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: viewModel.paymentProgress)
                    .tint(.ikisanGreen)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    // MARK: - Participants Section
    
    private var participantsSection: some View {
        VStack(spacing: 16) {
            Text("Participants (\(viewModel.totalCount))")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.participantsWithUsers.enumerated()), id: \.element.participant.id) { index, item in
                    ParticipantRow(
                        user: item.user,
                        participant: item.participant,
                        isCurrentUser: item.participant.userId == viewModel.currentUserId
                    )
                    
                    if index < viewModel.participantsWithUsers.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
    
    // MARK: - Payment Button Section
    
    private var paymentButtonSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                viewModel.initiatePayment()
            }) {
                HStack(spacing: 12) {
                    if viewModel.isProcessingPayment {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else if !FeatureFlags.isRazorpayEnabled {
                        // MARK: - COD Payment Button
                        Image(systemName: "banknote")
                        Text("Confirm COD — ₹\(String(format: "%.2f", viewModel.paymentAmount))")
                            .fontWeight(.semibold)
                    } else {
                        // MARK: - Future Razorpay Integration
                        Image(systemName: "creditcard.fill")
                        Text("Pay ₹\(String(format: "%.2f", viewModel.paymentAmount))")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.ikisanGreen)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isProcessingPayment)
            .padding(.top, 8)
            
            // COD info label
            if !FeatureFlags.isRazorpayEnabled {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("You will pay when service is delivered")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Supporting Views

struct InfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct TimeUnit: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(String(format: "%02d", value))")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct ParticipantRow: View {
    let user: User?
    let participant: RequestParticipant
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: participant.paymentStatus.iconName)
                        .foregroundColor(statusColor)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user?.name ?? "Unknown")
                        .font(.system(size: 16, weight: .medium))
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let area = participant.area {
                    Text("\(String(format: "%.2f", area)) acres")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Payment Status
            Image(systemName: participant.paymentStatus == .paid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(participant.paymentStatus == .paid ? .green : .gray)
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var statusColor: Color {
        switch participant.paymentStatus {
        case .paid: return .green
        case .pending: return .orange
        case .failed: return .red
        case .refunded: return .blue
        }
    }
}

// MARK: - Preview

#if DEBUG
struct GroupPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupPaymentView(
                request: Request(
                    id: UUID(),
                    userId: UUID(),
                    equipmentId: UUID(),
                    requestedDate: Date(),
                    status: .collectingPayment,
                    type: .coEquip,
                    area: 10.0,
                    timeSlot: .morning,
                    timePeriod: "8:00 AM - 12:00 PM",
                    location: "Village Road, District",
                    typeOfRequest: .myRequest,
                    participants: [],
                    paymentDeadline: Date().addingTimeInterval(3600 * 3)
                ),
                equipment: Equipment(
                    equipmentID: UUID(),
                    equipmentImage: "",
                    name: "Tractor",
                    type: "Heavy",
                    capacity: "50 HP",
                    pricePerHour: 500,
                    realPricePerHour: 600,
                    pricePerAcre: 800,
                    realPricePerAcre: 900,
                    providerID: UUID(),
                    rating: 4.5,
                    location: "Farm Area",
                    coEquipDetail: .Available,
                    modelYear: "2023",
                    mielage: "15 km/l"
                )
            )
        }
    }
}
#endif
