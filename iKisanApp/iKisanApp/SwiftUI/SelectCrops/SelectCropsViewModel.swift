//
//  SelectCropsViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI
import Combine

/// ViewModel for Select Crops screen following MVVM architecture
/// Handles all business logic, state management, and data operations
@MainActor
final class SelectCropsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var crops: [CropModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var buttonTitle: String = "Continue to App"
    @Published var showingAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    // MARK: - Private Properties
    
    private let dataController: DataController
    private let isFromProfile: Bool
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var selectedCrops: [CropModel] {
        crops.filter { $0.isSelected }
    }
    
    var hasSelectedCrops: Bool {
        !selectedCrops.isEmpty
    }
    
    var isEmpty: Bool {
        crops.isEmpty
    }
    
    // MARK: - Initialization
    
    init(dataController: DataController = IKisanDataController(), isFromProfile: Bool = false) {
        self.dataController = dataController
        self.isFromProfile = isFromProfile
        
        setupObservers()
        loadCrops()
    }
    
    // MARK: - Public Methods
    
    /// Toggles the selection state of a crop
    func toggleCropSelection(_ cropId: UUID) {
        guard let index = crops.firstIndex(where: { $0.id == cropId }) else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            crops[index].isSelected.toggle()
            
            // If deselecting and no field area, clear it
            if !crops[index].isSelected && crops[index].fieldArea.isEmpty {
                crops[index].fieldArea = ""
            }
            
            updateButtonTitle()
        }
    }
    
    /// Updates the field area for a specific crop
    func updateFieldArea(for cropId: UUID, area: String) {
        guard let index = crops.firstIndex(where: { $0.id == cropId }) else { return }
        
        crops[index].fieldArea = area
        
        // Save immediately to data controller
        dataController.saveCropFieldArea(cropName: crops[index].name, area: area)
    }
    
    /// Handles the continue/save button action
    func continueButtonTapped() async {
        let selectedCropNames = Set(selectedCrops.map { $0.name })
        
        // Save selected crops to data controller
        dataController.setSelectedCrops(selectedCropNames)
        
        // Save field areas
        saveFieldAreas()
        
        // Mark crop selection as completed
        UserDefaults.standard.set(true, forKey: "didCompleteCropSelection")
        UserDefaults.standard.set(false, forKey: "isNewlyRegisteredUser")
        
        if isFromProfile {
            await handleProfileUpdate()
        } else {
            await handleOnboardingCompletion()
        }
    }
    
    /// Reloads crops from the data controller
    func reloadCrops() {
        loadCrops()
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: NSNotification.Name("CropsUpdated"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadCrops()
            }
            .store(in: &cancellables)
    }
    
    private func loadCrops() {
        isLoading = true
        errorMessage = nil
        
        let cropList = dataController.getAllCropsForSelection()
        
        // If coming from profile, load previously selected crops
        if isFromProfile {
            let selectedCropNames = dataController.getSelectedCrops()
            let savedFieldAreas = dataController.getAllCropFieldAreas()
            
            crops = cropList.map { crop in
                CropModel(
                    from: crop,
                    isSelected: selectedCropNames.contains(crop.name),
                    fieldArea: savedFieldAreas[crop.name] ?? ""
                )
            }
            
            buttonTitle = "Save Selected Crops"
        } else {
            crops = cropList.map { CropModel(from: $0) }
        }
        
        isLoading = false
        updateButtonTitle()
    }
    
    private func saveFieldAreas() {
        var areas: [String: String] = [:]
        
        for crop in crops where !crop.fieldArea.isEmpty {
            areas[crop.name] = crop.fieldArea
        }
        
        dataController.saveCropFieldAreas(areas: areas)
    }
    
    private func updateButtonTitle() {
        if isFromProfile {
            buttonTitle = "Save Selected Crops"
        } else if hasSelectedCrops {
            buttonTitle = "Continue with Selected Crops"
        } else {
            buttonTitle = "Continue to App"
        }
    }
    
    private func handleProfileUpdate() async {
        guard let currentUser = AuthManager.shared.currentUser else {
            NotificationCenter.default.post(name: .cropSelectionCompleted, object: nil)
            return
        }
        
        let selectedCropIds = selectedCrops.map { $0.id }
        let totalFieldArea = calculateTotalFieldArea()
        
        isLoading = true
        
        do {
            try await AuthManager.shared.updateUserSelectedCrops(
                selectedCropIds: selectedCropIds,
                totalFieldArea: totalFieldArea
            )
            
            isLoading = false
            
            // Show success alert
            alertTitle = "Success"
            alertMessage = "Your crop selections have been updated."
            showingAlert = true
            
            // Post notification to dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .cropSelectionCompleted, object: nil)
            }
            
        } catch {
            isLoading = false
            
            // Check if error is non-critical
            let errorDescription = error.localizedDescription
            if errorDescription.contains("selectedCrops") && errorDescription.contains("users") {
                // Non-critical error, proceed anyway
                alertTitle = "Success"
                alertMessage = "Your crop selections have been updated."
                showingAlert = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .cropSelectionCompleted, object: nil)
                }
            } else {
                // Show error
                alertTitle = "Error"
                alertMessage = "Failed to update crop selections. Please try again."
                showingAlert = true
            }
        }
    }
    
    private func handleOnboardingCompletion() async {
        guard let currentUser = AuthManager.shared.currentUser else {
            NotificationCenter.default.post(name: .cropSelectionCompletedOnboarding, object: nil)
            return
        }
        
        let selectedCropIds = selectedCrops.map { $0.id }
        let totalFieldArea = calculateTotalFieldArea()
        
        isLoading = true
        
        do {
            try await AuthManager.shared.updateUserSelectedCrops(
                selectedCropIds: selectedCropIds,
                totalFieldArea: totalFieldArea
            )
            
            isLoading = false
            
            // Post notification to switch to main interface
            NotificationCenter.default.post(name: .cropSelectionCompletedOnboarding, object: nil)
            
        } catch {
            isLoading = false
            
            // Log error but continue anyway
            print("Error updating crops during onboarding: \(error)")
            
            // Still proceed to main interface
            NotificationCenter.default.post(name: .cropSelectionCompletedOnboarding, object: nil)
        }
    }
    
    private func calculateTotalFieldArea() -> Double {
        var total: Double = 0.0
        
        for crop in selectedCrops {
            if let area = Double(crop.fieldArea) {
                total += area
            }
        }
        
        return total
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let cropSelectionCompleted = Notification.Name("cropSelectionCompleted")
    static let cropSelectionCompletedOnboarding = Notification.Name("cropSelectionCompletedOnboarding")
}
