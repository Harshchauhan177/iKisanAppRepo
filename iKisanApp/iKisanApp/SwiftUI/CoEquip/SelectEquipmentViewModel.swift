//
//  SelectEquipmentViewModel.swift
//  iKisanApp
//
//  ViewModel for Select Equipment Screen - MVVM Architecture
//

import Foundation
import SwiftUI
import Combine

/// ViewModel managing equipment selection, filtering, and search logic
@MainActor
class SelectEquipmentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All available equipment from data source
    @Published var allEquipment: [Equipment] = []
    
    /// Filtered equipment based on active filters
    @Published var filteredEquipment: [Equipment] = []
    
    /// Search text entered by user
    @Published var searchText: String = "" {
        didSet {
            // Sanitize and apply filters
            applyFilters()
        }
    }
    
    /// Currently selected category filter
    @Published var selectedCategory: String = "All" {
        didSet {
            applyFilters()
        }
    }
    
    /// Selected date for equipment availability filtering
    @Published var selectedDate: Date = Date() {
        didSet {
            applyFilters()
        }
    }
    
    /// Whether date picker sheet is shown
    @Published var showDatePicker: Bool = false
    
    /// Loading state for async operations
    @Published var isLoading: Bool = false
    
    /// Error message if loading fails
    @Published var errorMessage: String?
    
    // MARK: - Properties
    
    /// Available filter categories
    let categories: [String] = ["All", "Combine", "Rice", "Wheat", "Soyabean", "Irrigation", "Other"]
    
    /// Reference to data controller
    weak var dataController: DataController?
    
    /// Search suggestion passed from previous screen
    var initialSearchSuggestion: String?
    
    /// Cancellables for Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    /// Formatted date string for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM"
        return formatter.string(from: selectedDate)
    }
    
    /// Whether search is active
    var isSearchActive: Bool {
        !sanitizedSearchText.isEmpty
    }
    
    /// Sanitized search text (trimmed whitespace)
    private var sanitizedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Search suggestions based on current input
    var searchSuggestions: [String] {
        let trimmedSearch = sanitizedSearchText
        guard !trimmedSearch.isEmpty, trimmedSearch.count >= 2 else {
            return []
        }
        
        // Get unique equipment names that match the search text
        let uniqueNames = Set(allEquipment.map { $0.name })
        let filtered = uniqueNames.filter { name in
            name.localizedCaseInsensitiveContains(trimmedSearch)
        }
        
        // Sort by relevance (starts with query first, then contains)
        let sortedResults = filtered.sorted { name1, name2 in
            let name1Lower = name1.lowercased()
            let name2Lower = name2.lowercased()
            let queryLower = trimmedSearch.lowercased()
            
            let name1Starts = name1Lower.hasPrefix(queryLower)
            let name2Starts = name2Lower.hasPrefix(queryLower)
            
            if name1Starts && !name2Starts {
                return true
            } else if !name1Starts && name2Starts {
                return false
            } else {
                return name1 < name2
            }
        }
        
        // Return top 5 suggestions
        return Array(sortedResults.prefix(5))
    }
    
    /// Whether to show search suggestions
    var shouldShowSuggestions: Bool {
        let trimmedSearch = sanitizedSearchText
        return !trimmedSearch.isEmpty && !searchSuggestions.isEmpty && trimmedSearch.count >= 2
    }
    
    // MARK: - Initialization
    
    init(dataController: DataController?, initialSearchSuggestion: String? = nil) {
        self.dataController = dataController
        self.initialSearchSuggestion = initialSearchSuggestion
        
        // Set initial search text if provided
        if let suggestion = initialSearchSuggestion, !suggestion.isEmpty {
            self.searchText = suggestion
        }
        
        loadEquipment()
    }
    
    // MARK: - Data Loading
    
    /// Load all equipment from data controller
    func loadEquipment() {
        guard let dataController = dataController else {
            print("❌ DataController is nil")
            errorMessage = "System error: Please try again later"
            return
        }
        
        isLoading = true
        
        // Simulate async loading (replace with actual async call if needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Load ALL equipment without limits
            let loadedEquipment = dataController.getAllEquipment()
            self.allEquipment = loadedEquipment
            
            print("📦 Loaded Equipment:")
            print("   Total items: \(loadedEquipment.count)")
            if loadedEquipment.count > 0 {
                print("   First 3 items:")
                for (index, equipment) in loadedEquipment.prefix(3).enumerated() {
                    print("     \(index + 1). \(equipment.name) (ID: \(equipment.equipmentID))")
                }
            }
            
            // Apply initial filters
            self.applyFilters()
            self.isLoading = false
        }
    }
    
    // MARK: - Filtering Logic
    
    /// Apply all active filters to equipment list
    func applyFilters() {
        var results = allEquipment
        
        // Sanitize search text
        let trimmedSearch = sanitizedSearchText
        
        print("🔍 Starting filter process...")
        print("   All Equipment: \(allEquipment.count)")
        
        // Apply search filter (if search is active)
        if !trimmedSearch.isEmpty {
            let beforeSearchCount = results.count
            results = results.filter { equipment in
                // Check name, type, and description with case-insensitive contains
                equipment.name.localizedCaseInsensitiveContains(trimmedSearch) ||
                equipment.type.localizedCaseInsensitiveContains(trimmedSearch) ||
                (equipment.description?.localizedCaseInsensitiveContains(trimmedSearch) ?? false)
            }
            print("   After Search '\(trimmedSearch)': \(results.count) (was \(beforeSearchCount))")
        }
        
        // Apply category filter (only if search is empty or in combination with search)
        if selectedCategory != "All" {
            let beforeCategoryCount = results.count
            results = results.filter { equipment in
                filterEquipmentByCategory(equipment, category: selectedCategory)
            }
            print("   After Category '\(selectedCategory)': \(results.count) (was \(beforeCategoryCount))")
        }
        
        // Apply date availability filter (only if not in debug mode)
        // Note: We're being lenient here - if equipment has no availability data, it passes through
        let beforeDateCount = results.count
        results = results.filter { equipment in
            equipment.isAvailable(on: selectedDate)
        }
        print("   After Date '\(formattedDate)': \(results.count) (was \(beforeDateCount))")
        
        // Update filtered results
        filteredEquipment = results
        
        // Final summary
        print("✅ Filter Complete: \(filteredEquipment.count) results")
        if filteredEquipment.count > 0 {
            print("   First result: \(filteredEquipment[0].name)")
        }
    }
    
    /// Category-specific filtering logic
    private func filterEquipmentByCategory(_ equipment: Equipment, category: String) -> Bool {
        let equipmentName = equipment.name.lowercased()
        let equipmentType = equipment.type.lowercased()
        let categoryLower = category.lowercased()
        
        switch categoryLower {
        case "combine":
            return equipmentName.contains("combine") ||
                   equipmentType.contains("combine") ||
                   (equipmentName.contains("harvest") && (equipmentType.contains("combine") || equipmentName.contains("combine")))
            
        case "rice":
            return equipmentName.contains("rice") ||
                   equipmentType.contains("rice") ||
                   equipmentName.contains("paddy") ||
                   equipmentType.contains("paddy")
            
        case "wheat":
            return equipmentName.contains("wheat") ||
                   equipmentType.contains("wheat") ||
                   (equipmentName.contains("grain") && !equipmentName.contains("rice"))
            
        case "soyabean", "soybean":
            return equipmentName.contains("soya") ||
                   equipmentName.contains("soy") ||
                   equipmentType.contains("soya") ||
                   equipmentType.contains("soy")
            
        case "irrigation":
            return equipmentName.contains("irrigation") ||
                   equipmentType.contains("irrigation") ||
                   equipmentName.contains("water") ||
                   equipmentName.contains("pump") ||
                   equipmentType.contains("pump")
            
        case "other":
            let mainCategories = ["combine", "rice", "wheat", "soya", "irrigation", "pump", "paddy"]
            return !mainCategories.contains { keyword in
                equipmentName.contains(keyword) || equipmentType.contains(keyword)
            }
            
        default:
            return true
        }
    }
    
    // MARK: - Actions
    
    /// Apply a search suggestion
    func applySuggestion(_ suggestion: String) {
        // Trim the suggestion before applying
        let trimmedSuggestion = suggestion.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Update search text (this will trigger applyFilters via didSet)
        searchText = trimmedSuggestion
        
        // Force an immediate filter refresh to ensure UI updates
        DispatchQueue.main.async { [weak self] in
            self?.applyFilters()
        }
        
        print("✅ Applied suggestion: '\(trimmedSuggestion)'")
    }
    
    /// Clear search text
    func clearSearch() {
        searchText = ""
        // Filter will be applied automatically via didSet
    }
    
    /// Reset all filters
    func resetFilters() {
        searchText = ""
        selectedCategory = "All"
        selectedDate = Date()
    }
    
    /// Handle equipment selection
    func selectEquipment(_ equipment: Equipment) {
        // This will be handled by the navigation coordinator
        print("Selected equipment: \(equipment.name)")
    }
}
