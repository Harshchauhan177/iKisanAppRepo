//
//  FarmerSelectionViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 03/01/26.
//

import SwiftUI
import Combine

/// ViewModel for FarmerSelectionView
/// Manages farmer search, filtering, and multi-selection
@MainActor
class FarmerSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var searchText: String = ""
    @Published var selectedFarmers: [User] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let dataController: DataController?
    private let requestId: UUID
    private let alreadyInvitedUserIds: Set<UUID>
    private let onSelectionComplete: ([User]) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    // All available farmers (excluding already invited)
    private var allFarmers: [User] = []
    
    // MARK: - Initialization
    
    init(
        dataController: DataController?,
        requestId: UUID,
        alreadyInvitedUserIds: Set<UUID>,
        onSelectionComplete: @escaping ([User]) -> Void
    ) {
        self.dataController = dataController
        self.requestId = requestId
        self.alreadyInvitedUserIds = alreadyInvitedUserIds
        self.onSelectionComplete = onSelectionComplete
        
        loadFarmers()
    }
    
    // MARK: - Computed Properties
    
    var filteredFarmers: [User] {
        guard !searchText.isEmpty else {
            return allFarmers
        }
        
        let lowercasedSearch = searchText.lowercased()
        return allFarmers.filter { farmer in
            farmer.name.lowercased().contains(lowercasedSearch) ||
            farmer.phone.contains(searchText) ||
            (farmer.location.address?.lowercased().contains(lowercasedSearch) ?? false)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadFarmers() {
        isLoading = true
        
        guard let dataController = dataController else {
            isLoading = false
            return
        }
        
        // Get all users from DataController
        let allUsers = dataController.getAllUsers()
        
        // Get current user to exclude them
        guard let currentUser = dataController.getCurrentUser() else {
            isLoading = false
            return
        }
        
        // Filter out:
        // 1. Current user
        // 2. Already invited users
        // 3. Equipment providers (optional - they're typically not farmers)
        allFarmers = allUsers.filter { user in
            // Exclude current user
            guard user.userID != currentUser.userID else {
                return false
            }
            
            // Exclude already invited users
            guard !alreadyInvitedUserIds.contains(user.userID) else {
                return false
            }
            
            return true
        }
        
        // Sort by name
        allFarmers.sort { $0.name < $1.name }
        
        isLoading = false
    }
    
    // MARK: - Selection Management
    
    func isSelected(_ farmer: User) -> Bool {
        selectedFarmers.contains(where: { $0.userID == farmer.userID })
    }
    
    func toggleSelection(_ farmer: User) {
        if isSelected(farmer) {
            selectedFarmers.removeAll { $0.userID == farmer.userID }
        } else {
            selectedFarmers.append(farmer)
        }
    }
    
    func completeSelection() {
        onSelectionComplete(selectedFarmers)
    }
}

// MARK: - Preview Helper

#if DEBUG
extension FarmerSelectionViewModel {
    static func preview() -> FarmerSelectionViewModel {
        return FarmerSelectionViewModel(
            dataController: nil,
            requestId: UUID(),
            alreadyInvitedUserIds: [],
            onSelectionComplete: { _ in }
        )
    }
}
#endif
