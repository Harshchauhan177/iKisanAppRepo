//
//  BookingCardView.swift
//  iKisanApp
//
//  SwiftUI Component for Upcoming Booking Card
//

import SwiftUI

struct BookingCardView: View {
    let booking: Booking
    let equipment: Equipment
    let onViewTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Equipment Image - Larger and more prominent
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
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                    }
                @unknown default:
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            // Booking Details
            VStack(alignment: .leading, spacing: 6) {
                // Equipment Name
                Text(equipment.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Date and Time
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(formatBookingDate(booking.bookingDate, timeSlot: booking.timeSlot))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 2)
                
                // Status and Booking Type Badges (Stacked vertically for better readability)
                HStack(spacing: 6) {
                    // Status Badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor(for: booking.status))
                            .frame(width: 6, height: 6)
                        
                        Text(booking.status.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(statusColor(for: booking.status))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(statusColor(for: booking.status).opacity(0.12))
                    )
                    
                    // Booking Type Badge
                    Text(bookingTypeLabel(for: booking.bookingType))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                        )
                    
                    Spacer()
                }
            }
            
            Spacer(minLength: 0)
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(14)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.08), lineWidth: 0.5)
        )
        .onTapGesture {
            onViewTapped()
        }
    }
    
    private func statusColor(for status: BookingStatus) -> Color {
        switch status {
        case .confirmed:
            return Color(red: 0.298, green: 0.498, blue: 0.345) // Green
        case .pending:
            return .orange
        case .completed:
            return Color(red: 0.0, green: 0.478, blue: 1.0) // Blue
        case .awaitingProvider:
            return .orange
        case .collectingPayment:
            return .yellow
        case .active:
            return Color(red: 0.298, green: 0.498, blue: 0.345) // Green
        }
    }
    
    private func bookingTypeLabel(for bookingType: BookingType) -> String {
        switch bookingType {
        case .onDemand:
            return "On-Demand"
        case .prebooking:
            return "Pre-Booking"
        case .coEquip:
            return "Co-Equip"
        }
    }
    
    private func bookingTypeColor(for bookingType: BookingType) -> Color {
        switch bookingType {
        case .onDemand:
            return .purple
        case .prebooking:
            return Color(red: 0.0, green: 0.478, blue: 1.0) // iOS system blue
        case .coEquip:
            return Color(red: 0.298, green: 0.498, blue: 0.345) // iKisan green
        }
    }
    
    private func formatBookingDate(_ date: Date, timeSlot: TimeSlot) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM"
        return "\(formatter.string(from: date)) • \(timeSlot.rawValue)"
    }
}

// MARK: - Preview
#if DEBUG
struct BookingCardView_Previews: PreviewProvider {
    static var previews: some View {
        BookingCardView(
            booking: Booking(
                userID: UUID(),
                equipmentID: UUID(),
                bookingType: .onDemand,
                bookingDate: Date(),
                fieldArea: 5.0,
                status: .confirmed,
                timeSlot: .morning,
                source: .home
            ),
            equipment: Equipment(
                equipmentID: UUID(),
                equipmentImage: "Mahindra Tractor",
                name: "Mahindra Tractor",
                type: "Tractor",
                capacity: "45HP",
                pricePerHour: 1000.0,
                realPricePerHour: 1200.0,
                pricePerAcre: 0,
                realPricePerAcre: 0,
                providerID: UUID(),
                rating: 4.5,
                location: "Delhi",
                coEquipDetail: .Available,
                modelYear: "2023",
                mielage: "10 km/l"
            ),
            onViewTapped: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .frame(width: 350)
    }
}
#endif
