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
            // Background: #F8F8F8
            Color(red: 248/255, green: 248/255, blue: 248/255)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading equipment...")
            } else if viewModel.equipmentCategories.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.equipmentCategories) { category in
                            EquipmentCategorySection(
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
                    .padding(.bottom, 80) // Bottom spacing as per spec
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

// MARK: - Equipment Category Section
struct EquipmentCategorySection: View {
    let category: EquipmentCategory
    let onSeeAll: () -> Void
    let onEquipmentTap: (EquipmentAgri) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header - minimum height 44px
            HStack(alignment: .center) {
                // Title: Inter Semi Bold 20px, color #1C1C1E
                Text(category.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 28/255, green: 28/255, blue: 30/255))
                
                Spacer()
                
                // "See All" button: Inter Semi Bold 15px, color #007AFF
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onSeeAll()
                }) {
                    Text("See All")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0/255, green: 102/255, blue: 51/255))
                }
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 16) // 16px horizontal padding
            .padding(.vertical, 12) // 12px vertical padding
            
            // Bottom border: 0.5px solid #E5E5EA
            Rectangle()
                .fill(Color(red: 229/255, green: 229/255, blue: 234/255))
                .frame(height: 0.5)
            
            // Horizontal ScrollView - minimum height 180px
            if category.equipmentList.isEmpty {
                Text("No equipment in this category")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) { // 12px spacing between cards
                        ForEach(category.equipmentList) { equipment in
                            EquipmentCard(equipment: equipment)
                                .simultaneousGesture(
                                    TapGesture()
                                        .onEnded {
                                            onEquipmentTap(equipment)
                                        }
                                )
                        }
                    }
                    .padding(.horizontal, 12) // 12px horizontal padding
                    .padding(.vertical, 12)
                }
                .frame(minHeight: 180)
            }
        }
    }
}

// MARK: - Equipment Card
struct EquipmentCard: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Image container (top): 140px × 100px with 8px padding
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 124, height: 84) // 140-16 for 8px padding on each side
                        .cornerRadius(8) // Rounded style for image
                        .clipped()
                } else {
                    // Placeholder with icon
                    Image(systemName: "tractor.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                }
            }
            .frame(width: 140, height: 100)
            .background(Color.white)
            
            // Equipment name below: Inter Medium 15px, color #1C1C1E, center-aligned, padding 8px
            Text(equipment.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 28/255, green: 28/255, blue: 30/255))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 124) // Account for 8px padding on each side
                .padding(8)
        }
        .frame(width: 140, height: 160) // Size: 140px × 160px
        .background(Color.white) // Background: White
        .cornerRadius(12) // Corner radius: 12px
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2) // Shadow: 0px 2px 8px rgba(0,0,0,0.08)
        .contentShape(Rectangle()) // Makes entire card tappable
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
