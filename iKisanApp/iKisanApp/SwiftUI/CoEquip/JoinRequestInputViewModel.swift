//
//  JoinRequestInputViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 04/01/26.
//

import Foundation
import Combine

/// ViewModel for join request input modal
/// Handles validation, capacity calculations, and join confirmation
@MainActor
class JoinRequestInputViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var fieldAreaInput: String = ""
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isProcessing: Bool = false
    @Published var joinSuccessful: Bool = false
    
    // MARK: - Computed Properties
    
    var isValidInput: Bool {
        guard let area = Double(fieldAreaInput), area > 0 else {
            return false
        }
        
        // Check if adding this area would exceed capacity
        let newTotal = currentTotalArea + area
        return newTotal <= capacity
    }
    
    var validationMessage: String {
        if fieldAreaInput.isEmpty {
            return ""
        }
        
        guard let area = Double(fieldAreaInput) else {
            return "Please enter a valid number"
        }
        
        if area <= 0 {
            return "Area must be greater than 0"
        }
        
        let newTotal = currentTotalArea + area
        if newTotal > capacity {
            let remaining = capacity - currentTotalArea
            return "Exceeds capacity. Maximum available: \(String(format: "%.2f", remaining)) acres"
        }
        
        return ""
    }
    
    var currentTotalAreaText: String {
        return String(format: "%.2f acres", currentTotalArea)
    }
    
    var capacityText: String {
        return String(format: "%.2f acres", capacity)
    }
    
    var remainingCapacity: Double {
        return capacity - currentTotalArea
    }
    
    var remainingCapacityText: String {
        return String(format: "%.2f acres", remainingCapacity)
    }
    
    var capacityPercentage: Double {
        guard capacity > 0 else { return 0 }
        return currentTotalArea / capacity
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: requestDate)
    }
    
    // MARK: - Private Properties
    
    private let request: CoEquipRequest
    private let currentTotalArea: Double
    private let capacity: Double
    private let dataController: DataController?
    private let onJoinSuccess: (Double) -> Void
    
    // Display properties
    let equipmentName: String
    let equipmentImageURL: String
    let requestDate: Date
    let creatorName: String
    
    // MARK: - Initialization
    
    init(
        request: CoEquipRequest,
        dataController: DataController?,
        onJoinSuccess: @escaping (Double) -> Void
    ) {
        self.request = request
        self.dataController = dataController
        self.onJoinSuccess = onJoinSuccess
        
        // Get underlying request for full details
        if let underlyingRequest = request.underlyingRequest {
            // Calculate current total area from participants
            self.currentTotalArea = underlyingRequest.participants?
                .filter { $0.status == .accepted || $0.status == .done }
                .reduce(0.0) { $0 + ($1.area ?? 0.0) } ?? 0.0
            
            self.capacity = underlyingRequest.area
            // Use CoEquipRequest display properties which already have equipment/user info
            self.equipmentName = request.equipmentName
            self.equipmentImageURL = request.equipmentImageURL
            self.requestDate = underlyingRequest.requestedDate
            self.creatorName = request.creatorName ?? "Unknown"
        } else {
            // Fallback to CoEquipRequest properties
            self.currentTotalArea = 0.0
            self.capacity = 100.0 // Default capacity
            self.equipmentName = request.equipmentName
            self.equipmentImageURL = request.equipmentImageURL
            self.requestDate = request.date
            self.creatorName = request.creatorName ?? "Unknown"
        }
    }
    
    // MARK: - Public Methods
    
    func confirmJoin() async {
        guard let area = Double(fieldAreaInput), area > 0 else {
            errorMessage = "Please enter a valid field area"
            showError = true
            return
        }
        
        // Final validation before processing
        let newTotal = currentTotalArea + area
        guard newTotal <= capacity else {
            errorMessage = "Adding this area would exceed the group capacity"
            showError = true
            return
        }
        
        isProcessing = true
        
        // Call the success handler which will trigger the actual backend update
        onJoinSuccess(area)
        
        // Mark as successful
        joinSuccessful = true
        isProcessing = false
    }
    
    // MARK: - Preview Helper
    
    #if DEBUG
    static func preview() -> JoinRequestInputViewModel {
        let participant1 = RequestParticipant(
            id: UUID(),
            requestId: UUID(),
            userId: UUID(),
            status: .accepted,
            area: 15.0,
            timeSlot: nil,
            joinedAt: Date()
        )
        
        let participant2 = RequestParticipant(
            id: UUID(),
            requestId: UUID(),
            userId: UUID(),
            status: .accepted,
            area: 10.0,
            timeSlot: nil,
            joinedAt: Date()
        )
        
        let underlyingRequest = Request(
            id: UUID(),
            userId: UUID(),
            equipmentId: UUID(),
            requestedDate: Date(),
            status: .pending,
            type: .onDemand,
            area: 50.0,
            timeSlot: .morning,
            timePeriod: nil,
            location: "Green Valley",
            typeOfRequest: .myRequest,
            participants: [participant1, participant2],
            acceptedUsers: nil
        )
        
        let request = CoEquipRequest(
            id: underlyingRequest.id,
            equipmentName: "John Deere 6120R",
            equipmentImageURL: "https://example.com/tractor.jpg",
            location: "Green Valley",
            date: underlyingRequest.requestedDate,
            joinedUsersCount: 2,
            status: .pending,
            creatorName: "John Farmer",
            creatorId: UUID(),
            underlyingRequest: underlyingRequest,
            hasJoined: false
        )
        
        return JoinRequestInputViewModel(
            request: request,
            dataController: nil,
            onJoinSuccess: { _ in }
        )
    }
    #endif
}
