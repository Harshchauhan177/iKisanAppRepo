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
        
        if dataController != nil {
            // Load from existing data without backend fetch
            Task {
                await reloadLocalData()
            }
        }
    }
    
    // MARK: - Notification Observers
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: .requestsUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    // Only reload data without triggering backend fetch
                    await self?.reloadLocalData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    /// Load requests from DataController (with backend fetch)
    func loadRequests() async {
        // Prevent recursive calls
        guard !isLoadingData else {
            print("⚠️ CoEquipViewModel: Already loading data, skipping")
            return
        }
        
        guard let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else {
            print("⚠️ CoEquipViewModel: DataController or current user not available")
            return
        }
        
        isLoadingData = true
        isLoading = true
        errorMessage = nil
        
        print("🔄 CoEquipViewModel: Loading requests from backend...")
        
        // Load data from backend
        await dataController.loadDataFromBackend()
        
        // Process local data
        await processRequests(currentUser: currentUser)
        
        isLoading = false
        isLoadingData = false
        
        print("✅ CoEquipViewModel: Loaded \(myRequests.count) my requests and \(joinRequests.count) join requests")
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
        
        print("🔄 CoEquipViewModel: Reloading from local data...")
        
        // Process local data without triggering backend fetch
        await processRequests(currentUser: currentUser)
        
        isLoadingData = false
        
        print("✅ CoEquipViewModel: Reloaded \(myRequests.count) my requests and \(joinRequests.count) join requests")
    }
    
    /// Process requests from DataController
    private func processRequests(currentUser: User) async {
        guard let dataController = dataController else { return }
        
        let allRequests = dataController.getAllCoEquipRequests()
        
        // Process my requests
        let myRequestsData = allRequests
            .filter { request in
                request.userId == currentUser.userID &&
                request.typeOfRequest == .myRequest
            }
            .sorted { $0.requestedDate > $1.requestedDate }
        
        // Process join requests (pending only)
        let joinRequestsData = allRequests
            .filter { request in
                request.participants?.contains { participant in
                    participant.userId == currentUser.userID && participant.status == .pending
                } ?? false
            }
            .sorted { $0.requestedDate > $1.requestedDate }
        
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
        
        for request in requests {
            // Get equipment details
            guard let equipment = dataController.getEquipmentById(request.equipmentId) else {
                continue
            }
            
            // Count joined users (participants with accepted or done status)
            let joinedCount = request.participants?.filter { 
                $0.status == .accepted || $0.status == .done 
            }.count ?? 0
            
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
                underlyingRequest: request
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
    
    /// Accept a join request
    func acceptRequest(_ request: CoEquipRequest) {
        guard let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else {
            print("⚠️ CoEquipViewModel: Cannot accept - DataController or user not available")
            return
        }
        
        print("✅ Accept request: \(request.equipmentName)")
        
        // Find the original Request object
        let allRequests = dataController.getAllCoEquipRequests()
        guard var originalRequest = allRequests.first(where: { $0.id == request.id }) else {
            print("❌ Could not find original request")
            return
        }
        
        // Update participant status to accepted
        if let participantIndex = originalRequest.participants?.firstIndex(where: { $0.userId == currentUser.userID }) {
            originalRequest.participants?[participantIndex].status = .accepted
            
            // Update in data controller
            dataController.updateRequest(originalRequest)
            
            print("✅ Request accepted successfully")
            
            // Reload local data
            Task {
                await reloadLocalData()
            }
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
        dataController.updateRequest(originalRequest)
        
        print("✅ Request rejected successfully")
        
        // Reload local data
        Task {
            await reloadLocalData()
        }
    }
}
