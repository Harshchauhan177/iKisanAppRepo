//
//  DiscountCardView.swift
//  iKisanApp
//
//  SwiftUI Component for Discount Card
//

import SwiftUI

struct DiscountCardView: View {
    let equipment: Equipment
    let averageRating: Double
    
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
                    // Fallback to local image
                    if let uiImage = UIImage(named: equipment.equipmentImage) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray.opacity(0.1)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                    }
                @unknown default:
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: 140, height: 140)
            .clipped()
            
            // Gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.3),
                    Color.clear
                ]),
                startPoint: .bottom,
                endPoint: .center
            )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text("₹\(Int(equipment.pricePerHour))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if averageRating > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "%.1f", averageRating))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(10)
        }
        .frame(width: 140, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Preview
#if DEBUG
struct DiscountCardView_Previews: PreviewProvider {
    static var previews: some View {
        DiscountCardView(
            equipment: Equipment(
                equipmentID: UUID(),
                equipmentImage: "Rotavator",
                name: "Rotavator",
                type: "Tilling",
                capacity: "5HP",
                pricePerHour: 1000.0,
                realPricePerHour: 1250.0,
                pricePerAcre: 500.0,
                realPricePerAcre: 625.0,
                providerID: UUID(),
                rating: 4.5,
                location: "Delhi",
                coEquipDetail: .Available,
                modelYear: "2023",
                mielage: "10 km/l"
            ),
            averageRating: 4.5
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
