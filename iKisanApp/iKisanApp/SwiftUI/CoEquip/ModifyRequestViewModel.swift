//
//  ModifyRequestViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 03/01/26.
//

import SwiftUI
import Combine

/// ViewModel for ModifyRequestView
/// Manages request modification logic including area updates and farmer invitations
@MainActor
class ModifyRequestViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var fieldArea: String = ""
    @Published var selectedFarmers: [User] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false
    @Published var showFarmerSelection: Bool = false
    @Published var areaValidationMessage: String = ""
    
    // MARK: - Dependencies
    
    let request: Request
    let dataController: DataController?
    private var cancellables = Set<AnyCancellable>()
    
    // Cache
    private var cachedEquipment: Equipment?
    
    // MARK: - Initialization
    
    init(request: Request, dataController: DataController?) {
        self.request = request
        self.dataController = dataController
        self.cachedEquipment = dataController?.getEquipmentById(request.equipmentId)
        
        // Initialize with current request area
        self.fieldArea = String(format: "%.2f", request.area)
        
        // Setup validation
        setupValidation()
    }
    
    // MARK: - Setup
    
    private func setupValidation() {
        // Monitor field area changes for validation
        $fieldArea
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.validateArea(value)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var equipmentImageURL: String {
        cachedEquipment?.equipmentImage ?? ""
    }
    
    var equipmentName: String {
        cachedEquipment?.name ?? "Equipment"
    }
    
    var location: String {
        request.location
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM"
        return formatter.string(from: request.requestedDate)
    }
    
    var minimumArea: String {
        String(format: "%.2f acres", request.area)
    }
    
    var currentTotalArea: String {
        let participants = request.participants ?? []
        let total = participants
            .filter { $0.status != .rejected }
            .reduce(0.0) { $0 + ($1.area ?? 0.0) }
        return String(format: "%.2f acres", total)
    }
    
    var currentParticipants: [ParticipantInfo] {
        guard let participants = request.participants else {
            return []
        }
        
        return participants.compactMap { participant in
            guard let user = dataController?.getUserById(participant.userId) else {
                return nil
            }
            
            return ParticipantInfo(
                userId: participant.userId,
                name: user.name,
                area: participant.area,
                status: participant.status
            )
        }
    }
    
    var alreadyInvitedUserIds: Set<UUID> {
        var userIds = Set<UUID>()
        
        // Add request creator
        userIds.insert(request.userId)
        
        // Add all current participants
        if let participants = request.participants {
            participants.forEach { userIds.insert($0.userId) }
        }
        
        // Add newly selected farmers
        selectedFarmers.forEach { userIds.insert($0.userID) }
        
        return userIds
    }
    
    var isValid: Bool {
        guard let areaValue = Double(fieldArea),
              areaValue > 0 else {
            return false
        }
        
        // Must be valid area
        return areaValidationMessage.isEmpty
    }
    
    // MARK: - Validation
    
    private func validateArea(_ value: String) {
        guard !value.isEmpty else {
            areaValidationMessage = "Area is required"
            return
        }
        
        guard let areaValue = Double(value) else {
            areaValidationMessage = "Please enter a valid number"
            return
        }
        
        if areaValue <= 0 {
            areaValidationMessage = "Area must be greater than 0"
            return
        }
        
        if areaValue > 1000 {
            areaValidationMessage = "Area seems unusually large"
            return
        }
        
        // All validations passed
        areaValidationMessage = ""
    }
    
    // MARK: - Actions
    
    func addSelectedFarmers(_ farmers: [User]) {
        // Add only farmers that aren't already selected
        let newFarmers = farmers.filter { newFarmer in
            !selectedFarmers.contains(where: { $0.userID == newFarmer.userID })
        }
        
        selectedFarmers.append(contentsOf: newFarmers)
    }
    
    func removeFarmer(_ farmer: User) {
        selectedFarmers.removeAll { $0.userID == farmer.userID }
    }
    
    func updateRequest() async {
        guard isValid else {
            errorMessage = "Please correct the validation errors"
            showError = true
            return
        }
        
        guard let areaValue = Double(fieldArea) else {
            errorMessage = "Invalid area value"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            // Create updated request
            var updatedRequest = request
            updatedRequest.area = areaValue
            
            // Add new participants for selected farmers
            var participants = updatedRequest.participants ?? []
            
            for farmer in selectedFarmers {
                let newParticipant = RequestParticipant(
                    id: UUID(),
                    requestId: request.id,
                    userId: farmer.userID,
                    status: .pending,
                    area: nil,
                    timeSlot: nil,
                    joinedAt: Date()
                )
                participants.append(newParticipant)
            }
            
            updatedRequest.participants = participants
            
            // Update in backend
            let success = await dataController?.updateRequest(updatedRequest) ?? false
            
            if success {
                // Post notification for other views to refresh
                NotificationCenter.default.post(
                    name: .requestsUpdated,
                    object: nil,
                    userInfo: ["requestId": request.id]
                )
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } else {
                throw NSError(
                    domain: "ModifyRequestViewModel",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to update request"]
                )
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to update request: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    // MARK: - Supporting Types
    
    struct ParticipantInfo {
        let userId: UUID
        let name: String
        let area: Double?
        let status: ParticipantStatus
    }
}

// MARK: - Preview Helper

#if DEBUG
extension ModifyRequestViewModel {
    static func preview() -> ModifyRequestViewModel {
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
            participants: []
        )
        
        return ModifyRequestViewModel(
            request: sampleRequest,
            dataController: nil
        )
    }
}
#endif
