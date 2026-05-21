//
//  YourPrebookingCard.swift
//  iKisanApp
//
//  Card displaying an existing prebooking with equipment image, details,
//  and HIG-compliant Modify / Delete actions.
//  - Modify: Available only when status != .confirmed (COD pre-confirmation).
//            Allows updating date, area, location.
//  - Delete: Available always. Cancels the prebooking.
//

import SwiftUI

struct YourPrebookingCard: View {
    let booking: Booking
    let equipment: Equipment
    let onModify: () -> Void
    let onDelete: () -> Void
    
    /// Whether the booking can still be modified (only before provider confirmation)
    private var canModify: Bool {
        booking.status != .confirmed && booking.status != .completed
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        return formatter.string(from: booking.bookingDate)
    }
    
    private var statusColor: Color {
        switch booking.status {
        case .confirmed:
            return .green
        case .pending:
            return .blue
        case .completed:
            return .gray
        case .awaitingProvider:
            return .orange
        case .collectingPayment:
            return .yellow
        case .active:
            return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content
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
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                // Booking Details
                VStack(alignment: .leading, spacing: 5) {
                    Text(equipment.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Date & Time Slot
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Text("\(formattedDate) · \(booking.timeSlot.rawValue)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Area
                    if booking.fieldArea > 0 {
                        HStack(spacing: 5) {
                            Image(systemName: "square.dashed")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Text("\(String(format: "%.1f", booking.fieldArea)) acres")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Status Badge
                    HStack(spacing: 5) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 7, height: 7)
                        
                        Text(booking.status.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(statusColor)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 12)
            
            // Full-width Separator
            Divider()
            
            // Action Buttons Row
            HStack(spacing: 0) {
                // Modify Button
                Button(action: onModify) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .medium))
                        Text("Modify")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(canModify ? Color.ikisanGreen : Color(.systemGray3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
                .disabled(!canModify)
                .accessibilityLabel(canModify ? "Modify booking" : "Booking confirmed, cannot modify")
                
                // Vertical Divider
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 1 / UIScreen.main.scale)
                    .frame(height: 24)
                
                // Delete Button
                Button(action: onDelete) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .medium))
                        Text("Delete")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
                .accessibilityLabel("Delete booking")
            }
            .buttonStyle(.plain)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.1), lineWidth: 0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(equipment.name), \(formattedDate), \(booking.status.displayName)")
    }
}

// MARK: - Preview
#if DEBUG
struct YourPrebookingCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Pending (modifiable)
            YourPrebookingCard(
                booking: Booking(
                    userID: UUID(),
                    equipmentID: UUID(),
                    bookingType: .prebooking,
                    bookingDate: Date().addingTimeInterval(86400 * 3),
                    fieldArea: 2.5,
                    status: .pending,
                    timeSlot: .morning,
                    source: .prebooking
                ),
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
                    mielage: "500 km"
                ),
                onModify: {},
                onDelete: {}
            )
            
            // Confirmed (not modifiable)
            YourPrebookingCard(
                booking: Booking(
                    userID: UUID(),
                    equipmentID: UUID(),
                    bookingType: .prebooking,
                    bookingDate: Date().addingTimeInterval(86400 * 7),
                    fieldArea: 5.0,
                    status: .confirmed,
                    timeSlot: .afternoon,
                    source: .prebooking
                ),
                equipment: Equipment(
                    equipmentID: UUID(),
                    equipmentImage: "Harrow",
                    name: "Disc Harrow",
                    type: "Tilling",
                    capacity: "8 Feet",
                    pricePerHour: 1300.0,
                    realPricePerHour: 1500.0,
                    pricePerAcre: 650.0,
                    realPricePerAcre: 750.0,
                    providerID: UUID(),
                    rating: 4.2,
                    location: "Haryana",
                    coEquipDetail: .Available,
                    modelYear: "2024",
                    mielage: "N/A"
                ),
                onModify: {},
                onDelete: {}
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
#endif
