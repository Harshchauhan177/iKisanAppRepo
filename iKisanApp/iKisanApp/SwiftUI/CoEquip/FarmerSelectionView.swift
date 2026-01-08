//
//  FarmerSelectionView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 03/01/26.
//

import SwiftUI

/// Multi-selection view for inviting farmers to a Co-Equip request
/// Follows HIG with search, filtering, and multi-selection patterns
struct FarmerSelectionView: View {
    @ObservedObject var viewModel: FarmerSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    
                    // Farmers list
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Spacer()
                    } else if viewModel.filteredFarmers.isEmpty {
                        emptyStateView
                    } else {
                        farmersList
                    }
                }
            }
            .navigationTitle("Select Farmers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ikisanGreen)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.completeSelection()
                        dismiss()
                    }
                    .foregroundColor(ikisanGreen)
                    .fontWeight(.semibold)
                    .disabled(viewModel.selectedFarmers.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                TextField("Search farmers", text: $viewModel.searchText)
                    .font(.system(size: 17))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    // MARK: - Farmers List
    
    private var farmersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredFarmers) { farmer in
                    FarmerRowView(
                        farmer: farmer,
                        isSelected: viewModel.isSelected(farmer),
                        onTap: {
                            viewModel.toggleSelection(farmer)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Farmers Found")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(viewModel.searchText.isEmpty
                 ? "There are no available farmers to invite"
                 : "No farmers match your search")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Farmer Row View

struct FarmerRowView: View {
    let farmer: User
    let isSelected: Bool
    let onTap: () -> Void
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // User Avatar
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.gray)
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(farmer.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(farmer.phone)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(farmer.location.address ?? "Unknown Location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ikisanGreen)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? ikisanGreen : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
struct FarmerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FarmerSelectionView(
            viewModel: FarmerSelectionViewModel.preview()
        )
    }
}
#endif
