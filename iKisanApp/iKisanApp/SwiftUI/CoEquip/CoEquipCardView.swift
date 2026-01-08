//
//  CoEquipCardView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 25/12/25.
//

import SwiftUI

/// A reusable card component for displaying Co-Equip requests
/// Matches the native iOS design with rounded corners, shadows, and proper spacing
struct CoEquipRequestCard: View {
    let request: CoEquipRequest
    
    var body: some View {
        HStack(spacing: 14) {
            // Equipment Image - Left (larger, more prominent)
            AsyncImage(url: URL(string: request.equipmentImageURL)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Middle Content - Equipment Details
            VStack(alignment: .leading, spacing: 5) {
                Text(request.equipmentName)
                    .font(.system(.body, design: .default).weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    Text(request.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    Text(request.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // User count row
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    Text("\(request.joinedUsersCount) joined")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right - Status Badge
            VStack(alignment: .trailing, spacing: 0) {
                StatusBadge(status: request.status)
                Spacer()
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(request.equipmentName) at \(request.location), \(request.formattedDate), \(request.joinedUsersCount) users joined, status: \(request.status.rawValue)")
    }
}

/// Status badge component showing request state
struct StatusBadge: View {
    let status: CoEquipRequestStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(status.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.12))
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .orange
        case .confirmed:
            return Color(red: 0.298, green: 0.498, blue: 0.345) // iKisan green
        case .completed:
            return Color(red: 0.0, green: 0.478, blue: 1.0) // iOS system blue
        case .cancelled:
            return Color.gray
        }
    }
}

/// Join Request Card with Accept/Reject buttons and creator name
struct CoEquipJoinRequestCard: View {
    let request: CoEquipRequest
    let creatorName: String
    let onAccept: () -> Void
    let onReject: () -> Void
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        HStack(spacing: 14) {
            // Equipment Image - Left
            AsyncImage(url: URL(string: request.equipmentImageURL)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Middle Content - Equipment Details
            VStack(alignment: .leading, spacing: 5) {
                Text(request.equipmentName)
                    .font(.system(.body, design: .default).weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    Text(request.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    Text(request.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption2)
                        .foregroundColor(ikisanGreen)
                        .frame(width: 12)
                    Text(creatorName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right - Action Buttons or Joined Badge
            if request.hasJoined {
                // Show "Joined" badge
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                        Text("Joined")
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .foregroundColor(ikisanGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(ikisanGreen.opacity(0.1))
                    .clipShape(Capsule())
                    Spacer()
                }
            } else {
                // Right - Action Buttons (Capsule shaped)
                VStack(spacing: 12) {
                    // Accept Button
                    Button(action: onAccept) {
                        Text("Accept")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 36)
                            .background(ikisanGreen)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // Reject Button
                    Button(action: onReject) {
                        Text("Reject")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.red)
                            .frame(width: 80, height: 36)
                            .background(Color.red.opacity(0.08))
                            .overlay(
                                Capsule()
                                    .stroke(Color.red, lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(request.equipmentName) by \(creatorName) at \(request.location), \(request.formattedDate)")
    }
}

#Preview("Single Card") {
    CoEquipRequestCard(
        request: CoEquipRequest(
            id: UUID(),
            equipmentName: "Rice Harvester",
            equipmentImageURL: "https://picsum.photos/200",
            location: "Girdharpur, Greater Noida",
            date: Date(),
            joinedUsersCount: 3,
            status: .pending,
            creatorName: nil,
            creatorId: nil,
            underlyingRequest: nil,
            hasJoined: false
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Join Request Card") {
    CoEquipJoinRequestCard(
        request: CoEquipRequest(
            id: UUID(),
            equipmentName: "Rice Harvester",
            equipmentImageURL: "https://picsum.photos/200",
            location: "Girdharpur, Greater Noida",
            date: Date(),
            joinedUsersCount: 0,
            status: .pending,
            creatorName: "Harsh Chauhan",
            creatorId: UUID(),
            underlyingRequest: nil,
            hasJoined: false
        ),
        creatorName: "Harsh Chauhan",
        onAccept: { print("Accept tapped") },
        onReject: { print("Reject tapped") }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
