import SwiftUI

struct InfoAboutEquipmentsView: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    @State private var expandedSection: String? = nil
    @State private var isLiked: Bool = false
    @State private var likeCount: Int
    @State private var isUpdatingLike: Bool = false
    
    init(equipment: EquipmentAgri) {
        self.equipment = equipment
        self._likeCount = State(initialValue: equipment.likedBy)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Main Equipment Card
                VStack(alignment: .leading, spacing: 0) {
                    // Equipment Image with Play Button Overlay
                    ZStack {
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
                                    .padding(40)
                                    .background(Color(hex: "F2F2F7"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 207)
                        .clipped()
                        
                        // Play Button Overlay
                        Button(action: {
                            // Play video action
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Equipment Information
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Likes
                        VStack(alignment: .leading, spacing: 8) {
                            Text(equipment.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "1C1C1E"))
                            
                            Button(action: {
                                Task {
                                    await toggleLike()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(isLiked ? Color(hex: "FF3B30") : Color(hex: "8E8E93"))
                                    Text("\(likeCount) likes")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                }
                            }
                            .disabled(isUpdatingLike)
                            .opacity(isUpdatingLike ? 0.6 : 1.0)
                        }
                        
                        // Expandable Information Pills
                        VStack(spacing: 12) {
                            if let purpose = equipment.purpose {
                                ExpandablePill(
                                    title: "Purpose",
                                    content: purpose,
                                    isExpanded: expandedSection == "purpose"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "purpose" ? nil : "purpose"
                                    }
                                }
                            }
                            
                            if let bestFor = equipment.bestFor {
                                ExpandablePill(
                                    title: "Best for",
                                    content: bestFor,
                                    isExpanded: expandedSection == "bestFor"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "bestFor" ? nil : "bestFor"
                                    }
                                }
                            }
                            
                            if let cost = equipment.averageCost {
                                ExpandablePill(
                                    title: "Average cost",
                                    content: cost,
                                    isExpanded: expandedSection == "cost"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "cost" ? nil : "cost"
                                    }
                                }
                            }
                            
                            if let needs = equipment.needs {
                                ExpandablePill(
                                    title: "Maintenance",
                                    content: needs,
                                    isExpanded: expandedSection == "maintenance"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "maintenance" ? nil : "maintenance"
                                    }
                                }
                            }
                        }
                        
                        // Buy Now Button
                        Button(action: {
                            // Buy action
                        }) {
                            Text("Buy Now")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "007AFF"))
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Related Equipment Section
                RelatedEquipmentSection(categoryId: equipment.categoryId, currentEquipmentId: equipment.id)
                    .padding(.top, 32)
                    .padding(.bottom, 32)
            }
        }
        .navigationTitle("Equipment Details")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(hex: "F8F8F8"))
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
    
    private func toggleLike() async {
        guard !isUpdatingLike else { return }
        
        // Check if user is logged in
        guard let currentUser = AuthManager.shared.currentUser else {
            print("⚠️ No logged-in user found")
            return
        }
        
        isUpdatingLike = true
        
        // Optimistic UI update
        let previousLiked = isLiked
        let previousCount = likeCount
        
        await MainActor.run {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isLiked.toggle()
                likeCount = isLiked ? likeCount + 1 : likeCount - 1
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Update in Supabase using RequestManager
        let success = await RequestManager.shared.toggleEquipmentLike(userId: currentUser.id, equipmentId: equipment.id)
        
        if !success {
            // Revert the UI change if the update failed
            await MainActor.run {
                withAnimation {
                    isLiked = previousLiked
                    likeCount = previousCount
                }
            }
            print("❌ Failed to toggle like in database")
        } else {
            print("✅ Successfully toggled like")
        }
        
        await MainActor.run {
            isUpdatingLike = false
        }
    }
}

// MARK: - Expandable Pill
struct ExpandablePill: View {
    let title: String
    let content: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1C1C1E"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "3C3C43").opacity(0.8))
                    .lineLimit(isExpanded ? nil : 1)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F2F2F7"))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Related Equipment Section
struct RelatedEquipmentSection: View {
    let categoryId: UUID
    let currentEquipmentId: UUID
    @State private var relatedEquipment: [EquipmentAgri] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text("Related Equipment")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "1C1C1E"))
                
                Spacer()
                
                if !relatedEquipment.isEmpty {
                    Text("\(relatedEquipment.count) items")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // Equipment Grid
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if relatedEquipment.isEmpty {
                Text("No related equipment available")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(relatedEquipment) { equipment in
                        RelatedEquipmentCard(equipment: equipment)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .task {
            await loadRelatedEquipment()
        }
    }
    
    private func loadRelatedEquipment() async {
        isLoading = true
        
        do {
            let equipmentList: [EquipmentAgri] = try await SupabaseManager.shared.client
                .from("equipmentAgri")
                .select("*")
                .eq("categoryId", value: categoryId)
                .neq("id", value: currentEquipmentId)
                .execute()
                .value
            
            await MainActor.run {
                self.relatedEquipment = equipmentList
                self.isLoading = false
            }
        } catch {
            print("❌ Error loading related equipment: \(error)")
            await MainActor.run {
                self.relatedEquipment = []
                self.isLoading = false
            }
        }
    }
}

// MARK: - Related Equipment Card
struct RelatedEquipmentCard: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    @State private var isLiked: Bool = false
    @State private var likeCount: Int
    @State private var isUpdatingLike: Bool = false
    
    init(equipment: EquipmentAgri) {
        self.equipment = equipment
        self._likeCount = State(initialValue: equipment.likedBy)
    }
    
    var body: some View {
        NavigationLink(destination: InfoAboutEquipmentsView(equipment: equipment)) {
            VStack(alignment: .leading, spacing: 8) {
                // Equipment Image (1:1 aspect ratio)
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Image(systemName: "tractor")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray.opacity(0.3))
                            .padding(30)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
                .background(Color(hex: "F2F2F7"))
                .cornerRadius(12)
                
                // Equipment Name
                Text(equipment.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "1C1C1E"))
                    .lineLimit(1)
                
                // Likes - Interactive Button
                Button(action: {
                    Task {
                        await toggleLike()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 11))
                            .foregroundColor(isLiked ? Color(hex: "FF3B30") : Color(hex: "8E8E93"))
                        Text("\(likeCount)")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                }
                .disabled(isUpdatingLike)
                .opacity(isUpdatingLike ? 0.6 : 1.0)
                
                // Book Now Button
                Button(action: {
                    // Book action
                }) {
                    Text("Book Now")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "007AFF"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "007AFF"), lineWidth: 2)
                        )
                        .cornerRadius(18)
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "E5E5EA"), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
    
    private func toggleLike() async {
        guard !isUpdatingLike else { return }
        
        // Check if user is logged in
        guard let currentUser = AuthManager.shared.currentUser else {
            print("⚠️ No logged-in user found")
            return
        }
        
        isUpdatingLike = true
        
        // Optimistic UI update
        let previousLiked = isLiked
        let previousCount = likeCount
        
        await MainActor.run {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isLiked.toggle()
                likeCount = isLiked ? likeCount + 1 : likeCount - 1
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Update in Supabase using RequestManager
        let success = await RequestManager.shared.toggleEquipmentLike(userId: currentUser.id, equipmentId: equipment.id)
        
        if !success {
            // Revert the UI change if the update failed
            await MainActor.run {
                withAnimation {
                    isLiked = previousLiked
                    likeCount = previousCount
                }
            }
            print("❌ Failed to toggle like in database")
        } else {
            print("✅ Successfully toggled like for related equipment")
        }
        
        await MainActor.run {
            isUpdatingLike = false
        }
    }
}

#Preview {
    NavigationStack {
        InfoAboutEquipmentsView(
            equipment: EquipmentAgri(
                id: UUID(),
                categoryId: UUID(),
                name: "Rotary Tiller",
                imageName: "",
                purpose: "Soil Breaking & Mixing",
                bestFor: "Medium to Large Fields",
                averageCost: "$45–65 per hour",
                needs: "Regular blade sharpening",
                likedBy: 142
            )
        )
    }
}
