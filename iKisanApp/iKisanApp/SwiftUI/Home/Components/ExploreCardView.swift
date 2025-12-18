//
//  ExploreCardView.swift
//  iKisanApp
//
//  SwiftUI Component for Explore/Recent & Recommended Card
//

import SwiftUI

struct ExploreCardView: View {
    let equipment: Equipment
    let averageRating: Double
    let onBookNow: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Equipment Image with Rating Badge
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
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
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        case .failure:
                            // Fallback to local image
                            if let uiImage = UIImage(named: equipment.equipmentImage) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            } else {
                                Color.gray.opacity(0.1)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray.opacity(0.5))
                                    )
                            }
                        @unknown default:
                            Color.gray.opacity(0.1)
                        }
                    }
                    
                    // Rating Badge
                    if averageRating > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "%.1f", averageRating))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .fill(Color.black.opacity(0.3))
                                )
                        )
                        .padding(8)
                    }
                }
            }
            .aspectRatio(1.2, contentMode: .fit)
            
            // Equipment Details
            VStack(alignment: .leading, spacing: 6) {
                // Equipment Name
                Text(equipment.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 38)
                
                // Price
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("₹\(Int(equipment.pricePerHour))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    
                    Text("/hour")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 4)
                
                // Book Now Button
                Button(action: onBookNow) {
                    Text("Book Now")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.298, green: 0.498, blue: 0.345),
                                            Color(red: 0.35, green: 0.58, blue: 0.41)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(12)
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.12), lineWidth: 0.5)
        )
    }
}

// MARK: - Scale Button Style for better touch feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#if DEBUG
struct ExploreCardView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreCardView(
            equipment: Equipment(
                equipmentID: UUID(),
                equipmentImage: "Harrow",
                name: "Harrow",
                type: "Tilling",
                capacity: "8 Feet",
                pricePerHour: 1300.0,
                realPricePerHour: 1500.0,
                pricePerAcre: 650.0,
                realPricePerAcre: 750.0,
                providerID: UUID(),
                rating: 4.5,
                location: "Punjab",
                coEquipDetail: .Available,
                modelYear: "2023",
                mielage: "N/A"
            ),
            averageRating: 4.5,
            onBookNow: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .frame(width: 200)
    }
}
#endif
