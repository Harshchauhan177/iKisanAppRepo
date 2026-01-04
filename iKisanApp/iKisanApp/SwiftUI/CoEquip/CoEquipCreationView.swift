//
//  CoEquipCreationView.swift
//  iKisanApp
//
//  Placeholder view for Co-Equip booking flow
//  This will be the entry point for creating Co-Equip requests
//

import SwiftUI

/// Placeholder view for Co-Equip creation flow
struct CoEquipCreationView: View {
    
    @Environment(\.dismiss) private var dismiss
    let equipment: Equipment
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "person.3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                
                VStack(spacing: 12) {
                    Text("Co-Equip Booking Flow")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Coming Soon")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Equipment info
                VStack(spacing: 8) {
                    Text("Selected Equipment:")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(equipment.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Info card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                        Text("What is Co-Equip?")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text("Join with nearby farmers to share equipment costs and reduce expenses. This feature will allow you to create or join Co-Equip requests.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Co-Equip Booking")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CoEquipCreationView(equipment: Equipment.sampleEquipment)
    }
}
