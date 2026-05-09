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
/// CRITICAL: Razorpay SDK must be initialized on the Main Thread for WebKit message handlers
@MainActor
class GroupPaymentManager: NSObject, ObservableObject, RazorpayPaymentCompletionProtocol {

    // MARK: - Singleton

    /// Shared instance - call `preWarm()` at app launch to ensure main thread initialization
    static let shared = GroupPaymentManager()

    // MARK: - Published Properties
    @Published var isProcessingPayment: Bool = false
    @Published var paymentError: String?
    @Published var showPaymentSuccess: Bool = false

    // MARK: - Private Properties
    private var razorpay: RazorpayCheckout?
    private let razorpayKey = "rzp_test_A9W91a51kUjKmX" // Reuse existing key

    // CRITICAL: Transparent overlay VC to isolate Razorpay from SwiftUI hierarchy
    // This prevents WKWebView/CheckoutBridge crashes caused by UIHostingController lifecycle
    private var paymentOverlayVC: UIViewController?

    // Current payment context
    private var currentRequest: Request?
    private var currentParticipant: RequestParticipant?
    private var currentEquipment: Equipment?
    private var currentUser: User?
    private var paymentCompletionHandler: ((Bool, String?) -> Void)?

    // MARK: - Initialization

    private override init() {
        super.init()
        print("🔄 [Razorpay] GroupPaymentManager singleton created")
        // NOTE: We no longer pre-initialize Razorpay here
        // A fresh instance is created for each payment to ensure CheckoutBridge is properly bound
    }

    /// Pre-warm is now a no-op - kept for backward compatibility
    /// Fresh Razorpay instances are created per-payment instead
    static func preWarm() {
        print("🚀 [Razorpay] PRE-WARM called (no-op - fresh instances used per payment)")
        _ = GroupPaymentManager.shared
    }

    // MARK: - View Controller Helpers (Simplified for Overlay Strategy)

    /// Get the basic topmost view controller from the window root
    /// We don't need complex traversal - we just need somewhere to present our overlay
    private func getWindowRootViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter({ $0.isKeyWindow }).first,
              let rootViewController = keyWindow.rootViewController else {
            print("⚠️ [Razorpay] No key window or root view controller found")
            return nil
        }

        // Find the topmost presented VC to present our overlay from
        var topVC = rootViewController
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        print("🔍 [Razorpay] Window root topmost VC: \(type(of: topVC))")
        return topVC
    }

    /// Open Razorpay checkout via dedicated UIKit ViewController
    /// This solves the CheckoutBridge error that occurs when calling from SwiftUI context
    private func openRazorpayInIsolatedOverlay(with options: [String: Any]) {
        print("═══════════════════════════════════════════")
        print("💳 [Razorpay] STATIC UI HANDOVER STRATEGY v6")
        print("   Settling UI after DB save before Razorpay presentation")
        print("   Thread: \(Thread.isMainThread ? "MAIN ✓" : "BACKGROUND ⚠️")")
        print("═══════════════════════════════════════════")

        // CRITICAL: Force 1.0 second delay to let SwiftUI finish any redraws from the DB save
        // This prevents UI churn from tearing down the display controller during Razorpay init
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            print("✅ [Razorpay] UI settled - finding topmost view controller")

            // Find the absolute highest root window
            let keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .filter { $0.isKeyWindow }.first

            guard let rootVC = keyWindow?.rootViewController else {
                print("❌ [Razorpay] No root view controller found")
                self.handlePaymentFailure(error: "Could not present payment UI")
                return
            }

            // Find the topmost presented VC from the root
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }

            print("🎯 [Razorpay] Presenting from topmost VC: \(type(of: topVC))")

            // Present the dedicated UIKit ViewController for Razorpay on the topmost VC
            // This provides a proper UIKit context for WKWebView initialization
            RazorpayPaymentViewController.presentOnViewController(
                topVC,
                with: options
            ) { [weak self] success, paymentId in
                guard let self = self else { return }

                if success, let paymentId = paymentId {
                    print("✅ [GroupPaymentManager] Payment successful via UIKit VC: \(paymentId)")
                    Task {
                        await self.recordPaymentSuccess(paymentId: paymentId)
                    }
                } else {
                    print("❌ [GroupPaymentManager] Payment failed or cancelled via UIKit VC")
                    self.handlePaymentFailure(error: "Payment failed or was cancelled")
                }
            }
        }
    }

    /// Clean up after payment completes
    private func dismissPaymentOverlay(completion: (() -> Void)? = nil) {
        // Clean up any state
        print("🧹 [Razorpay] Cleaning up...")
        self.razorpay = nil
        self.paymentOverlayVC = nil
        print("✅ [Razorpay] Cleanup complete")
        completion?()
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

        // MARK: - COD Payment Path
        // When Razorpay is disabled, skip payment gateway and record as COD
        if !FeatureFlags.isRazorpayEnabled {
            print("💵 [GroupPaymentManager] Processing as Cash on Delivery (Razorpay disabled)")
            let codPaymentId = "COD-\(UUID().uuidString.prefix(8))"
            Task {
                await self.recordPaymentSuccess(paymentId: codPaymentId)
            }
            return
        }

        // MARK: - Future Razorpay Integration
        // The following Razorpay payment flow is preserved for future releases.
        // Set FeatureFlags.isRazorpayEnabled = true to re-enable.

        // Create Razorpay order securely via Edge Function, then open checkout
        Task {
            do {
                // Step 1: Create order via Edge Function (with Auth Hold)
                let orderId = try await SupabaseManager.shared.createRazorpayOrder(
                    amount: amount,
                    notes: [
                        "bookingType": "coequip_group",
                        "requestId": request.id.uuidString,
                        "participantId": participant.id.uuidString,
                        "userId": user.userID.uuidString,
                        "equipmentId": equipment.equipmentID.uuidString
                    ]
                )

                print("✅ Received order_id from Edge Function: \(orderId)")

                // Step 2: Prepare Razorpay checkout options with secure order_id
                let options: [String: Any] = [
                    "order_id": orderId, // Secure order_id from backend
                    "amount": String(Int(amount * 100)), // Amount in paise (for reference)
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

                // Step 3: Open Razorpay in isolated overlay (prevents SwiftUI crashes)
                print("💳 Opening Razorpay with order_id: \(orderId), amount: ₹\(amount)")
                self.openRazorpayInIsolatedOverlay(with: options)

            } catch {
                // Handle Edge Function error
                await MainActor.run {
                    print("❌ Failed to create Razorpay order: \(error.localizedDescription)")
                    self.paymentError = "Failed to initialize payment: \(error.localizedDescription)"
                    self.isProcessingPayment = false
                    completion(false, nil)
                }
            }
        }

        // Note: Processing flag will be reset in Razorpay callbacks
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

    /// Initiate immediate payment when a farmer confirms joining a group
    /// Uses Auth Hold to reserve funds without immediate capture
    /// - Parameters:
    ///   - request: The group request being joined
    ///   - participant: The participant's details (including area)
    ///   - equipment: The equipment being booked
    ///   - user: The current user joining
    ///   - completion: Callback with success status and optional payment ID
    func initiateJoinPayment(
        request: Request,
        participant: RequestParticipant,
        equipment: Equipment,
        user: User,
        completion: @escaping (Bool, String?) -> Void
    ) {
        print("🔄 Initiating join payment (Auth Hold) for request: \(request.id)")

        // Calculate amount based on participant's field area
        guard let fieldArea = participant.area, fieldArea > 0 else {
            completion(false, "Invalid field area")
            return
        }

        let amount = equipment.pricePerAcre * fieldArea
        print("💰 Calculated payment amount: ₹\(amount) (Area: \(fieldArea) acres × ₹\(equipment.pricePerAcre)/acre)")

        // Check if user already has a payment hold
        if participant.paymentStatus == .paid {
            completion(false, "You have already authorized payment for this group")
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

        // MARK: - COD Payment Path
        // When Razorpay is disabled, skip payment gateway and record as COD
        if !FeatureFlags.isRazorpayEnabled {
            print("💵 [GroupPaymentManager] Processing join payment as Cash on Delivery (Razorpay disabled)")
            let codPaymentId = "COD-\(UUID().uuidString.prefix(8))"
            Task {
                await self.recordPaymentSuccess(paymentId: codPaymentId)
            }
            return
        }

        // MARK: - Future Razorpay Integration
        // The following Razorpay payment flow is preserved for future releases.
        // Set FeatureFlags.isRazorpayEnabled = true to re-enable.

        // Create Razorpay order with Auth Hold via Edge Function
        Task {
            do {
                // Step 1: Create order via Edge Function (payment_capture: 0 = Auth Hold)
                let orderId = try await SupabaseManager.shared.createRazorpayOrder(
                    amount: amount,
                    notes: [
                        "bookingType": "coequip_join",
                        "paymentType": "auth_hold",
                        "requestId": request.id.uuidString,
                        "participantId": participant.id.uuidString,
                        "userId": user.userID.uuidString,
                        "equipmentId": equipment.equipmentID.uuidString,
                        "fieldArea": String(fieldArea),
                        "pricePerAcre": String(equipment.pricePerAcre)
                    ]
                )

                print("✅ Auth Hold order created: \(orderId)")

                // Step 2: Prepare Razorpay checkout options
                let options: [String: Any] = [
                    "order_id": orderId,
                    "amount": String(Int(amount * 100)), // Amount in paise
                    "currency": "INR",
                    "description": "CoEquip Join - \(equipment.name) (\(String(format: "%.2f", fieldArea)) acres)",
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
                        "bookingType": "coequip_join",
                        "paymentType": "auth_hold",
                        "requestId": request.id.uuidString,
                        "participantId": participant.id.uuidString,
                        "userId": user.userID.uuidString,
                        "equipmentId": equipment.equipmentID.uuidString
                    ]
                ]

                // Step 3: Open Razorpay in isolated overlay (prevents SwiftUI crashes)
                print("💳 Opening Razorpay Auth Hold for ₹\(amount)")
                self.openRazorpayInIsolatedOverlay(with: options)

            } catch {
                await MainActor.run {
                    print("❌ Failed to create Auth Hold order: \(error.localizedDescription)")
                    self.paymentError = "Failed to initialize payment: \(error.localizedDescription)"
                    self.isProcessingPayment = false
                    completion(false, nil)
                }
            }
        }
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

    // Note: These delegate methods are kept for backward compatibility
    // but won't be called when using RazorpayPaymentViewController
    // The UIKit VC has its own delegate implementation

    nonisolated func onPaymentError(_ code: Int32, description str: String) {
        Task { @MainActor in
            print("❌ [GroupPaymentManager] Razorpay delegate onPaymentError: \(str) (Code: \(code))")
            self.handlePaymentFailure(error: str)
        }
    }

    nonisolated func onPaymentSuccess(_ payment_id: String) {
        Task { @MainActor in
            print("✅ [GroupPaymentManager] Razorpay delegate onPaymentSuccess: \(payment_id)")
            await self.recordPaymentSuccess(paymentId: payment_id)
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
