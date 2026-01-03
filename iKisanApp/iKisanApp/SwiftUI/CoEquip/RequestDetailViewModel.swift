//
//  RequestDetailViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 26/12/25.
//

import SwiftUI
import Combine

/// ViewModel for Request Detail view
/// Manages request data, user interactions, and business logic
@MainActor
class RequestDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showConfirmation: Bool = false
    @Published var confirmationMessage: String = ""
    @Published var confirmationAction: ConfirmationAction = .accept
    @Published var showModifySheet: Bool = false
    @Published var showEquipmentDetail: Bool = false
    
    // MARK: - Dependencies
    
    let request: Request // Changed from private to internal for ModifyRequestView access
    let dataController: DataController? // Changed from private to internal
    private weak var coordinator: CoEquipNavigationCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // Cache for frequently accessed data
    private var _cachedEquipment: Equipment?
    private var cachedRequester: User?
    private var cachedProvider: User?
    
    // Public accessor for cached equipment (needed for navigation)
    var cachedEquipment: Equipment? {
        return _cachedEquipment
    }
    
    // MARK: - Initialization
    
    init(request: Request, dataController: DataController?, coordinator: CoEquipNavigationCoordinator? = nil) {
        self.request = request
        self.dataController = dataController
        self.coordinator = coordinator
        
        // Pre-fetch and cache data to avoid repeated lookups
        self._cachedEquipment = dataController?.getEquipmentById(request.equipmentId)
        self.cachedRequester = dataController?.getUserById(request.userId)
        
        if let equipment = _cachedEquipment {
            self.cachedProvider = dataController?.getUserById(equipment.providerID)
        }
        
        // Setup observers for data updates
        setupDataObservers()
    }
    
    // MARK: - Data Observers
    
    private func setupDataObservers() {
        // Listen for data updates from backend
        NotificationCenter.default.publisher(for: .requestsUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshCachedData()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .equipmentUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshCachedData()
            }
            .store(in: &cancellables)
    }
    
    private func refreshCachedData() {
        // Refresh cached data when updates occur
        _cachedEquipment = dataController?.getEquipmentById(request.equipmentId)
        cachedRequester = dataController?.getUserById(request.userId)
        
        if let equipment = _cachedEquipment {
            cachedProvider = dataController?.getUserById(equipment.providerID)
        }
        
        // Trigger view update
        objectWillChange.send()
    }
    
    // MARK: - Computed Properties - Equipment Details
    
    var equipmentImageURL: String {
        // Return real equipment image URL from cached data
        return _cachedEquipment?.equipmentImage ?? ""
    }
    
    var equipmentName: String {
        // Return real equipment name from cached data
        return _cachedEquipment?.name ?? "Unknown Equipment"
    }
    
    var equipmentType: String {
        // Return real equipment type from cached data
        return _cachedEquipment?.type ?? "N/A"
    }
    
    var equipmentCapacity: String {
        // Return real equipment capacity from cached data
        return _cachedEquipment?.capacity ?? "N/A"
    }
    
    var equipmentProviderName: String? {
        // Return real provider name from cached data
        return cachedProvider?.name
    }
    
    // MARK: - Computed Properties - Request Details
    
    var statusText: String {
        switch request.status {
        case .pending:
            return "Pending"
        case .confirmed:
            return "Accepted"
        case .completed:
            return "Completed"
//        case .cancelled:
//            return "Cancelled"
        }
    }
    
    var statusColor: Color {
        switch request.status {
        case .pending:
            return .orange
        case .confirmed:
            return Color(red: 0.298, green: 0.498, blue: 0.345) // iKisan green
        case .completed:
            return .blue
//        case .cancelled:
//            return .red
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter.string(from: request.requestedDate)
    }
    
    var timeSlotText: String {
        switch request.timeSlot {
        case .morning:
            return "Morning"
        case .afternoon:
            return "Afternoon"
        case .evening:
            return "Evening"
//        case .night:
//            return "Night"
//        case .fullDay:
//            return "Full Day"
        }
    }
    
    var timePeriod: String? {
        return request.timePeriod
    }
    
    var location: String {
        return request.location
    }
    
    // MARK: - Computed Properties - User Info
    
    var isMyRequest: Bool {
        // Check against real current user from AuthManager
        guard let currentUser = AuthManager.shared.currentUser else {
            return false
        }
        return request.userId == currentUser.id
    }
    
    var requesterName: String {
        // Return real requester name from cached data
        return cachedRequester?.name ?? "Unknown User"
    }
    
    var requesterPhone: String? {
        // Return real phone number if available
        return cachedRequester?.phone
    }
    
    // MARK: - Computed Properties - Participants
    
    struct ParticipantInfo: Identifiable {
        let id: UUID
        let userId: UUID
        let name: String
        let area: Double?
        let timeSlot: String?
        let status: ParticipantStatus
    }
    
    var participants: [ParticipantInfo] {
        // Fetch real participants from request data
        guard let requestParticipants = request.participants else {
            return []
        }
        
        // Only show participants who have completed joining (status = .done)
        return requestParticipants.compactMap { participant in
            guard participant.status == .done,
                  let user = dataController?.getUserById(participant.userId) else {
                return nil
            }
            
            return ParticipantInfo(
                id: participant.id,
                userId: participant.userId,
                name: user.name,
                area: participant.area,
                timeSlot: participant.timeSlot,
                status: participant.status
            )
        }
    }
    
    var hasParticipants: Bool {
        // Check if there are any completed participants
        return !participants.isEmpty
    }
    
    var participantCount: Int {
        // Count of completed participants only
        return participants.count
    }
    
    // MARK: - Joined Farmers (for My Requests)
    
    /// Farmers who have joined (accepted or confirmed) the request
    var joinedFarmers: [ParticipantInfo] {
        guard isMyRequest, let requestParticipants = request.participants else {
            return []
        }
        
        // Fetch real participant data with their user information
        let farmers = requestParticipants.compactMap { participant -> ParticipantInfo? in
            // Only exclude rejected participants (show pending, accepted, and done)
            guard participant.status != .rejected else {
                return nil
            }
            
            // Fetch real user data from DataController
            guard let user = dataController?.getUserById(participant.userId) else {
                return nil
            }
            
            return ParticipantInfo(
                id: participant.id,
                userId: participant.userId,
                name: user.name,
                area: participant.area,
                timeSlot: participant.timeSlot,
                status: participant.status
            )
        }
        
        return farmers
    }
    
    var hasJoinedFarmers: Bool {
        return !joinedFarmers.isEmpty
    }
    
    var joinedFarmersCount: Int {
        return joinedFarmers.count
    }
    
    // MARK: - Computed Properties - Area and Pricing
    
    var minimumAreaText: String {
        // Return real minimum area from request
        return String(format: "%.2f acres", request.area)
    }
    
    var currentTotalAreaText: String {
        // Calculate total area from real joined farmers data
        let total = joinedFarmers.reduce(0.0) { $0 + ($1.area ?? 0.0) }
        return String(format: "%.2f acres", total)
    }
    
    var yourAreaText: String? {
        // Return current user's area from real participant data
        guard let currentUser = AuthManager.shared.currentUser,
              let participant = request.participants?.first(where: { $0.userId == currentUser.id }),
              let area = participant.area else {
            return nil
        }
        return String(format: "%.2f acres", area)
    }
    
    var pricePerAcreText: String {
        // Return real price from cached equipment data
        guard let equipment = _cachedEquipment else {
            return "N/A"
        }
        return "₹\(Int(equipment.pricePerAcre))"
    }
    
    var estimatedTotalPrice: String? {
        // Calculate total price from real data
        guard let equipment = _cachedEquipment else {
            return nil
        }
        
        let area: Double
        if isMyRequest {
            // For creator: sum all joined farmers' areas
            area = joinedFarmers.reduce(0.0) { $0 + ($1.area ?? 0.0) }
        } else {
            // For participant: show only their area cost
            guard let currentUser = AuthManager.shared.currentUser,
                  let participant = request.participants?.first(where: { $0.userId == currentUser.id }),
                  let participantArea = participant.area else {
                return nil
            }
            area = participantArea
        }
        
        let total = equipment.pricePerAcre * area
        return "₹\(Int(total))"
    }
    
    // MARK: - Action Capabilities
    
    var showActions: Bool {
        return canModify || canAccept || canDecline || canDelete || canViewEquipment
    }
    
    var canModify: Bool {
        return isMyRequest && request.status == .pending
    }
    
    var canAccept: Bool {
        guard !isMyRequest else { return false }
        
        // Check if real current user is already a participant
        guard let currentUser = AuthManager.shared.currentUser else {
            return false
        }
        
        let isParticipant = request.participants?.contains(where: { $0.userId == currentUser.id }) ?? false
        
        // Can accept if not already a participant and request is pending
        return !isParticipant && request.status == .pending
    }
    
    var canDecline: Bool {
        return canAccept // Same conditions as accept
    }
    
    var canDelete: Bool {
        return isMyRequest && request.status == .pending
    }
    
    var canViewEquipment: Bool {
        return true // Always allow viewing equipment details
    }
    
    // MARK: - Public Methods
    
    /// Set the coordinator (used when coordinator is created after viewModel initialization)
    func setCoordinator(_ coordinator: CoEquipNavigationCoordinator?) {
        self.coordinator = coordinator
    }
    
    // MARK: - Actions
    
    enum ConfirmationAction {
        case accept
        case decline
        case delete
    }
    
    func presentAcceptConfirmation() {
        confirmationAction = .accept
        confirmationMessage = "Are you sure you want to accept this request? You'll need to provide your area details."
        showConfirmation = true
    }
    
    func presentDeclineConfirmation() {
        confirmationAction = .decline
        confirmationMessage = "Are you sure you want to decline this request?"
        showConfirmation = true
    }
    
    func presentDeleteConfirmation() {
        confirmationAction = .delete
        confirmationMessage = "Are you sure you want to delete this request? This action cannot be undone."
        showConfirmation = true
    }
    
    func confirmAction() {
        switch confirmationAction {
        case .accept:
            acceptRequest()
        case .decline:
            declineRequest()
        case .delete:
            deleteRequest()
        }
    }
    
    func acceptRequest() {
        // Navigate to acceptance flow where user enters area
        // Using real equipment data from cache
        guard let equipment = _cachedEquipment else {
            errorMessage = "Equipment not found"
            showError = true
            return
        }
        
        coordinator?.navigateToAcceptRequest(request: request, equipment: equipment)
    }
    
    func declineRequest() {
        isLoading = true
        
        Task {
            do {
                // Update request status in DataController/backend
                // In a real implementation, you would call:
                // await dataController?.declineRequest(requestId: request.id)
                
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                
                await MainActor.run {
                    isLoading = false
                    coordinator?.dismissRequestDetail()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to decline request: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    func deleteRequest() {
        isLoading = true
        
        Task {
            do {
                // Delete the request from DataController/backend
                let success = await dataController?.deleteRequest(with: request.id) ?? false
                
                if success {
                    // Post notification to update other views
                    NotificationCenter.default.post(
                        name: .requestDeleted,
                        object: nil,
                        userInfo: ["requestId": request.id]
                    )
                    
                    // Small delay for better UX
                    try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
                    
                    await MainActor.run {
                        isLoading = false
                        coordinator?.dismissRequestDetail()
                    }
                } else {
                    throw NSError(
                        domain: "RequestDetailViewModel",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to delete request"]
                    )
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to delete request: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    func modifyRequest() {
        // Show ModifyRequestView in a sheet (handled by RequestDetailView)
        showModifySheet = true
    }
    
    func viewEquipmentDetails() {
        // For SwiftUI navigation, use @Published property
        // For UIKit coordinator, use the coordinator method
        if coordinator != nil {
            // UIKit-based navigation via coordinator
            guard let equipment = _cachedEquipment else {
                errorMessage = "Equipment not found"
                showError = true
                return
            }
            coordinator?.navigateToEquipmentDetail(equipment: equipment, isReadOnly: true)
        } else {
            // SwiftUI-based navigation via published property
            guard _cachedEquipment != nil else {
                errorMessage = "Equipment not found"
                showError = true
                return
            }
            showEquipmentDetail = true
        }
    }
}

// MARK: - Navigation Coordinator Protocol

protocol CoEquipNavigationCoordinator: AnyObject {
    func navigateToAcceptRequest(request: Request, equipment: Equipment)
    func navigateToModifyRequest(request: Request)
    func navigateToEquipmentDetail(equipment: Equipment, isReadOnly: Bool)
    func dismissRequestDetail()
}

// MARK: - Preview Helper

#if DEBUG
extension RequestDetailViewModel {
    static func preview() -> RequestDetailViewModel {
        let sampleRequest = Request(
            id: UUID(),
            userId: UUID(),
            equipmentId: UUID(),
            requestedDate: Date(),
            status: .pending,
            type: .coEquip,
            area: 5.0,
            timeSlot: .morning,
            timePeriod: "08:00 - 12:00",
            location: "Murshadpur, Greater Noida, UP",
            typeOfRequest: .myRequest,
            participants: [
                RequestParticipant(
                    id: UUID(),
                    requestId: UUID(),
                    userId: UUID(),
                    status: .done,
                    area: 2.5,
                    timeSlot: "08:00 - 10:00",
                    joinedAt: Date()
                )
            ]
        )
        
        return RequestDetailViewModel(
            request: sampleRequest,
            dataController: nil,
            coordinator: nil
        )
    }
}
#endif
