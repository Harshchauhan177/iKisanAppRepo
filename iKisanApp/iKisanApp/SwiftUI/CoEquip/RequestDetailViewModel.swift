//
//  RequestDetailViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 26/12/25.
//

import SwiftUI
import Combine
import Supabase

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
    
    // Single source of truth for participants - always fetched from database
    @Published var participants: [RequestParticipant] = []
    @Published var isLoadingParticipants: Bool = false
    
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
        
        // Fetch participants on initialization
        Task {
            await fetchGroupParticipants()
        }
    }
    
    // MARK: - Participant Fetching
    
    /// Fetch all participants (invited farmers) for this request from the database
    /// Always fetches from backend to ensure data consistency
    func fetchGroupParticipants() async {
        await MainActor.run {
            isLoadingParticipants = true
        }
        
        print("🔄 Fetching participants from database for request: \(request.id)")
        
        // Always fetch from database to ensure fresh data
        if let freshRequest = await fetchRequestWithParticipants(requestId: request.id) {
            let fetchedParticipants = freshRequest.participants ?? []
            print("✅ Fetched \(fetchedParticipants.count) participants from database")
            
            // Filter out rejected participants
            let activeParticipants = fetchedParticipants.filter { $0.status != .rejected }
            
            await MainActor.run {
                self.participants = activeParticipants
                self.isLoadingParticipants = false
                print("✅ Loaded \(activeParticipants.count) active participants")
                
                // Log participant details for debugging
                if !activeParticipants.isEmpty {
                    let statusSummary = activeParticipants.map { participant in
                        let userName = dataController?.getUserById(participant.userId)?.name ?? "Unknown"
                        return "\(userName): \(participant.status.rawValue)"
                    }.joined(separator: ", ")
                    print("   Participants: \(statusSummary)")
                }
            }
        } else {
            print("❌ Failed to fetch participants from database")
            await MainActor.run {
                self.participants = []
                self.isLoadingParticipants = false
            }
        }
    }
    
    /// Fetch a single request from database WITH participants JOIN
    /// This is needed for newly created requests that exist in local cache without participants
    private func fetchRequestWithParticipants(requestId: UUID) async -> Request? {
        do {
            // Fetch from Supabase with participants JOIN (same query as fetchRequests)
            let rawData = try await SupabaseManager.shared.client
                .from("requests")
                .select("""
                    *,
                    request_participants (
                        id,
                        requestId,
                        userId,
                        status,
                        area,
                        timeSlotId,
                        joinedAt,
                        created_at,
                        updated_at
                    )
                """)
                .eq("id", value: requestId.uuidString)
                .single()
                .execute()
                .data
            
            // Decode the response with proper date handling
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Create date formatter for the simple format (matches database format)
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                // Try parsing with different formats
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss",       // Basic format: 2026-01-18T20:34:00
                    "yyyy-MM-dd'T'HH:mm:ssZ",      // With timezone: 2026-01-18T20:34:00Z
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZ"   // With milliseconds and timezone
                ]
                
                for format in formats {
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }
            
            struct RequestWithParticipants: Codable {
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
                let acceptedUser: [String]?
                let request_participants: [ParticipantDTO]?
                
                struct ParticipantDTO: Codable {
                    let id: UUID
                    let requestId: UUID
                    let userId: UUID
                    let status: String
                    let area: Double?
                    let timeSlotId: String?
                    let joinedAt: Date
                    let created_at: Date?
                    let updated_at: Date?
                }
            }

            
            let dto = try decoder.decode(RequestWithParticipants.self, from: rawData)
            
            // Convert to Request model
            let participants = dto.request_participants?.map { participantDto in
                RequestParticipant(
                    id: participantDto.id,
                    requestId: participantDto.requestId,
                    userId: participantDto.userId,
                    status: ParticipantStatus(rawValue: participantDto.status) ?? .pending,
                    area: participantDto.area,
                    timeSlot: participantDto.timeSlotId,
                    joinedAt: participantDto.joinedAt
                )
            } ?? []
            
            let freshRequest = Request(
                id: dto.id,
                userId: dto.userId,
                equipmentId: dto.equipmentId,
                requestedDate: dto.requestedDate,
                status: BookingStatus(rawValue: dto.status) ?? .pending,
                type: BookingType(rawValue: dto.type) ?? .onDemand,
                area: dto.area,
                timeSlot: TimeSlot(rawValue: dto.timeSlot) ?? .morning,
                timePeriod: dto.timePeriod,
                location: dto.location,
                typeOfRequest: dto.typeOfRequest == "myRequest" ? .myRequest : .acceptedRequest,
                participants: participants,
                acceptedUsers: dto.acceptedUser?.compactMap { UUID(uuidString: $0) } ?? []
            )
            
            return freshRequest
            
        } catch {
            print("❌ Error fetching request with participants: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("   Code: \(postgrestError.code ?? "nil")")
                print("   Message: \(postgrestError.message ?? "nil")")
            }
            return nil
        }
    }
    
    // MARK: - Data Observers
    
    private func setupDataObservers() {
        // Listen for data updates from backend
        NotificationCenter.default.publisher(for: .requestsUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshCachedData()
                // Also refresh participants when requests are updated
                Task {
                    await self?.fetchGroupParticipants()
                }
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
    
    var hasParticipants: Bool {
        return !participants.isEmpty
    }
    
    var participantCount: Int {
        return participants.count
    }
    
    // MARK: - Computed Properties - Area and Pricing
    
    var minimumAreaText: String {
        // Hardcoded minimum required area (business rule)
        return "5.0 acres"
    }
    
    var currentTotalAreaText: String {
        // Calculate total area from participants
        let total = participants.reduce(0.0) { $0 + ($1.area ?? 0.0) }
        return String(format: "%.2f acres", total)
    }
    
    var hostAreaText: String {
        // Return the creator's (host's) area contribution from request
        return String(format: "%.2f acres", request.area)
    }
    
    var yourAreaText: String? {
        // Return current user's area from participants
        guard let currentUser = AuthManager.shared.currentUser,
              let participant = participants.first(where: { $0.userId == currentUser.id }),
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
        // Calculate total price from participants
        guard let equipment = _cachedEquipment else {
            return nil
        }
        
        let area: Double
        if isMyRequest {
            // For creator: sum all participants' areas
            area = participants.reduce(0.0) { $0 + ($1.area ?? 0.0) }
        } else {
            // For participant: show only their area cost
            guard let currentUser = AuthManager.shared.currentUser,
                  let participant = participants.first(where: { $0.userId == currentUser.id }),
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
