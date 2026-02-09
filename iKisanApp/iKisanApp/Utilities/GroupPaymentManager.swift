//
//  GroupPaymentManager.swift
//  iKisanApp
//
//  Created by Senior Backend Engineer on 13/01/26.
//  Handles group payment workflow with Razorpay integration
//

import Foundation
import UIKit
import Supabase
import Razorpay

/// Manager for handling group payment workflow (post-confirmation payments)
/// Extends existing Razorpay integration to support CoEquip group payments
@MainActor
class GroupPaymentManager: NSObject, ObservableObject, RazorpayPaymentCompletionProtocol {
    
    // MARK: - Singleton
    static let shared = GroupPaymentManager()
    
    // MARK: - Published Properties
    @Published var isProcessingPayment: Bool = false
    @Published var paymentError: String?
    @Published var showPaymentSuccess: Bool = false
    
    // MARK: - Private Properties
    private var razorpay: RazorpayCheckout?
    private let razorpayKey = "rzp_test_A9W91a51kUjKmX" // Reuse existing key
    
    // Current payment context
    private var currentRequest: Request?
    private var currentParticipant: RequestParticipant?
    private var currentEquipment: Equipment?
    private var currentUser: User?
    private var paymentCompletionHandler: ((Bool, String?) -> Void)?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setupRazorpay()
    }
    
    private func setupRazorpay() {
        razorpay = RazorpayCheckout.initWithKey(razorpayKey, andDelegate: self)
        print("✅ GroupPaymentManager initialized with Razorpay")
    }
    
    // MARK: - Public Methods
    
    /// Initiate payment for a group participant
    /// - Parameters:
    ///   - request: The group request
    ///   - participant: The participant making payment
    ///   - equipment: The equipment being booked
    ///   - user: Current user
    ///   - amount: Payment amount in INR
    ///   - completion: Callback with success status and optional payment ID
    func initiateGroupPayment(
        request: Request,
        participant: RequestParticipant,
        equipment: Equipment,
        user: User,
        amount: Double,
        completion: @escaping (Bool, String?) -> Void
    ) {
        print("🔄 Initiating group payment for request: \(request.id)")
        
        // Validate group state
        guard request.status == .collectingPayment else {
            completion(false, "Group is not in payment collection state")
            return
        }
        
        // Check if payment deadline has passed
        if request.hasPaymentExpired {
            completion(false, "Payment deadline has expired")
            return
        }
        
        // Check if user already paid
        if participant.paymentStatus == .paid {
            completion(false, "You have already paid for this group")
            return
        }
        
        // Store context
        self.currentRequest = request
        self.currentParticipant = participant
        self.currentEquipment = equipment
        self.currentUser = user
        self.paymentCompletionHandler = completion
        
        // Mark as processing
        isProcessingPayment = true
        paymentError = nil
        
        // Prepare Razorpay options
        let options: [String: Any] = [
            "amount": String(Int(amount * 100)), // Convert to paise
            "currency": "INR",
            "description": "CoEquip Group Payment - \(equipment.name)",
            "image": equipment.equipmentImage,
            "name": "iKisan CoEquip",
            "prefill": [
                "email": user.email,
                "contact": user.phone
            ],
            "theme": [
                "color": "#4C7F5F" // iKisan green
            ],
            "notes": [
                "bookingType": "coequip_group",
                "requestId": request.id.uuidString,
                "participantId": participant.id.uuidString,
                "userId": user.userID.uuidString,
                "equipmentId": equipment.equipmentID.uuidString
            ]
        ]
        
        // Open Razorpay payment
        print("💳 Opening Razorpay with amount: ₹\(amount)")
        razorpay?.open(options)
        
        // Note: Processing flag will be reset in callbacks
    }
    
    /// Check if current user has paid for a group
    func hasUserPaid(in request: Request, userId: UUID) -> Bool {
        guard let participants = request.participants else { return false }
        
        let userParticipant = participants.first { $0.userId == userId }
        return userParticipant?.paymentStatus == .paid
    }
    
    /// Get payment summary for a group
    func getPaymentSummary(for request: Request) -> GroupPaymentSummary {
        let participants = request.participants ?? []
        let totalCount = participants.count
        let paidCount = participants.filter { $0.paymentStatus == .paid }.count
        let pendingCount = participants.filter { $0.paymentStatus == .pending }.count
        let totalCollected = participants
            .filter { $0.paymentStatus == .paid }
            .compactMap { $0.paymentAmount }
            .reduce(0, +)
        
        return GroupPaymentSummary(
            requestId: request.id,
            totalParticipants: totalCount,
            paidParticipants: paidCount,
            pendingParticipants: pendingCount,
            totalAmountCollected: totalCollected,
            paymentDeadline: request.paymentDeadline,
            isComplete: totalCount > 0 && paidCount == totalCount
        )
    }
    
    // MARK: - Private Methods
    
    /// Record payment success in Supabase
    private func recordPaymentSuccess(paymentId: String) async {
        guard let request = currentRequest,
              let participant = currentParticipant,
              let user = currentUser,
              let equipment = currentEquipment else {
            print("❌ Missing context for payment recording")
            return
        }
        
        // Calculate amount (you may want to pass this in)
        let amount = equipment.pricePerAcre * (participant.area ?? 0.0)
        
        do {
            print("📝 Recording payment in Supabase...")
            
            // Call the secure RPC function
            let result = try await SupabaseManager.shared.client
                .rpc("record_participant_payment", params: [
                    "p_request_id": request.id.uuidString,
                    "p_user_id": user.userID.uuidString,
                    "p_payment_id": paymentId,
                    "p_payment_amount": String(amount)
                ])
                .execute()
            
            print("✅ Payment recorded successfully")
            
            // Parse the response
            if let data = result.data as? Data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📊 Payment result: \(json)")
                
                // Notify completion handler
                await MainActor.run {
                    paymentCompletionHandler?(true, paymentId)
                    showPaymentSuccess = true
                    isProcessingPayment = false
                }
            }
            
            // Post notification to refresh UI
            NotificationCenter.default.post(
                name: .groupPaymentCompleted,
                object: nil,
                userInfo: [
                    "requestId": request.id,
                    "participantId": participant.id,
                    "paymentId": paymentId
                ]
            )
            
        } catch {
            print("❌ Error recording payment: \(error)")
            await MainActor.run {
                paymentError = "Payment succeeded but recording failed. Contact support with ID: \(paymentId)"
                paymentCompletionHandler?(false, nil)
                isProcessingPayment = false
            }
        }
    }
    
    /// Handle payment failure
    private func handlePaymentFailure(error: String) {
        print("❌ Payment failed: \(error)")
        
        Task { @MainActor in
            paymentError = error
            paymentCompletionHandler?(false, nil)
            isProcessingPayment = false
        }
    }
}

// MARK: - RazorpayProtocol Extension

extension GroupPaymentManager {
    
    nonisolated func onPaymentError(_ code: Int32, description str: String) {
        Task { @MainActor in
            print("❌ Razorpay payment error: \(str) (Code: \(code))")
            handlePaymentFailure(error: str)
        }
    }
    
    nonisolated func onPaymentSuccess(_ payment_id: String) {
        Task { @MainActor in
            print("✅ Razorpay payment successful: \(payment_id)")
            await recordPaymentSuccess(paymentId: payment_id)
        }
    }
}

// MARK: - Supporting Types

/// Summary of group payment status
struct GroupPaymentSummary {
    let requestId: UUID
    let totalParticipants: Int
    let paidParticipants: Int
    let pendingParticipants: Int
    let totalAmountCollected: Double
    let paymentDeadline: Date?
    let isComplete: Bool
    
    var paymentProgress: Double {
        guard totalParticipants > 0 else { return 0 }
        return Double(paidParticipants) / Double(totalParticipants)
    }
    
    var timeRemaining: TimeInterval? {
        guard let deadline = paymentDeadline else { return nil }
        return deadline.timeIntervalSinceNow
    }
    
    var hasExpired: Bool {
        guard let remaining = timeRemaining else { return false }
        return remaining < 0
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let groupPaymentCompleted = Notification.Name("groupPaymentCompleted")
    static let groupPaymentFailed = Notification.Name("groupPaymentFailed")
    static let groupActivated = Notification.Name("groupActivated")
}
