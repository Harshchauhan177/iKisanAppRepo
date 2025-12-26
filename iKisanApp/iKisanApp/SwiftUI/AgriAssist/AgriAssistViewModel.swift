//
//  AgriAssistViewModel.swift
//  iKisanApp
//
//  Created by GitHub Copilot on 24/12/25.
//

import Foundation
import Combine

@MainActor
class AgriAssistViewModel: ObservableObject {
    @Published var crops: [AgriCrop] = []
    @Published var filteredCrops: [AgriCrop] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func loadCrops() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedCrops: [AgriCrop] = try await SupabaseManager.shared.client
                .from("cropCategories")
                .select("*")
                .execute()
                .value
            
            self.crops = fetchedCrops
            self.filteredCrops = fetchedCrops
            print("✅ Loaded \(fetchedCrops.count) crops")
        } catch {
            print("❌ Error loading crops: \(error)")
            self.errorMessage = "Failed to load crops. Please try again."
            self.crops = []
            self.filteredCrops = []
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        print("🔄 Refreshing crops data...")
        await loadCrops()
    }
    
    func searchCrops(with query: String) {
        if query.isEmpty {
            filteredCrops = crops
        } else {
            filteredCrops = crops.filter { 
                $0.name.lowercased().contains(query.lowercased())
            }
        }
    }
}
