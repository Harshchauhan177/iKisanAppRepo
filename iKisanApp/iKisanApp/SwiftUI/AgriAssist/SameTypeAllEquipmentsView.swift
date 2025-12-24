//
//  SameTypeAllEquipmentsView.swift
//  iKisanApp
//
//  Created by GitHub Copilot on 24/12/25.
//

import SwiftUI

struct SameTypeAllEquipmentsView: View {
    let category: EquipmentCategory
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(category.equipmentList) { equipment in
                    NavigationLink(destination: InfoAboutEquipmentsView(equipment: equipment)) {
                        EquipmentListRowView(equipment: equipment)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Equipment List Row View
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
                title: "Tractors",
                equipmentList: []
            )
        )
    }
}
