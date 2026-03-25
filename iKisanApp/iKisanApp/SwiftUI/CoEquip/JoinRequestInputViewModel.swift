//
//  JoinRequestInputViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 04/01/26.
//

import Foundation
import Combine

/// Area units for agricultural land measurement
enum AreaUnit: String, CaseIterable, Identifiable {
    case acre = "Acre"
    case hectare = "Hectare"
    case bigha = "Bigha"
    case guntha = "Guntha"
    case biswa = "Biswa"
    
    var id: String { rawValue }
    
    /// Conversion factor to convert this unit to acres
    var toAcresFactor: Double {
        switch self {
        case .acre:
            return 1.0
        case .hectare:
            return 2.47105 // 1 hectare = 2.47105 acres
        case .bigha:
            return 0.62 // 1 bigha ≈ 0.62 acres (varies by region, using standard conversion)
        case .guntha:
            return 0.025 // 1 guntha ≈ 0.025 acres
        case .biswa:
            return 0.031 // 1 biswa ≈ 0.031 acres
        }
    }
    
    /// Convert a value in this unit to acres
    func toAcres(_ value: Double) -> Double {
        return value * toAcresFactor
    }
    
    /// Convert a value from acres to this unit
    func fromAcres(_ acres: Double) -> Double {
        return acres / toAcresFactor
    }
}

/// ViewModel for join request input modal
/// Handles validation, capacity calculations, and join confirmation
@MainActor
class JoinRequestInputViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var fieldAreaInput: String = ""
    @Published var selectedUnit: AreaUnit = .acre
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isProcessing: Bool = false
    @Published var joinSuccessful: Bool = false
    
    // MARK: - Computed Properties
    
    /// The area entered by user converted to acres (standardized)
    var areaInAcres: Double? {
        guard let value = Double(fieldAreaInput) else { return nil }
        return selectedUnit.toAcres(value)
    }
    
    /// Display text showing the converted value in acres
    var convertedAreaText: String {
        guard let acres = areaInAcres, acres > 0 else { return "" }
        
        if selectedUnit == .acre {
            return "" // No need to show conversion if already in acres
        }
        
        return String(format: "≈ %.2f acres", acres)
    }
    
    var isValidInput: Bool {
        guard let acres = areaInAcres, acres > 0 else {
            return false
        }

        // Check if adding this area (in acres) would exceed equipment capacity
        // Validation: newFarmerArea <= (equipmentCapacity - currentTotalGroupArea)
        return acres <= remainingCapacity
    }

    var validationMessage: String {
        if fieldAreaInput.isEmpty {
            return ""
        }

        guard let value = Double(fieldAreaInput) else {
            return "Please enter a valid number"
        }

        if value <= 0 {
            return "Area must be greater than 0"
        }

        guard let acres = areaInAcres else {
            return "Invalid area value"
        }

        if acres > remainingCapacity {
            let remainingInSelectedUnit = selectedUnit.fromAcres(remainingCapacity)
            return "Exceeds capacity. Maximum available: \(String(format: "%.2f", remainingInSelectedUnit)) \(selectedUnit.rawValue.lowercased())"
        }

        return ""
    }

    var currentTotalAreaText: String {
        return String(format: "%.2f acres", currentTotalArea)
    }

    var capacityText: String {
        return String(format: "%.2f acres", equipmentCapacity)
    }

    /// Remaining capacity available for new farmers to commit
    /// Formula: equipment.capacity - currentTotalGroupArea
    var remainingCapacity: Double {
        return max(0, equipmentCapacity - currentTotalArea)
    }

    var remainingCapacityText: String {
        return String(format: "%.2f acres", remainingCapacity)
    }

    var capacityPercentage: Double {
        guard equipmentCapacity > 0 else { return 0 }
        return currentTotalArea / equipmentCapacity
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
    private let equipmentCapacity: Double // Equipment's maximum capacity
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
            // Calculate current total area from accepted/done participants
            // This represents the total area already committed to the group
            self.currentTotalArea = underlyingRequest.participants?
                .filter { $0.status == .accepted || $0.status == .done }
                .reduce(0.0) { $0 + ($1.area ?? 0.0) } ?? 0.0

            // Get equipment capacity from the equipment, NOT from request.area
            // request.area is the group's accumulated area, NOT the max capacity
            if let equipment = dataController?.getEquipmentById(underlyingRequest.equipmentId) {
                // Parse equipment capacity (may be "50 acres" or just "50")
                let capacityString = equipment.capacity.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                self.equipmentCapacity = Double(capacityString) ?? 100.0
            } else {
                // Fallback - use a reasonable default
                self.equipmentCapacity = 100.0
            }

            // Use CoEquipRequest display properties which already have equipment/user info
            self.equipmentName = request.equipmentName
            self.equipmentImageURL = request.equipmentImageURL
            self.requestDate = underlyingRequest.requestedDate
            self.creatorName = request.creatorName ?? "Unknown"
        } else {
            // Fallback to CoEquipRequest properties
            self.currentTotalArea = 0.0
            self.equipmentCapacity = 100.0 // Default capacity
            self.equipmentName = request.equipmentName
            self.equipmentImageURL = request.equipmentImageURL
            self.requestDate = request.date
            self.creatorName = request.creatorName ?? "Unknown"
        }
    }
    
    // MARK: - Public Methods
    
    func confirmJoin() async {
        guard let acres = areaInAcres, acres > 0 else {
            errorMessage = "Please enter a valid field area"
            showError = true
            return
        }

        // Final validation: ensure new farmer's area doesn't exceed remaining capacity
        guard acres <= remainingCapacity else {
            errorMessage = "Adding this area would exceed the equipment's capacity"
            showError = true
            return
        }

        isProcessing = true

        // Call the success handler with the standardized area in acres
        onJoinSuccess(acres)

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
