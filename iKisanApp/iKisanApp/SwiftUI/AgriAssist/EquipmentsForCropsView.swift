//
//  EquipmentsForCropsView.swift
//  iKisanApp
//
//  Created by GitHub Copilot on 24/12/25.
//

import SwiftUI

struct EquipmentsForCropsView: View {
    let crop: AgriCrop
    @StateObject private var viewModel: EquipmentsForCropsViewModel
    
    init(crop: AgriCrop) {
        self.crop = crop
        _viewModel = StateObject(wrappedValue: EquipmentsForCropsViewModel(cropId: crop.id))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading equipment...")
            } else if viewModel.equipmentCategories.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.equipmentCategories) { category in
                            EquipmentCategoryCard(
                                category: category,
                                onSeeAll: {
                                    viewModel.selectedCategory = category
                                },
                                onEquipmentTap: { equipment in
                                    viewModel.selectedEquipment = equipment
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Equipments for \(crop.name)")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.loadEquipmentCategories()
        }
        .navigationDestination(item: $viewModel.selectedCategory) { category in
            SameTypeAllEquipmentsView(category: category)
        }
        .navigationDestination(item: $viewModel.selectedEquipment) { equipment in
            InfoAboutEquipmentsView(equipment: equipment)
        }
        .task {
            await viewModel.loadEquipmentCategories()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No equipment available")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Check back later for equipment recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Equipment Category Card
struct EquipmentCategoryCard: View {
    let category: EquipmentCategory
    let onSeeAll: () -> Void
    let onEquipmentTap: (EquipmentAgri) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(category.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onSeeAll) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Horizontal ScrollView of equipment
            if category.equipmentList.isEmpty {
                Text("No equipment in this category")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(category.equipmentList) { equipment in
                            EquipmentCardView(equipment: equipment)
                                .onTapGesture {
                                    onEquipmentTap(equipment)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Equipment Card View
struct EquipmentCardView: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    
    var body: some View {
        VStack(spacing: 8) {
            // Equipment Image
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "tractor")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .padding(20)
                }
            }
            .frame(width: 120, height: 120)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Equipment Name
            Text(equipment.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 120)
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard !equipment.imageName.isEmpty else { return }
        
        await MainActor.run {
            ImageCache.shared.loadImage(from: equipment.imageName) { loadedImage in
                self.image = loadedImage
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
class EquipmentsForCropsViewModel: ObservableObject {
    @Published var equipmentCategories: [EquipmentCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCategory: EquipmentCategory?
    @Published var selectedEquipment: EquipmentAgri?
    
    private let cropId: UUID
    
    init(cropId: UUID) {
        self.cropId = cropId
    }
    
    func loadEquipmentCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch equipment categories for the crop
            var categories: [EquipmentCategory] = try await SupabaseManager.shared.client
                .from("equipmentCategories")
                .select("*")
                .eq("cropCategoryId", value: cropId)
                .execute()
                .value
            
            // Fetch equipment for each category
            for i in categories.indices {
                let equipmentList: [EquipmentAgri] = try await SupabaseManager.shared.client
                    .from("equipmentAgri")
                    .select("*")
                    .eq("categoryId", value: categories[i].id)
                    .execute()
                    .value
                categories[i].equipmentList = equipmentList
            }
            
            self.equipmentCategories = categories
            print("✅ Loaded \(categories.count) equipment categories")
        } catch {
            print("❌ Error loading equipment categories: \(error)")
            self.errorMessage = "Failed to load equipment categories"
            self.equipmentCategories = []
        }
        
        isLoading = false
    }
}

// Make EquipmentCategory conform to Identifiable and Hashable for navigation
extension EquipmentCategory: Identifiable, Hashable {
    static func == (lhs: EquipmentCategory, rhs: EquipmentCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Make EquipmentAgri conform to Identifiable for ForEach
extension EquipmentAgri: Identifiable, Hashable {
    static func == (lhs: EquipmentAgri, rhs: EquipmentAgri) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    NavigationStack {
        EquipmentsForCropsView(crop: AgriCrop(id: UUID(), name: "Wheat", imageName: ""))
    }
}
