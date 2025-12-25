//
//  SameTypeAllEquipmentsView.swift
//  iKisanApp
//
//  Created by GitHub Copilot on 24/12/25.
//

import SwiftUI

struct SameTypeAllEquipmentsView: View {
    let category: EquipmentCategory
    
    // Define the grid layout with 2 columns
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(category.equipmentList) { equipment in
                    NavigationLink(destination: InfoAboutEquipmentsView(equipment: equipment)) {
                        EquipmentGridCardView(equipment: equipment)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97)) // #F8F8F8
    }
}

// MARK: - Equipment Grid Card View
struct EquipmentGridCardView: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    @State private var isLiked: Bool = false
    @State private var likeCount: Int = 0
    @State private var isPressed: Bool = false
    @State private var isUpdatingLike: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Circular Image Container
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "tractor")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58)) // #8E8E93
                        .frame(width: 40, height: 40)
                        .frame(width: 100, height: 100)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            .overlay(
                Circle()
                    .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 2) // #E8E8E8
            )
            .padding(.top, 24)
            
            // Equipment Name
            Text(equipment.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.12)) // #1C1C1E
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .frame(maxWidth: .infinity)
            
            // Like Section
            HStack(spacing: 4) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 14))
                    .foregroundColor(isLiked ? Color(red: 1.0, green: 0.23, blue: 0.19) : Color(red: 0.56, green: 0.56, blue: 0.58)) // #FF3B30 : #8E8E93
                
                Text("\(likeCount)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58)) // #8E8E93
            }
            .padding(.top, 12)
            .padding(.bottom, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !isUpdatingLike else { return }
                
                // Get current user
                guard let currentUser = AuthManager.shared.currentUser else {
                    print("⚠️ No logged-in user found")
                    return
                }
                
                // Optimistically update UI
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
                
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                // Update in Supabase
                Task {
                    await toggleLikeInDatabase(userId: currentUser.id)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1) // #E5E5EA
        )
        .shadow(color: Color.black.opacity(isPressed ? 0.04 : 0.06), radius: isPressed ? 6 : 12, x: 0, y: isPressed ? 1 : 2)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .task {
            await loadImage()
            await loadLikeState()
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
    
    private func loadLikeState() async {
        // Get current user
        guard let currentUser = AuthManager.shared.currentUser else {
            print("⚠️ No logged-in user found")
            return
        }
        
        // Load the current like count from Supabase
        let count = await RequestManager.shared.getEquipmentAgriLikeCount(equipmentId: equipment.id)
        
        // Check if current user has liked this equipment
        let hasLiked = await RequestManager.shared.hasUserLikedEquipment(userId: currentUser.id, equipmentId: equipment.id)
        
        await MainActor.run {
            self.likeCount = count
            self.isLiked = hasLiked
        }
    }
    
    private func toggleLikeInDatabase(userId: UUID) async {
        isUpdatingLike = true
        defer { isUpdatingLike = false }
        
        let success = await RequestManager.shared.toggleEquipmentLike(userId: userId, equipmentId: equipment.id)
        
        if (!success) {
            // Revert the UI change if the update failed
            await MainActor.run {
                withAnimation {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
            }
            print("❌ Failed to toggle like in database")
        }
    }
}

// MARK: - Legacy Equipment List Row View (kept for compatibility)
struct EquipmentListRowView: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    
    var body: some View {
        HStack(spacing: 16) {
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
                        .padding(16)
                }
            }
            .frame(width: 80, height: 80)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Equipment Details
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let purpose = equipment.purpose {
                    Text(purpose)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let cost = equipment.averageCost {
                    Text("₹\(cost)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
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

#Preview {
    NavigationStack {
        SameTypeAllEquipmentsView(
            category: EquipmentCategory(
                id: UUID(),
                title: "All Plowing Equipments",
                equipmentList: []
            )
        )
    }
}
