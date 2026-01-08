//
//  JoinRequestInputView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 04/01/26.
//

import SwiftUI

/// Modern modal input view for accepting join requests
/// Captures field area before processing the accept action
struct JoinRequestInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JoinRequestInputViewModel
    @FocusState private var isFieldFocused: Bool
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isProcessing {
                    ProgressView("Joining request...")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 8)
                        )
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Equipment Summary
                            equipmentSummarySection
                            
                            // Field Area Input
                            fieldAreaInputSection
                            
                            // Capacity Info
                            capacityInfoSection
                            
                            // Confirm Button
                            confirmButton
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Join Co-Equip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ikisanGreen)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .onChange(of: viewModel.joinSuccessful) { success in
                if success {
                    dismiss()
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Equipment Summary Section
    
    private var equipmentSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Equipment Image
                AsyncImage(url: URL(string: viewModel.equipmentImageURL)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "tractor")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Equipment Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.equipmentName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Created by \(viewModel.creatorName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Field Area Input Section
    
    private var fieldAreaInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Field Area")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.brown)
                        .frame(width: 32)
                    
                    // Text field and unit selector side by side
                    HStack(spacing: 12) {
                        TextField("Enter area", text: $viewModel.fieldAreaInput)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 17))
                            .focused($isFieldFocused)
                            .frame(maxWidth: .infinity)
                        
                        // Unit selector dropdown
                        Menu {
                            ForEach(AreaUnit.allCases) { unit in
                                Button {
                                    viewModel.selectedUnit = unit
                                } label: {
                                    HStack {
                                        Text(unit.rawValue)
                                        if viewModel.selectedUnit == unit {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.selectedUnit.rawValue)
                                    .font(.system(size: 15, weight: .medium))
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundColor(ikisanGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(ikisanGreen.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                )
                
                // Conversion display (if not in acres)
                if !viewModel.convertedAreaText.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundColor(ikisanGreen)
                        Text(viewModel.convertedAreaText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                }
                
                // Validation message
                if !viewModel.validationMessage.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(viewModel.validationMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Capacity Info Section
    
    private var capacityInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group Capacity")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            VStack(spacing: 12) {
                // Current vs Capacity
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Total Area")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.currentTotalAreaText)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Capacity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.capacityText)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(ikisanGreen)
                    }
                }
                
                // Visual progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewModel.capacityPercentage > 0.9 ? Color.orange : ikisanGreen)
                            .frame(width: geometry.size.width * min(viewModel.capacityPercentage, 1.0))
                    }
                }
                .frame(height: 8)
                
                // Remaining space info
                if viewModel.remainingCapacity > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(ikisanGreen)
                        Text("\(viewModel.remainingCapacityText) space remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("Group is at capacity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Confirm Button
    
    private var confirmButton: some View {
        Button {
            isFieldFocused = false
            Task {
                await viewModel.confirmJoin()
            }
        } label: {
            HStack {
                if viewModel.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Confirm Join")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isValidInput ? ikisanGreen : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.isValidInput || viewModel.isProcessing)
        .padding(.top, 8)
    }
}

// MARK: - Preview

#if DEBUG
struct JoinRequestInputView_Previews: PreviewProvider {
    static var previews: some View {
        JoinRequestInputView(
            viewModel: JoinRequestInputViewModel.preview()
        )
    }
}
#endif
