import SwiftUI
import WebKit

// MARK: - Equipment Image View
struct EquipmentImageView: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        if imageName.hasPrefix("http") {
            // Remote URL
            AsyncImage(url: URL(string: imageName)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
                    .frame(width: width, height: height)
                    .background(Color.gray.opacity(0.2))
            }
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(cornerRadius)
        } else {
            // Local asset
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()
                .cornerRadius(cornerRadius)
        }
    }
}

struct InfoAboutEquipmentsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = InfoAboutEquipmentsViewModel()
    
    let selectedEquipmentId: UUID
    let dataController: DataController
    
    // Use the same green color as the rest of the app
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Equipment Type Details Section
                    if let equipment = viewModel.equipmentTypeDetails.first {
                        EquipmentDetailsSection(equipment: equipment, ikisanGreen: ikisanGreen)
                    }
                    
                    // Related Equipment Section
                    if !viewModel.relatedEquipment.isEmpty {
                        RelatedEquipmentSection(
                            equipment: viewModel.relatedEquipment,
                            ikisanGreen: ikisanGreen,
                            onSeeAllTapped: {
                                viewModel.showAllRelatedEquipment(dataController: dataController)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("Equipment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(ikisanGreen)
                }
            }
            .accentColor(ikisanGreen)
        }
        .onAppear {
            viewModel.loadData(equipmentId: selectedEquipmentId, dataController: dataController)
        }
        .sheet(isPresented: $viewModel.showingAllEquipments) {
            if let equipments = viewModel.allEquipmentsToShow {
                AllEquipmentsView(
                    equipments: equipments, 
                    title: viewModel.sectionHeaders[viewModel.selectedSection],
                    ikisanGreen: ikisanGreen
                )
            }
        }
        .overlay(
            viewModel.isLoading ?
                ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
                .background(Color.secondary.opacity(0.2).cornerRadius(8))
                : nil
        )
    }
}

// MARK: - Equipment Details Section
struct EquipmentDetailsSection: View {
    let equipment: EquipmentAgri
    let ikisanGreen: Color
    @State private var showingVideo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            SectionHeaderView(
                title: "Equipment Type Details",
                showSeeAllButton: true,
                ikisanGreen: ikisanGreen,
                onSeeAllTapped: {
                    // Handle see all for equipment details
                }
            )
            
            // Equipment Card
            VStack(alignment: .leading, spacing: 16) {
                // Image and basic info
                HStack(spacing: 16) {
                    EquipmentImageView(
                        imageName: equipment.imageName,
                        width: 120,
                        height: 120,
                        cornerRadius: 12
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ikisanGreen.opacity(0.3), lineWidth: 1)
                    )
                    .onTapGesture {
                        showingVideo = true
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(equipment.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("\(equipment.likedBy)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(title: "Purpose", value: equipment.purpose ?? "N/A", ikisanGreen: ikisanGreen)
                    DetailRow(title: "Best For", value: equipment.bestFor ?? "N/A", ikisanGreen: ikisanGreen)
                    DetailRow(title: "Average Cost", value: equipment.averageCost ?? "N/A", ikisanGreen: ikisanGreen)
                    DetailRow(title: "Needs", value: equipment.needs ?? "N/A", ikisanGreen: ikisanGreen)
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .sheet(isPresented: $showingVideo) {
            VideoPlayerView(videoURL: "https://youtu.be/s6vK-T7JQHk", ikisanGreen: ikisanGreen)
        }
    }
}

// MARK: - Related Equipment Section
struct RelatedEquipmentSection: View {
    let equipment: [EquipmentAgri]
    let ikisanGreen: Color
    let onSeeAllTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            SectionHeaderView(
                title: "Related Equipment",
                showSeeAllButton: true,
                ikisanGreen: ikisanGreen,
                onSeeAllTapped: onSeeAllTapped
            )
            
            // Equipment Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(equipment, id: \.id) { equipment in
                    RelatedEquipmentCard(equipment: equipment, ikisanGreen: ikisanGreen)
                }
            }
        }
    }
}

// MARK: - Related Equipment Card
struct RelatedEquipmentCard: View {
    let equipment: EquipmentAgri
    let ikisanGreen: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            EquipmentImageView(
                imageName: equipment.imageName,
                width: .infinity,
                height: 120,
                cornerRadius: 12
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ikisanGreen.opacity(0.3), lineWidth: 1)
            )
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(equipment.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("\(equipment.likedBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Button("Book Now") {
                    // Navigate to home tab and search for equipment
                    navigateToHomeAndSearch(equipmentName: equipment.name)
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(ikisanGreen)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    private func navigateToHomeAndSearch(equipmentName: String) {
        // This would need to be implemented with proper navigation
        // For now, we'll just print the action
        print("Navigate to home and search for: \(equipmentName)")
    }
}

// MARK: - Section Header View
struct SectionHeaderView: View {
    let title: String
    let showSeeAllButton: Bool
    let ikisanGreen: Color
    let onSeeAllTapped: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            if showSeeAllButton {
                Button("See All") {
                    onSeeAllTapped()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ikisanGreen)
            }
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    let ikisanGreen: Color
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ikisanGreen)
                .frame(width: 90, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    let videoURL: String
    let ikisanGreen: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            WebView(url: videoURL)
                .navigationTitle("Video")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(ikisanGreen)
                    }
                }
        }
    }
}

// MARK: - WebView for Video
struct WebView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - All Equipments View
struct AllEquipmentsView: View {
    let equipments: [EquipmentAgri]
    let title: String
    let ikisanGreen: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(equipments, id: \.id) { equipment in
                        RelatedEquipmentCard(equipment: equipment, ikisanGreen: ikisanGreen)
                    }
                }
                .padding(16)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ikisanGreen)
                }
            }
            .accentColor(ikisanGreen)
        }
    }
}

// MARK: - View Model
class InfoAboutEquipmentsViewModel: ObservableObject {
    @Published var equipmentTypeDetails: [EquipmentAgri] = []
    @Published var relatedEquipment: [EquipmentAgri] = []
    @Published var sectionHeaders: [String] = []
    @Published var showingAllEquipments = false
    @Published var allEquipmentsToShow: [EquipmentAgri]?
    @Published var selectedSection = 0
    @Published var isLoading = false
    
    func loadData(equipmentId: UUID, dataController: DataController) {
        isLoading = true
        sectionHeaders = dataController.getEquipmentSectionHeaders()
        
        Task {
            do {
                // Load equipment details
                let details: [EquipmentAgri] = try await SupabaseManager.shared.client
                    .from("equipmentAgri")
                    .select("*")
                    .eq("id", value: equipmentId)
                    .execute()
                    .value
                
                await MainActor.run {
                    self.equipmentTypeDetails = details
                }
                
                if let firstEquipment = details.first {
                    // Load related equipment
                    let related: [EquipmentAgri] = try await SupabaseManager.shared.client
                        .from("equipmentAgri")
                        .select()
                        .eq("categoryId", value: firstEquipment.categoryId)
                        .neq("id", value: equipmentId)
                        .execute()
                        .value
                    
                    await MainActor.run {
                        self.relatedEquipment = related
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                print("Error loading equipment data: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func showAllRelatedEquipment(dataController: DataController) {
        selectedSection = 1
        allEquipmentsToShow = dataController.getRelatedEquipment()
        showingAllEquipments = true
    }
} 