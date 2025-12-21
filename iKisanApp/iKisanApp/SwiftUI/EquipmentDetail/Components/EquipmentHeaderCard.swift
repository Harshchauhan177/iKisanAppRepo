//
//  EquipmentHeaderCard.swift
//  iKisanApp
//
//  Floating header card with equipment info and book button
//

import SwiftUI

struct EquipmentHeaderCard: View {
    
    @ObservedObject var viewModel: EquipmentDetailViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hosted by section
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Text(viewModel.hostedByText)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 12)
            
            // Equipment name and rating
            HStack(alignment: .top) {
                Text(viewModel.equipment.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                // Rating badge - Yellow star style matching Reviews section
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.yellow)
                    
                    Text(viewModel.ratingText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
            }
            .padding(.bottom, 16)
            
            // Pricing section
            VStack(alignment: .leading, spacing: 4) {
                // Per hour pricing
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(viewModel.pricePerHourText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if viewModel.hasDiscount {
                        Text(viewModel.originalPricePerHourText)
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .strikethrough()
                    }
                }
                
                // Per acre pricing
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(viewModel.pricePerAcreText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if viewModel.hasDiscount {
                        Text(viewModel.originalPricePerAcreText)
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .strikethrough()
                    }
                }
            }
            .padding(.bottom, 12)
            
            // CoEquip status and Book button
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.coEquipText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(viewModel.locationText)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Book button
                Button(action: {
                    // Haptic feedback following HIG
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                    
                    print("📱 Book button tapped in SwiftUI EquipmentHeaderCard")
                    viewModel.bookEquipment()
                }) {
                    Text("Book")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 90, height: 44)
                        .background(Color(red: 0.298, green: 0.498, blue: 0.345))
                        .clipShape(Capsule())
                }
                .accessibilityLabel("Book this equipment")
                .accessibilityHint("Double tap to view booking options")
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}
