//
//  SpecificationsSection.swift
//  iKisanApp
//
//  Equipment specifications in a grid layout
//

import SwiftUI

struct SpecificationsSection: View {
    
    @ObservedObject var viewModel: EquipmentDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Text("Specifications")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            // Specifications Grid
            HStack(spacing: 12) {
                // Model
                SpecificationItem(
                    icon: "gear",
                    title: "Model",
                    value: viewModel.equipment.modelYear
                )
                
                // Capacity
                SpecificationItem(
                    icon: "scalemass",
                    title: "Capacity",
                    value: viewModel.equipment.capacity
                )
                
                // Mileage
                SpecificationItem(
                    icon: "fuelpump",
                    title: "Mileage",
                    value: viewModel.equipment.mielage
                )
            }
        }
    }
}

// MARK: - Specification Item Component
struct SpecificationItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                .frame(height: 32)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}
