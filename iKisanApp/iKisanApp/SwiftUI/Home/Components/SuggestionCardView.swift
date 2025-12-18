//
//  SuggestionCardView.swift
//  iKisanApp
//
//  SwiftUI Component for Suggestion Card
//

import SwiftUI

struct SuggestionCardView: View {
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
                    // Fallback to local image
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
            .frame(height: 200)
            .clipped()
            
            // Gradient overlay for better text readability
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
                
                if let description = equipment.description {
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                } else {
                    Text("Perfect for your farming needs")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
#if DEBUG
struct SuggestionCardView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionCardView(
            equipment: Equipment(
                equipmentID: UUID(),
                equipmentImage: "JohnDeer Tractor",
                name: "JohnDeer Tractor",
                type: "Tractor",
                capacity: "50HP",
                pricePerHour: 1100.0,
                realPricePerHour: 1375.0,
                pricePerAcre: 0,
                realPricePerAcre: 0,
                providerID: UUID(),
                rating: 5.0,
                location: "Punjab",
                coEquipDetail: .Available,
                modelYear: "2024",
                mielage: "12 km/l",
                description: "Good for the agriculture"
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .frame(width: 350)
    }
}
#endif
