//
//  PrebookingCardComponents.swift
//  iKisanApp
//
//  Created on 30/12/25.
//

import SwiftUI

// MARK: - Recommended Equipment Card

struct RecommendedEquipmentCard: View {
    let equipment: Equipment
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Equipment Image
            AsyncImage(url: URL(string: equipment.equipmentImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 320, height: 150)
            .clipped()
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            
            // Text Content
            VStack(alignment: .leading, spacing: 2) {
                Text(equipment.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let description = equipment.description {
                    Text(description)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(width: 320, height: 150)
        .background(Color(red: 0.298, green: 0.498, blue: 0.345))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// MARK: - Available Equipment Card

struct AvailableEquipmentCard: View {
    let equipment: Equipment
    let onPreBook: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Equipment Image
            AsyncImage(url: URL(string: equipment.equipmentImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .clipped()
            
            // Equipment Info
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    
                    Text("Available")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("₹\(Int(equipment.pricePerHour))")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("Hosted By \(equipment.providerName ?? "Unknown")")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Pre Book Button
            Button(action: onPreBook) {
                Text("Pre Book")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.298, green: 0.498, blue: 0.345))
                    .cornerRadius(20)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Prebooking Card

struct PrebookingCard: View {
    let booking: Booking
    let equipment: Equipment
    let onModify: () -> Void
    let onCancel: () -> Void
    
    @State private var showCancelAlert = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: booking.bookingDate)
    }
    
    private var statusColor: Color {
        switch booking.status {
        case .pending:
            return .blue
        case .confirmed:
            return Color(red: 0.298, green: 0.498, blue: 0.345)
        case .completed:
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Equipment Image
            AsyncImage(url: URL(string: equipment.equipmentImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .clipped()
            
            // Booking Info
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(booking.status.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(statusColor)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 5) {
                Button(action: onModify) {
                    Text("Modify")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 93, height: 36)
                        .background(Color(red: 0.298, green: 0.498, blue: 0.345))
                        .cornerRadius(18)
                }
                
                Button(action: { showCancelAlert = true }) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 93, height: 36)
                        .background(Color.red)
                        .cornerRadius(18)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("Cancel Prebooking", isPresented: $showCancelAlert) {
            Button("No, Keep Booking", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                onCancel()
            }
        } message: {
            Text("Are you sure you want to cancel this prebooking for \(equipment.name)?")
        }
    }
}

// MARK: - FAQ Row

struct FAQRow: View {
    let faq: FAQ
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(faq.question)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            
            if !isLast {
                Divider()
                    .padding(.leading, 16)
            }
        }
        .background(Color.white)
        .cornerRadius(isFirst ? 10 : 0, corners: [.topLeft, .topRight])
        .cornerRadius(isLast ? 10 : 0, corners: [.bottomLeft, .bottomRight])
    }
}
