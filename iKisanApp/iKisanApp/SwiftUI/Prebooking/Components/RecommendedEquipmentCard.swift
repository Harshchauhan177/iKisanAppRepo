//
//  RecommendedEquipmentCard.swift
//  iKisanApp
//
//  Reusable horizontal recommended equipment card with green gradient overlay.
//  Used in Pre Booking landing screen's "Recommended" section.
//

import SwiftUI

struct RecommendedEquipmentCard: View {
    let equipment: Equipment
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Equipment Image
            AsyncImage(url: URL(string: equipment.equipmentImage)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.1)
                        .overlay(
                            ProgressView()
                                .tint(Color(red: 0.298, green: 0.498, blue: 0.345))
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    if let uiImage = UIImage(named: equipment.equipmentImage) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray.opacity(0.1)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                    }
                @unknown default:
                    Color.gray.opacity(0.1)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipped()
            
            // Gradient overlay for text readability (matches SuggestionCardView)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.4),
                    Color.clear
                ]),
                startPoint: .bottom,
                endPoint: .center
            )
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                Text(equipment.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let description = equipment.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                } else {
                    Text(equipment.type)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(equipment.name), \(equipment.type)")
        .accessibilityHint("Double tap to view equipment details")
    }
}

// MARK: - Preview
#if DEBUG
struct RecommendedEquipmentCard_Previews: PreviewProvider {
    static var previews: some View {
        RecommendedEquipmentCard(
            equipment: Equipment(
                equipmentID: UUID(),
                equipmentImage: "Harrow",
                name: "Rice Harvester",
                type: "Harvesting",
                capacity: "5 HP",
                pricePerHour: 1100.0,
                realPricePerHour: 1100.0,
                pricePerAcre: 500.0,
                realPricePerAcre: 500.0,
                providerID: UUID(),
                rating: 4.5,
                location: "Punjab",
                coEquipDetail: .Available,
                modelYear: "2023",
                mielage: "500 km",
                description: "Efficient rice harvesting machine"
            )
        )
        .frame(width: 300)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
