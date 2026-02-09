//
//  GroupPaymentIntegrationExample.swift
//  iKisanApp
//
//  Quick integration examples for existing views
//

import SwiftUI

// MARK: - Example 1: Update RequestDetailView to show payment UI

/*
 Add this to your RequestDetailView.swift in the action buttons section:
 
 if viewModel.request.status == .collectingPayment {
     // Show Payment Button or Status
     GroupPaymentStatusCard(
         request: viewModel.request,
         equipment: viewModel.equipment
     )
 } else if viewModel.request.status == .awaitingProvider {
     // Show waiting message
     Text("Awaiting provider confirmation")
         .font(.subheadline)
         .foregroundColor(.secondary)
 } else if viewModel.request.status == .active {
     // Show active group status
     HStack {
         Image(systemName: "checkmark.circle.fill")
             .foregroundColor(.green)
         Text("Group Active - Work in Progress")
             .font(.subheadline)
     }
 }
*/

// MARK: - Example 2: Payment Status Card Component

struct GroupPaymentStatusCard: View {
    let request: Request
    let equipment: Equipment
    @StateObject private var paymentManager = GroupPaymentManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Status Header
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.orange)
                Text("Payment Required")
                    .font(.headline)
                Spacer()
                if let deadline = request.paymentDeadline {
                    CountdownBadge(deadline: deadline)
                }
            }
            
            // User's Payment Status
            if let currentUser = AuthManager.shared.currentUser {
                let currentUserId = currentUser.id
                let hasPaid = paymentManager.hasUserPaid(in: request, userId: currentUserId)
                
                if hasPaid {
                    // User has paid
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("You have paid. Waiting for others.")
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    // User needs to pay
                    NavigationLink(destination: GroupPaymentView(request: request, equipment: equipment)) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Complete Payment")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.ikisanGreen)
                        .cornerRadius(12)
                    }
                }
            }
            
            // Payment Progress
            let summary = paymentManager.getPaymentSummary(for: request)
            ProgressView(value: summary.paymentProgress)
                .tint(.ikisanGreen)
            
            Text("\(summary.paidParticipants)/\(summary.totalParticipants) participants paid")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Example 3: Countdown Badge

struct CountdownBadge: View {
    let deadline: Date
    @State private var timeRemaining: TimeInterval = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.caption)
            Text(formattedTime)
                .font(.caption)
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(timeColor.opacity(0.2))
        .foregroundColor(timeColor)
        .cornerRadius(6)
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
        .onAppear {
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = deadline.timeIntervalSinceNow
    }
    
    private var formattedTime: String {
        guard timeRemaining > 0 else { return "Expired" }
        
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        
        return "\(hours)h \(minutes)m"
    }
    
    private var timeColor: Color {
        if timeRemaining > 7200 { // > 2 hours
            return .green
        } else if timeRemaining > 3600 { // > 1 hour
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Example 4: Provider Acceptance with Payment Timer

/*
 Update your provider acceptance function:
 
 func acceptGroupRequest(requestId: UUID) async throws {
     // Update status to collecting_payment (trigger will set deadline)
     try await SupabaseManager.shared.client
         .from("requests")
         .update(["status": "collecting_payment"])
         .eq("id", value: requestId.uuidString)
         .execute()
     
     // Optional: Send push notifications to all participants
     await sendPaymentNotifications(requestId: requestId)
     
     print("✅ Group payment collection started")
 }
 
 func sendPaymentNotifications(requestId: UUID) async {
     // Fetch all participants
     let participants = try? await SupabaseManager.shared.client
         .from("request_participants")
         .select("userId")
         .eq("requestId", value: requestId.uuidString)
         .execute()
         .value as? [[String: Any]]
     
     // Send push notification to each participant
     // Implementation depends on your push notification setup
     for participant in participants ?? [] {
         if let userId = participant["userId"] as? String {
             // Send notification: "Provider accepted! Pay within 4 hours."
             print("📲 Notifying user: \(userId)")
         }
     }
 }
*/

// MARK: - Example 5: Group Card with Payment Status

struct GroupCardWithPaymentStatus: View {
    let request: Request
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Existing group card content...
            
            // Payment Status Badge
            if request.status == BookingStatus.collectingPayment {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                    Text("Payment Required")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    if let deadline = request.paymentDeadline {
                        Spacer()
                        Text(timeRemaining(until: deadline))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            } else if request.status == .awaitingProvider {
                HStack {
                    Image(systemName: "person.crop.circle.badge.clock")
                        .foregroundColor(.blue)
                    Text("Awaiting Provider")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            } else if request.status == .active {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private func timeRemaining(until deadline: Date) -> String {
        let remaining = deadline.timeIntervalSinceNow
        guard remaining > 0 else { return "Expired" }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        
        return "\(hours)h \(minutes)m left"
    }
}

// MARK: - Example 6: Listen for Group Activation

/*
 In your CoEquip list view or relevant view model, listen for group activation:
 
 class CoEquipListViewModel: ObservableObject {
     private var cancellables = Set<AnyCancellable>()
     
     init() {
         // Listen for group activation
         NotificationCenter.default.publisher(for: .groupActivated)
             .sink { [weak self] notification in
                 if let requestId = notification.userInfo?["requestId"] as? UUID {
                     self?.handleGroupActivated(requestId: requestId)
                 }
             }
             .store(in: &cancellables)
         
         // Listen for payment completion
         NotificationCenter.default.publisher(for: .groupPaymentCompleted)
             .sink { [weak self] notification in
                 self?.refreshGroupList()
             }
             .store(in: &cancellables)
     }
     
     private func handleGroupActivated(requestId: UUID) {
         // Show success message or navigate to active group view
         print("🎉 Group \(requestId) is now active!")
         // Refresh UI
         Task {
             await refreshGroupList()
         }
     }
 }
*/

// MARK: - Example 7: Test Payment Flow

/*
 For testing, you can create a test group:
 
 func createTestPaymentGroup() async throws {
     let requestId = UUID()
     let currentUserId = AuthManager.shared.currentUser?.userID ?? UUID()
     
     // Create test request
     let request = Request(
         id: requestId,
         userId: currentUserId,
         equipmentId: UUID(), // Use a real equipment ID
         requestedDate: Date().addingTimeInterval(86400), // Tomorrow
         status: .collectingPayment, // Start directly in payment collection
         type: .coEquip,
         area: 5.0,
         timeSlot: .morning,
         timePeriod: "8:00 AM - 12:00 PM",
         location: "Test Location",
         typeOfRequest: .myRequest,
         participants: [],
         paymentDeadline: Date().addingTimeInterval(3600) // 1 hour for testing
     )
     
     // Insert into database (will need to manually set payment_deadline)
     try await SupabaseManager.shared.client
         .from("requests")
         .insert(request)
         .execute()
     
     // Create test participant
     let participant = RequestParticipant(
         id: UUID(),
         requestId: requestId,
         userId: currentUserId,
         status: .pending,
         area: 5.0,
         timeSlot: "morning",
         joinedAt: Date(),
         paymentStatus: .pending
     )
     
     try await SupabaseManager.shared.client
         .from("request_participants")
         .insert(participant)
         .execute()
     
     print("✅ Test payment group created: \(requestId)")
 }
*/

// Note: Color.ikisanGreen may already be defined in your project
