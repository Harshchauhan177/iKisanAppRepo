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
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // Booking Details
            VStack(alignment: .leading, spacing: 8) {
                // Equipment Name
                Text(equipment.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Date and Time
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(formatBookingDate(booking.bookingDate, timeSlot: booking.timeSlot))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // Status Badge
                HStack(spacing: 8) {
                    Text(booking.status.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(statusColor(for: booking.status))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor(for: booking.status).opacity(0.15))
                        )
                    
                    Spacer()
                }
            }
            
            Spacer(minLength: 0)
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.1), lineWidth: 0.5)
        )
        .onTapGesture {
            onViewTapped()
        }
    }
    
    private func statusColor(for status: BookingStatus) -> Color {
        switch status {
        case .confirmed:
            return Color(red: 0.298, green: 0.498, blue: 0.345)
        case .pending:
            return .orange
        case .completed:
            return .blue
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
