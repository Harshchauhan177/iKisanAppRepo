//
//  PreBookingEquipmentCard.swift
//  iKisanApp
//
//  Reusable card for available equipment in the prebooking flow.
//  Displays equipment image, name, availability, price, provider, and a "Pre Book" button.
//

import SwiftUI

struct PreBookingEquipmentCard: View {
    let equipment: Equipment
    let onPreBook: () -> Void
    let onCardTap: () -> Void
    
    var body: some View {
        Button(action: onCardTap) {
            HStack(spacing: 14) {
                // Equipment Image
                AsyncImage(url: URL(string: equipment.equipmentImage)) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.1)
                            .overlay(
                                ProgressView()
                                    .tint(Color.ikisanGreen)
                                    .scaleEffect(0.7)
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
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray.opacity(0.5))
                                )
                        }
                    @unknown default:
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                // Equipment Details
                VStack(alignment: .leading, spacing: 5) {
                    // Name
                    Text(equipment.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Availability Status
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 7, height: 7)
                        
                        Text("Available")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    // Price
                    Text("₹\(String(format: "%.1f", equipment.pricePerHour))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Hosted By
                    HStack(spacing: 5) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("Hosted By \(equipment.providerName ?? "Unknown")")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Pre Book Button
                Button(action: {
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onPreBook()
                }) {
                    Text("Pre Book")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.ikisanGreen)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Pre Book \(equipment.name)")
                .accessibilityHint("Double tap to proceed to booking review")
            }
            .padding(12)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(Color.gray.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(equipment.name), ₹\(String(format: "%.1f", equipment.pricePerHour)), Available")
        .accessibilityHint("Double tap to view equipment details")
    }
}

// MARK: - Preview
#if DEBUG
struct PreBookingEquipmentCard_Previews: PreviewProvider {
    static var previews: some View {
        PreBookingEquipmentCard(
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
                providerName: "Ravi Kumar"
            ),
            onPreBook: {},
            onCardTap: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
