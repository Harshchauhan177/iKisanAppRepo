//
//  EquipmentSelectionCard.swift
//  iKisanApp
//
//  Reusable equipment card component for selection grid
//

import SwiftUI

/// Equipment card component with image, rating, pricing, and host info
struct EquipmentSelectionCard: View {
    
    // MARK: - Properties
    
    let equipment: Equipment
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    // MARK: - Computed Properties
    
    private var pricePerHourText: String {
        "₹\(Int(equipment.pricePerHour))/hr"
    }
    
    private var originalPriceText: String {
        "₹\(Int(equipment.realPricePerHour))"
    }
    
    private var hasDiscount: Bool {
        equipment.pricePerHour < equipment.realPricePerHour
    }
    
    private var hostText: String {
        "Hosted by \(equipment.providerName ?? "Unknown")"
    }
    
    private var ratingText: String {
        String(format: "%.1f", equipment.rating)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Equipment Image with Rating Badge (60% of card height)
            equipmentImageSection
                .frame(height: 132) // 60% of 220pt card height
            
            // Equipment Details (40% of card height)
            VStack(alignment: .leading, spacing: 6) {
                // Equipment Name
                Text(equipment.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1) // Strict 1 line limit
                    .truncationMode(.tail)
                
                // Pricing Row with better spacing
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    // Discounted Price
                    Text(pricePerHourText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Original Price (if discounted)
                    if hasDiscount {
                        Text(originalPriceText)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary.opacity(0.8))
                            .strikethrough(true, color: .secondary)
                    }
                }
                .padding(.top, 2)
                
                // Host Info with better contrast
                Text(hostText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.9)) // Better readability
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12)) // Ensure tap area matches card shape
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(equipment.name), \(pricePerHourText), \(hostText), Rating \(ratingText)")
        .accessibilityHint("Double tap to view equipment details")
    }
    
    // MARK: - Subviews
    
    /// Equipment image section with rating badge overlay
    private var equipmentImageSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                // Equipment Image
                AsyncImage(url: URL(string: equipment.equipmentImage)) { phase in
                    switch phase {
                    case .empty:
                        // Placeholder while loading
                        Color(.systemGray5)
                            .overlay {
                                ProgressView()
                                    .tint(.gray)
                            }
                        
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        
                    case .failure:
                        // Fallback to local image or placeholder
                        if let localImage = UIImage(named: equipment.equipmentImage) {
                            Image(uiImage: localImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            // Final fallback
                            Color(.systemGray4)
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                        .foregroundColor(.secondary)
                                }
                        }
                        
                    @unknown default:
                        Color(.systemGray5)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                
                // Rating Badge
                ratingBadge
                    .padding([.trailing, .bottom], 8)
            }
        }
    }
    
    /// Green rating badge with star icon
    private var ratingBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
            
            Text(ratingText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(red: 0.298, green: 0.498, blue: 0.345))
        )
        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview

#Preview("Equipment Card") {
    let sampleEquipment = Equipment(
        equipmentID: UUID(),
        equipmentImage: "Rice",
        name: "Rice Harvester Pro 3000",
        type: "Combine",
        capacity: "5 acres/hour",
        pricePerHour: 1200,
        realPricePerHour: 1500,
        pricePerAcre: 300,
        realPricePerAcre: 400,
        providerID: UUID(),
        rating: 4.5,
        location: "Murshadpur, Greater Noida",
        coEquipDetail: .Available,
        modelYear: "2023",
        mielage: "15 km/l",
        description: "High efficiency rice harvester",
        providerName: "Harsh Chauhan"
    )
    
    VStack {
        EquipmentSelectionCard(equipment: sampleEquipment)
        .frame(width: 180, height: 200)
        
        Spacer()
    }
    .padding()
    .background(Color(.systemGray6))
}
