//
//  SelectEquipmentView.swift
//  iKisanApp
//
//  Modern SwiftUI implementation of Equipment Selection Screen
//  High-fidelity, HIG-compliant design for Co-Equip create request flow
//

import SwiftUI

/// Equipment selection screen for Co-Equip create request flow
struct SelectEquipmentView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel: SelectEquipmentViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isSearchFieldFocused: Bool // Keyboard management
    @State private var showSuggestions: Bool = false // Explicit control for suggestion visibility
    
    // MARK: - Grid Layout
    
    private let horizontalPadding: CGFloat = 16 // Unified horizontal margin
    
    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: 14),
        GridItem(.flexible(minimum: 0), spacing: 14)
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                loadingView
            } else {
                contentView
            }
        }
        .navigationTitle("Select Equipment")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $viewModel.showDatePicker) {
            datePickerSheet
        }
    }
    
    // MARK: - Main Content
    
    private var contentView: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 16) {
                    // Search Bar
                    searchBarSection
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 8)
                    
                    // Category Filters
                    categoryFiltersSection
                    
                    // Date Picker Row
                    datePickerRow
                        .padding(.horizontal, horizontalPadding)
                    
                    // Equipment Grid or Empty State
                    if viewModel.filteredEquipment.isEmpty {
                        // Non-blocking empty state - only replaces the grid
                        emptyStateContent
                            .padding(.top, 40)
                            .transition(.opacity)
                    } else {
                        equipmentGridSection
                            .padding(.horizontal, horizontalPadding)
                            .padding(.bottom, 24)
                            .transition(.opacity)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively) // Dismiss keyboard on scroll
            .scrollIndicators(.hidden)
            .animation(.easeInOut(duration: 0.25), value: viewModel.filteredEquipment.isEmpty)
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    // Dismiss suggestions when user starts scrolling
                    if showSuggestions {
                        showSuggestions = false
                    }
                }
            )
            .onChange(of: viewModel.searchText) { newValue in
                // Show suggestions when user types (minimum 2 chars)
                showSuggestions = !newValue.isEmpty && 
                                  newValue.count >= 2 && 
                                  !viewModel.searchSuggestions.isEmpty
            }
            
            // Search Suggestions Overlay
            if showSuggestions {
                searchSuggestionsOverlay
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showSuggestions)
    }
    
    // MARK: - Search Bar Section
    
    private var searchBarSection: some View {
        HStack(spacing: 10) {
            // Magnifying Glass Icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
            
            // Search Text Field
            TextField("Search equipment", text: $viewModel.searchText)
                .font(.system(size: 17))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit {
                    // Dismiss keyboard and suggestions when user taps search/return
                    showSuggestions = false
                    isSearchFieldFocused = false
                }
                .onChange(of: isSearchFieldFocused) { isFocused in
                    if !isFocused {
                        // Hide suggestions when keyboard is dismissed
                        showSuggestions = false
                    }
                }
            
            // Clear Button
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                    showSuggestions = false
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(height: 48) // Consistent height
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search equipment")
    }
    
    // MARK: - Category Filters Section
    
    private var categoryFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: viewModel.selectedCategory == category,
                        action: {
                            viewModel.selectedCategory = category
                            // Haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 6)
        }
    }
    
    // MARK: - Date Picker Row
    
    private var datePickerRow: some View {
        Button(action: {
            viewModel.showDatePicker = true
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack(spacing: 12) {
                // Calendar Icon
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    .frame(width: 20, height: 20)
                
                // Date Text
                Text(viewModel.formattedDate)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(height: 48) // Match search bar height for visual consistency
            .background(
                RoundedRectangle(cornerRadius: 10) // Match search bar corner radius
                    .fill(Color(.systemGray6)) // Match search bar background
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Select date: \(viewModel.formattedDate)")
        .accessibilityHint("Double tap to change date")
    }
    
    // MARK: - Equipment Grid Section
    
    private var equipmentGridSection: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.filteredEquipment, id: \.equipmentID) { equipment in
                NavigationLink(destination: equipmentDetailView(for: equipment)) {
                    EquipmentSelectionCard(equipment: equipment)
                }
                .buttonStyle(.plain) // Remove default NavigationLink styling
                .frame(height: 220) // Slightly increased for better proportions
            }
        }
    }
    
    /// Create equipment detail view for navigation
    @ViewBuilder
    private func equipmentDetailView(for equipment: Equipment) -> some View {
        EquipmentDetailView(
            viewModel: EquipmentDetailViewModel(
                equipment: equipment,
                bookingSource: .home,
                dataController: viewModel.dataController,
                navigationCoordinator: nil
            )
        )
    }
    
    // MARK: - Search Suggestions Overlay
    
    /// Native iOS-style search suggestions list anchored below search bar
    private var searchSuggestionsOverlay: some View {
        VStack(spacing: 0) {
            // Spacer to position suggestions below search bar
            Color.clear
                .frame(height: 8 + 48 + 8) // top padding + search bar height + small gap
            
            // Suggestions List Container
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.searchSuggestions.enumerated()), id: \.offset) { index, suggestion in
                            Button(action: {
                                handleSuggestionTap(suggestion)
                            }) {
                                HStack(spacing: 12) {
                                    // Magnifying glass icon (left)
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                        .frame(width: 20)
                                    
                                    // Suggestion text (center, left-aligned)
                                    Text(suggestion)
                                        .font(.system(size: 17))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                    
                                    // Arrow icon (right)
                                    Image(systemName: "arrow.up.left")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary.opacity(0.5))
                                        .frame(width: 20)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                                .contentShape(Rectangle()) // Ensure entire row is tappable
                            }
                            .buttonStyle(.plain)
                            
                            // Divider between rows (except after last item)
                            if index < viewModel.searchSuggestions.count - 1 {
                                Divider()
                                    .padding(.leading, 48) // Align with text, not icon
                            }
                        }
                    }
                }
                .frame(maxHeight: 200) // Max 5 rows visible at ~40pt each
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
            .padding(.horizontal, horizontalPadding)
            
            Spacer(minLength: 0)
        }
        .background(
            // Dimmed overlay - tap to dismiss
            Color.black.opacity(0.001)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissSuggestions()
                }
        )
        .edgesIgnoringSafeArea(.bottom)
    }
    
    /// Handle suggestion tap with proper state management
    private func handleSuggestionTap(_ suggestion: String) {
        // 1. Update search text
        viewModel.applySuggestion(suggestion)
        
        // 2. Hide suggestions IMMEDIATELY
        showSuggestions = false
        
        // 3. Dismiss keyboard
        isSearchFieldFocused = false
        
        // 4. Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Dismiss suggestions overlay
    private func dismissSuggestions() {
        showSuggestions = false
        isSearchFieldFocused = false
    }
    
    // MARK: - Empty State Content (Non-blocking)
    
    private var emptyStateContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("No Equipment Found")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Try selecting a different category or adjusting your search")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Optional quick action
            if viewModel.isSearchActive {
                Button(action: {
                    viewModel.clearSearch()
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Text("Clear Search")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Empty State View
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(red: 0.298, green: 0.498, blue: 0.345))
            
            Text("Loading equipment...")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Date Picker Sheet
    
    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showDatePicker = false
                    }
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    .fontWeight(.semibold)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Category Chip Component

/// Pill-shaped category filter chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 0.298, green: 0.498, blue: 0.345) : Color(.systemBackground))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title) category")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Preview

#Preview("Select Equipment View") {
    NavigationStack {
        SelectEquipmentView(
            viewModel: SelectEquipmentViewModel(
                dataController: nil,
                initialSearchSuggestion: nil
            )
        )
    }
}

#Preview("Select Equipment - With Search") {
    let viewModel = SelectEquipmentViewModel(
        dataController: nil,
        initialSearchSuggestion: "Rice"
    )
    return NavigationStack {
        SelectEquipmentView(viewModel: viewModel)
    }
}
