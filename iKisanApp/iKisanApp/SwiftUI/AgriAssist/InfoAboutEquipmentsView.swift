//
//  InfoAboutEquipmentsView.swift
//  iKisanApp
//
//  Created by GitHub Copilot on 24/12/25.
//

import SwiftUI

struct InfoAboutEquipmentsView: View {
    let equipment: EquipmentAgri
    @State private var image: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Equipment Image
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "tractor")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .padding(40)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Equipment Name
                Text(equipment.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Details Section
                if let purpose = equipment.purpose {
                    DetailCard(title: "Purpose", content: purpose, icon: "target")
                }
                
                if let bestFor = equipment.bestFor {
                    DetailCard(title: "Best For", content: bestFor, icon: "star")
                }
                
                if let cost = equipment.averageCost {
                    DetailCard(title: "Average Cost", content: "₹\(cost)", icon: "indianrupeesign.circle")
                }
                
                if let needs = equipment.needs {
                    DetailCard(title: "Requirements", content: needs, icon: "checklist")
                }
                
                // Likes
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(equipment.likedBy) farmers like this")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .padding()
        }
        .navigationTitle("Equipment Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
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

// MARK: - Detail Card
struct DetailCard: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        InfoAboutEquipmentsView(
            equipment: EquipmentAgri(
                id: UUID(),
                categoryId: UUID(),
                name: "Tractor",
                imageName: "",
                purpose: "Plowing and tilling the soil",
                bestFor: "Large fields",
                averageCost: "500-800 per hour",
                needs: "Diesel fuel and trained operator",
                likedBy: 150
            )
        )
    }
}
