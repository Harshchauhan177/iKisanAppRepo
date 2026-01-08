//
//  SelectFarmersView.swift
//  iKisanApp
//
//  SwiftUI Farmer Selection Screen - HIG-compliant design
//  Allows searching, filtering by distance, and selecting multiple farmers
//

import SwiftUI

struct SelectFarmersView: View {
    @StateObject var viewModel: SelectFarmersViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBarView(text: $viewModel.searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    // Distance Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DistanceFilter.allCases, id: \.self) { filter in
                                FilterPillView(
                                    title: filter.displayText,
                                    isSelected: viewModel.selectedDistanceFilter == filter
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.selectedDistanceFilter = filter
                                    }
                                    
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    
                    // Results Count
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .ikisanGreen))
                            Text("Calculating distances...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 60)
                    } else if viewModel.filteredFarmers.isEmpty {
                        EmptyStateView(
                            searchText: viewModel.searchText,
                            selectedFilter: viewModel.selectedDistanceFilter
                        )
                    } else {
                        HStack {
                            Text("\(viewModel.filteredFarmers.count) farmers found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        
                        // Farmers List
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.filteredFarmers) { farmer in
                                    FarmerSelectionRow(
                                        farmer: farmer,
                                        isSelected: viewModel.isSelected(farmer)
                                    ) {
                                        viewModel.toggleSelection(for: farmer)
                                    }
                                    
                                    if farmer.id != viewModel.filteredFarmers.last?.id {
                                        Divider()
                                            .padding(.leading, 74)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100) // Space for sticky button
                        }
                    }
                }
                
                // Sticky Footer Button
                if !viewModel.selectedFarmerIds.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                        
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            viewModel.confirmSelection()
                            dismiss()
                        }) {
                            HStack {
                                Spacer()
                                
                                Text("Add \(viewModel.selectedFarmerIds.count) Farmer\(viewModel.selectedFarmerIds.count == 1 ? "" : "s")")
                                    .font(.system(size: 17, weight: .semibold))
                                
                                Spacer()
                            }
                            .frame(height: 50)
                            .background(Color.ikisanGreen)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(
                                color: Color.ikisanGreen.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    }
                    .background(
                        Color.white
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Add Farmers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
            
            TextField("Search by name or phone", text: $text)
                .focused($isFocused)
                .font(.system(size: 17))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Filter Pill View

struct FilterPillView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.ikisanGreen : Color.white)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
                        )
                )
                .shadow(
                    color: isSelected ? Color.ikisanGreen.opacity(0.2) : Color.clear,
                    radius: 4,
                    x: 0,
                    y: 2
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Farmer Selection Row

struct FarmerSelectionRow: View {
    let farmer: Farmer
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Profile Image
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.ikisanGreen.opacity(0.8), Color.ikisanGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text(farmer.initials)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Farmer Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(farmer.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f km away", farmer.distance))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    if let phone = farmer.phoneNumber {
                        Text(phone)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Selection Checkbox
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.ikisanGreen : Color(.systemGray4),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.ikisanGreen : Color.clear)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let searchText: String
    let selectedFilter: DistanceFilter
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Farmers Found")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Text("No results for \"\(searchText)\"")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No farmers found within \(selectedFilter.displayText.lowercased())")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Supporting Extensions

extension Farmer {
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let firstInitial = components[0].prefix(1)
            let lastInitial = components[1].prefix(1)
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "??"
    }
}

// MARK: - Preview

#Preview {
    SelectFarmersView(
        viewModel: SelectFarmersViewModel(
            parentViewModel: CreateCoEquipGroupViewModel(
                equipment: Equipment.sampleEquipment
            )
        )
    )
}
