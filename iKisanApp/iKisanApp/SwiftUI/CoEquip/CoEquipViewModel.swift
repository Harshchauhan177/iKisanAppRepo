//
//  CoEquipViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 25/12/25.
//

import SwiftUI
import Combine

/// Request status enum matching the existing UIKit implementation
enum CoEquipRequestStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

/// Data model for a Co-Equip request
struct CoEquipRequest: Identifiable, Hashable {
    let id: UUID
    let equipmentName: String
    let equipmentImageURL: String
    let location: String
    let date: Date
    let joinedUsersCount: Int
    let status: CoEquipRequestStatus
    let creatorName: String? // Name of the user who created the request (for join requests)
    let creatorId: UUID? // ID of the creator for fetching
    let underlyingRequest: Request? // Store the full Request object for navigation
    let hasJoined: Bool // Whether the current user has already accepted this request
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM"
        return formatter.string(from: date)
    }
    
    // Custom hash and equality to exclude underlyingRequest
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CoEquipRequest, rhs: CoEquipRequest) -> Bool {
        lhs.id == rhs.id
    }
}

/// ViewModel managing Co-Equip requests data and business logic
@MainActor
class CoEquipViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var myRequests: [CoEquipRequest] = []
    @Published var joinRequests: [CoEquipRequest] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedTab: CoEquipTab = .myRequests
    
    // Join request modal properties
    @Published var showJoinInputSheet: Bool = false
    @Published var selectedRequestForJoin: CoEquipRequest?
    
    // MARK: - Dependencies
    
    private(set) var dataController: DataController? // Changed from private weak to internal
    private var cancellables = Set<AnyCancellable>()
    private var isLoadingData = false // Flag to prevent recursive loading
    
    // MARK: - Tab Selection
    
    enum CoEquipTab: String, CaseIterable {
        case myRequests = "My Requests"
        case joinRequests = "Join Requests"
    }
    
    // MARK: - Initialization
    
    init(dataController: DataController? = nil) {
        self.dataController = dataController
        setupNotificationObservers()
        
        // Don't load data immediately - wait for .dataInitiallyLoaded notification
        // This prevents race conditions with the DataController's async init
    }
    
    // MARK: - Notification Observers
    
    private func setupNotificationObservers() {
        // Listen for data updates
        NotificationCenter.default.publisher(for: .requestsUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self, !self.isLoadingData else { return }
                Task { @MainActor in
                    // Only reload local data without triggering backend fetch
                    await self.reloadLocalData()
                }
            }
            .store(in: &cancellables)
        
        // Listen for initial data load completion
        NotificationCenter.default.publisher(for: .dataInitiallyLoaded)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    print("📥 Received dataInitiallyLoaded notification")
                    // Load the initially fetched data
                    await self.reloadLocalData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    /// Load requests from DataController (with backend fetch)
    func loadRequests() async {
        // Prevent recursive calls
        guard !isLoadingData else {
            print("⚠️ loadRequests skipped - already loading")
            return
        }
        
        guard let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else {
            print("❌ loadRequests failed - no dataController or currentUser")
            errorMessage = "Unable to load user data. Please log in again."
            return
        }
        
        print("🔄 loadRequests - Starting for user: \(currentUser.name)")
        
        isLoadingData = true
        isLoading = true
        errorMessage = nil
        
        // Load data from backend
        await dataController.loadDataFromBackend()
        print("✅ Backend data loaded")
        
        // Process local data
        await processRequests(currentUser: currentUser)
        
        isLoading = false
        isLoadingData = false
        
        print("✅ loadRequests complete - myRequests: \(myRequests.count), joinRequests: \(joinRequests.count)")
    }
    
    /// Reload data from local cache (without backend fetch)
    private func reloadLocalData() async {
        // Prevent recursive calls
        guard !isLoadingData else { return }
        
        guard let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else {
            return
        }
        
        isLoadingData = true
        
        // Process local data without triggering backend fetch
        await processRequests(currentUser: currentUser)
        
        isLoadingData = false
    }
    
    /// Process requests from DataController
    private func processRequests(currentUser: User) async {
        guard let dataController = dataController else { return }
        
        let allRequests = dataController.getAllCoEquipRequests()
        
        print("🔍 CoEquipViewModel - Processing requests")
        print("   Total requests fetched: \(allRequests.count)")
        print("   Current user ID: \(currentUser.userID)")
        print("   Current user name: \(currentUser.name)")
        print("")
        
        // Debug: Print all requests with their participants
        for (index, request) in allRequests.enumerated() {
            let isCreator = request.userId == currentUser.userID
            print("📋 Request \(index + 1): \(request.id.uuidString.prefix(8))...")
            print("   Creator ID: \(request.userId.uuidString.prefix(8))... \(isCreator ? "(YOU)" : "")")
            print("   Type: \(request.typeOfRequest)")
            print("   Status: \(request.status)")
            
            if let participants = request.participants, !participants.isEmpty {
                print("   Participants: \(participants.count)")
                var foundCurrentUser = false
                for participant in participants {
                    let isCurrentUser = participant.userId == currentUser.userID
                    if isCurrentUser { foundCurrentUser = true }
                    print("     - User: \(participant.userId.uuidString.prefix(8))... \(isCurrentUser ? "⭐ (YOU)" : "")")
                    print("       Status: \(participant.status)")
                }
                if !foundCurrentUser && !isCreator {
                    print("   ⚠️ Current user is NOT a participant and NOT the creator!")
                }
            } else {
                print("   ⚠️ Participants: NONE (empty array or nil)")
            }
            
            if let acceptedUsers = request.acceptedUsers, !acceptedUsers.isEmpty {
                print("   Accepted Users: \(acceptedUsers.count)")
                for userId in acceptedUsers {
                    let isCurrentUser = userId == currentUser.userID
                    print("     - \(userId.uuidString.prefix(8))...\(isCurrentUser ? " ⭐ (YOU)" : "")")
                }
            }
            print("")
        }
        
        // Process my requests
        let myRequestsData = allRequests
            .filter { request in
                request.userId == currentUser.userID &&
                request.typeOfRequest == .myRequest
            }
            .sorted { $0.requestedDate > $1.requestedDate }
        
        print("✅ My requests count: \(myRequestsData.count)")
        
        // Process join requests - Show requests where current user is invited as a participant
        // An invited farmer should see the creator's request because they are listed as a participant
        let joinRequestsData = allRequests
            .filter { request in
                // Must NOT be created by current user (those go in My Requests)
                guard request.userId != currentUser.userID else {
                    return false
                }
                
                // Check if user is a participant with pending OR done status
                let isParticipant = request.participants?.contains { participant in
                    participant.userId == currentUser.userID && 
                    (participant.status == .pending || participant.status == .done)
                } ?? false
                
                // Also check acceptedUsers array as backup mechanism
                let isInAcceptedUsers = request.acceptedUsers?.contains(currentUser.userID) ?? false
                
                let shouldShow = isParticipant || isInAcceptedUsers
                
                if shouldShow {
                    print("  ✅ Including request \(request.id.uuidString.prefix(8)) - isParticipant: \(isParticipant), participants count: \(request.participants?.count ?? 0)")
                }
                
                return shouldShow
            }
            .sorted { $0.requestedDate > $1.requestedDate }
        
        print("✅ Join requests count: \(joinRequestsData.count)")
        
        // Debug: Show why each request was included/excluded
        if joinRequestsData.isEmpty && !allRequests.isEmpty {
            print("⚠️ DEBUG: No join requests found. Analyzing all requests:")
            for request in allRequests {
                let isCreator = request.userId == currentUser.userID
                let participantInfo = request.participants?.filter { $0.userId == currentUser.userID }.map { "status: \($0.status)" }.joined(separator: ", ") ?? "none"
                let inAcceptedUsers = request.acceptedUsers?.contains(currentUser.userID) ?? false
                print("  Request \(request.id): creator=\(isCreator), participants=[\(participantInfo)], inAcceptedUsers=\(inAcceptedUsers)")
            }
        }
        
        // Convert to CoEquipRequest format
        myRequests = await convertToCoEquipRequests(myRequestsData, dataController: dataController)
        joinRequests = await convertToCoEquipRequests(joinRequestsData, dataController: dataController)
    }
    
    /// Refresh data (for pull-to-refresh)
    func refreshData() async {
        await loadRequests()
    }
    
    // MARK: - Helper Methods
    
    /// Convert Request objects to CoEquipRequest display models
    private func convertToCoEquipRequests(_ requests: [Request], dataController: DataController) async -> [CoEquipRequest] {
        var coEquipRequests: [CoEquipRequest] = []
        
        // Get current user to check joined status
        guard let currentUser = dataController.getCurrentUser() else {
            return []
        }
        
        for request in requests {
            // Get equipment details
            guard let equipment = dataController.getEquipmentById(request.equipmentId) else {
                continue
            }
            
            // Count joined users (participants with done status - database uses "done" not "accepted")
            let joinedCount = request.participants?.filter { 
                $0.status == .done 
            }.count ?? 0
            
            // Check if current user has joined (has done status - database uses "done" not "accepted")
            let hasJoined = request.participants?.contains { 
                $0.userId == currentUser.userID && $0.status == .done 
            } ?? false
            
            // Get creator name (for join requests)
            let creatorName = dataController.getUserById(request.userId)?.name
            
            // Map booking status to CoEquipRequestStatus
            let status: CoEquipRequestStatus
            switch request.status {
            case .pending:
                status = .pending
            case .confirmed:
                status = .confirmed
            case .completed:
                status = .completed
            case .awaitingProvider:
                status = .pending // Map to pending as it's still waiting
            case .collectingPayment:
                status = .confirmed // Map to confirmed as provider accepted
            case .active:
                status = .confirmed // Map to confirmed as it's active
            }
            
            let coEquipRequest = CoEquipRequest(
                id: request.id,
                equipmentName: equipment.name,
                equipmentImageURL: equipment.equipmentImage,
                location: request.location,
                date: request.requestedDate,
                joinedUsersCount: joinedCount,
                status: status,
                creatorName: creatorName,
                creatorId: request.userId,
                underlyingRequest: request,
                hasJoined: hasJoined
            )
            
            coEquipRequests.append(coEquipRequest)
        }
        
        return coEquipRequests
    }
    
    // MARK: - Computed Properties
    
    var currentRequests: [CoEquipRequest] {
        selectedTab == .myRequests ? myRequests : joinRequests
    }
    
    // MARK: - Actions
    
    /// Initiates the accept request flow by showing the input modal
    func acceptRequest(_ request: CoEquipRequest) {
        print("🟢 [CoEquipVM] Initiating accept flow for request: \(request.id)")
        selectedRequestForJoin = request
        showJoinInputSheet = true
    }
    
    /// Confirms join with the specified field area
    /// Called from JoinRequestInputViewModel after validation
    func confirmJoin(request: CoEquipRequest, fieldArea: Double) async {
        print("🟢 [CoEquipVM] Confirming join for request: \(request.id), area: \(fieldArea)")
        
        guard let dataController = dataController else {
            print("❌ [CoEquipVM] DataController not available")
            errorMessage = "Unable to process request"
            return
        }
        
        guard let currentUser = dataController.getCurrentUser() else {
            print("❌ [CoEquipVM] No current user")
            errorMessage = "User not logged in"
            return
        }
        
        // Find the original Request object
        let allRequests = dataController.getAllCoEquipRequests()
        guard var originalRequest = allRequests.first(where: { $0.id == request.id }) else {
            print("❌ Could not find original request")
            errorMessage = "Request not found"
            return
        }
        
        // Store original state for rollback
        let originalParticipants = originalRequest.participants
        
        // OPTIMISTIC UPDATE: Update local UI immediately
        print("🔄 [CoEquipVM] Starting optimistic update...")
        
        // Find or create participant entry
        if var participants = originalRequest.participants {
            // Find participant entry for current user
            if let index = participants.firstIndex(where: { $0.userId == currentUser.userID }) {
                // Update existing participant - use .done status (matches database enum)
                participants[index].status = .done
                participants[index].area = fieldArea
                print("✅ [CoEquipVM] Updated existing participant with area: \(fieldArea) and status: done")
            } else {
                // This shouldn't happen since they got the invite, but handle it
                let newParticipant = RequestParticipant(
                    id: UUID(),
                    requestId: originalRequest.id,
                    userId: currentUser.userID,
                    status: .done, // Use .done status (matches database enum)
                    area: fieldArea,
                    timeSlot: nil, // Will be assigned by backend or later
                    joinedAt: Date()
                )
                participants.append(newParticipant)
                print("✅ [CoEquipVM] Created new participant with area: \(fieldArea) and status: done")
            }
            originalRequest.participants = participants
        } else {
            // Create participants array with this user
            let newParticipant = RequestParticipant(
                id: UUID(),
                requestId: originalRequest.id,
                userId: currentUser.userID,
                status: .done, // Use .done status (matches database enum)
                area: fieldArea,
                timeSlot: nil,
                joinedAt: Date()
            )
            originalRequest.participants = [newParticipant]
            print("✅ [CoEquipVM] Created participants array with new participant and status: done")
        }
        
        // Update local cache immediately for instant UI feedback
        await processRequests(currentUser: currentUser)
        
        print("🌐 [CoEquipVM] Sending update to backend...")
        
        // Update request in backend
        let success = await dataController.updateRequest(originalRequest)
        
        if success {
            print("✅ [CoEquipVM] Successfully accepted request in backend")
            
            // Close the modal
            showJoinInputSheet = false
            selectedRequestForJoin = nil
            
            // Reload data to ensure we have latest from backend
            await reloadLocalData()
        } else {
            print("❌ [CoEquipVM] Failed to update request in backend - ROLLING BACK")
            errorMessage = "Failed to join request. Please try again."
            
            // ROLLBACK: Restore original state
            var rolledBackRequest = originalRequest
            rolledBackRequest.participants = originalParticipants
            
            // Update local state to reflect rollback
            await processRequests(currentUser: currentUser)
        }
    }
    
    /// Reject a join request
    func rejectRequest(_ request: CoEquipRequest) {
        guard let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else {
            print("⚠️ CoEquipViewModel: Cannot reject - DataController or user not available")
            return
        }
        
        print("🚫 Reject request: \(request.equipmentName)")
        
        // Find the original Request object
        let allRequests = dataController.getAllCoEquipRequests()
        guard var originalRequest = allRequests.first(where: { $0.id == request.id }) else {
            print("❌ Could not find original request")
            return
        }
        
        // Remove participant from the request
        originalRequest.participants?.removeAll(where: { $0.userId == currentUser.userID })
        
        // Update in data controller
        Task {
            _ = await dataController.updateRequest(originalRequest)
        }
        
        print("✅ Request rejected successfully")
        
        // Reload local data
        Task {
            await reloadLocalData()
        }
    }
    
    // MARK: - Navigation
    
    /// Navigate to create request flow (select equipment)
    func navigateToCreateRequest() {
        print("➕ Navigate to create request")
        // This will be handled by the parent view/coordinator
    }
}
