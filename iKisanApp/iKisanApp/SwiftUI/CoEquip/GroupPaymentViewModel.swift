//
//  GroupPaymentViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 13/01/26.
//  ViewModel for Group Payment workflow
//

import Foundation
import SwiftUI
import Combine

@MainActor
class GroupPaymentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var request: Request
    @Published var equipment: Equipment
    @Published var participants: [RequestParticipant] = []
    @Published var participantsWithUsers: [(participant: RequestParticipant, user: User?)] = []
    
    // Timer properties
    @Published var hoursRemaining: Int = 0
    @Published var minutesRemaining: Int = 0
    @Published var secondsRemaining: Int = 0
    @Published var timeProgress: Double = 1.0
    
    // UI State
    @Published var isProcessingPayment: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false
    
    // MARK: - Private Properties
    private var countdownTimer: Timer?
    private var dataRefreshTimer: Timer?
    private let dataController: IKisanDataController?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var currentUserId: UUID {
        // Get current user ID from AuthManager or DataController
        if let authUser = AuthManager.shared.currentUser {
            return authUser.id
        }
        return dataController?.getCurrentUser()?.userID ?? UUID()
    }
    
    var currentUserParticipant: RequestParticipant? {
        participants.first { $0.userId == currentUserId }
    }
    
    var currentUserPaymentStatus: PaymentStatus {
        currentUserParticipant?.paymentStatus ?? .pending
    }
    
    var canPay: Bool {
        guard let participant = currentUserParticipant else { return false }
        return participant.paymentStatus == .pending && 
               request.status == BookingStatus.collectingPayment &&
               !request.hasPaymentExpired
    }
    
    var showCountdown: Bool {
        request.status == BookingStatus.collectingPayment && 
        request.paymentDeadline != nil &&
        !request.hasPaymentExpired
    }
    
    var paymentAmount: Double {
        guard let participant = currentUserParticipant,
              let area = participant.area else {
            return 0
        }
        return equipment.pricePerAcre * area
    }
    
    var totalCount: Int {
        participants.count
    }
    
    var paidCount: Int {
        participants.filter { $0.paymentStatus == .paid }.count
    }
    
    var paymentProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(paidCount) / Double(totalCount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM"
        return formatter.string(from: request.requestedDate)
    }
    
    var timeRemainingColor: Color {
        let remaining = request.timeRemainingForPayment ?? 0
        if remaining > 7200 { // > 2 hours
            return .green
        } else if remaining > 3600 { // > 1 hour
            return .orange
        } else {
            return .red
        }
    }
    
    var paymentStatusColor: Color {
        switch currentUserPaymentStatus {
        case .paid: return .green
        case .pending: return .orange
        case .failed: return .red
        case .refunded: return .blue
        }
    }
    
    // MARK: - Initialization
    
    init(request: Request, equipment: Equipment) {
        self.request = request
        self.equipment = equipment
        self.participants = request.participants ?? []
        
        // Get DataController
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            self.dataController = sceneDelegate.dataController as? IKisanDataController
        } else {
            self.dataController = nil
        }
        
        loadParticipantUsers()
        updateCountdown()
        
        // Subscribe to payment notifications
        NotificationCenter.default.publisher(for: .groupPaymentCompleted)
            .sink { [weak self] notification in
                self?.handlePaymentCompleted(notification)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        // Start countdown timer (updates every second)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateCountdown()
            }
        }
        
        // Start data refresh timer (refresh every 30 seconds)
        dataRefreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refreshGroupData()
            }
        }
        
        print("✅ Started monitoring group payment")
    }
    
    func stopMonitoring() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        dataRefreshTimer?.invalidate()
        dataRefreshTimer = nil
        print("🛑 Stopped monitoring group payment")
    }
    
    func initiatePayment() {
        guard let participant = currentUserParticipant else {
            errorMessage = "Unable to initiate payment. Please try again."
            showError = true
            return
        }
        
        // Get User from DataController (not AuthUser)
        guard let user = dataController?.getCurrentUser() else {
            errorMessage = "Unable to get user information. Please login again."
            showError = true
            return
        }
        
        isProcessingPayment = true
        
        GroupPaymentManager.shared.initiateGroupPayment(
            request: request,
            participant: participant,
            equipment: equipment,
            user: user,
            amount: paymentAmount
        ) { [weak self] success, paymentId in
            Task { @MainActor [weak self] in
                self?.isProcessingPayment = false
                
                if success {
                    self?.showSuccess = true
                    // Refresh data to show updated payment status
                    await self?.refreshGroupData()
                } else {
                    self?.errorMessage = "Payment failed. Please try again."
                    self?.showError = true
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateCountdown() {
        guard let deadline = request.paymentDeadline else {
            hoursRemaining = 0
            minutesRemaining = 0
            secondsRemaining = 0
            timeProgress = 0
            return
        }
        
        let remaining = deadline.timeIntervalSinceNow
        
        if remaining <= 0 {
            // Time expired
            hoursRemaining = 0
            minutesRemaining = 0
            secondsRemaining = 0
            timeProgress = 0
        } else {
            let totalSeconds = Int(remaining)
            hoursRemaining = totalSeconds / 3600
            minutesRemaining = (totalSeconds % 3600) / 60
            secondsRemaining = totalSeconds % 60
            
            // Calculate progress (4 hours = 14400 seconds)
            let totalDeadlineSeconds: TimeInterval = 4 * 3600
            timeProgress = remaining / totalDeadlineSeconds
        }
    }
    
    private func loadParticipantUsers() {
        participantsWithUsers = participants.compactMap { participant in
            let user = dataController?.getUserById(participant.userId)
            return (participant: participant, user: user)
        }
    }
    
    private func refreshGroupData() async {
        print("🔄 Refreshing group payment data...")
        
        guard let dataController = dataController else { return }
        
        // Fetch fresh request data with participants
        if let freshRequest = await fetchRequestWithParticipants(requestId: request.id) {
            request = freshRequest
            participants = freshRequest.participants ?? []
            loadParticipantUsers()
            
            print("✅ Group data refreshed. Status: \(request.status), Paid: \(paidCount)/\(totalCount)")
            
            // Check if group is now active
            if request.status == .active {
                // Post notification
                NotificationCenter.default.post(
                    name: .groupActivated,
                    object: nil,
                    userInfo: ["requestId": request.id]
                )
            }
        }
    }
    
    private func fetchRequestWithParticipants(requestId: UUID) async -> Request? {
        do {
            // Fetch from Supabase with participants JOIN
            struct RequestWithParticipantsDTO: Codable {
                let id: UUID
                let userId: UUID
                let equipmentId: UUID
                let requestedDate: Date
                let status: String
                let type: String
                let area: Double
                let timeSlot: String
                let timePeriod: String?
                let location: String
                let typeOfRequest: String
                let paymentDeadline: Date?
                let request_participants: [ParticipantDTO]?
                
                struct ParticipantDTO: Codable {
                    let id: UUID
                    let requestId: UUID
                    let userId: UUID
                    let status: String
                    let area: Double?
                    let timeSlotId: String?
                    let joinedAt: Date
                    let paymentStatus: String?
                    let paymentId: String?
                    let paymentTimestamp: Date?
                    let paymentAmount: Double?
                }
            }
            
            let response: RequestWithParticipantsDTO = try await SupabaseManager.shared.client
                .from("requests")
                .select("*, request_participants(*)")
                .eq("id", value: requestId.uuidString)
                .single()
                .execute()
                .value
            
            // Convert DTO to Request model
            let participants = response.request_participants?.map { dto in
                RequestParticipant(
                    id: dto.id,
                    requestId: dto.requestId,
                    userId: dto.userId,
                    status: ParticipantStatus(rawValue: dto.status) ?? .pending,
                    area: dto.area,
                    timeSlot: dto.timeSlotId,
                    joinedAt: dto.joinedAt,
                    paymentStatus: PaymentStatus(rawValue: dto.paymentStatus ?? "pending") ?? .pending,
                    paymentId: dto.paymentId,
                    paymentTimestamp: dto.paymentTimestamp,
                    paymentAmount: dto.paymentAmount
                )
            } ?? []
            
            let request = Request(
                id: response.id,
                userId: response.userId,
                equipmentId: response.equipmentId,
                requestedDate: response.requestedDate,
                status: BookingStatus(rawValue: response.status) ?? .pending,
                type: BookingType(rawValue: response.type) ?? .coEquip,
                area: response.area,
                timeSlot: TimeSlot(rawValue: response.timeSlot) ?? .morning,
                timePeriod: response.timePeriod,
                location: response.location,
                typeOfRequest: RequestType.myRequest,
                participants: participants,
                paymentDeadline: response.paymentDeadline
            )
            
            return request
            
        } catch {
            print("❌ Error fetching request: \(error)")
            return nil
        }
    }
    
    private func handlePaymentCompleted(_ notification: Notification) {
        guard let requestId = notification.userInfo?["requestId"] as? UUID,
              requestId == request.id else {
            return
        }
        
        print("🔔 Payment completed notification received")
        
        Task {
            await refreshGroupData()
        }
    }
}
