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
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading equipment...")
            } else if viewModel.equipmentCategories.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
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
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Equipments for \(crop.name)")
        .navigationBarTitleDisplayMode(.large)
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
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .center) {
                Text(category.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onSeeAll) {
                    Text("See All")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 0.2, green: 0.47, blue: 0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Horizontal ScrollView of equipment
            if category.equipmentList.isEmpty {
                Text("No equipment in this category")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(category.equipmentList) { equipment in
                            EquipmentCardView(equipment: equipment)
                                .onTapGesture {
                                    onEquipmentTap(equipment)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Equipment Card View
struct EquipmentCardView: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    
    var body: some View {
        VStack(spacing: 12) {
            // Equipment Image with rounded corners and white background
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
                        .padding(24)
                }
            }
            .frame(width: 140, height: 140)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 0.5)
            )
            
            // Equipment Name
            Text(equipment.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 140, alignment: .center)
        }
        .frame(width: 140)
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
