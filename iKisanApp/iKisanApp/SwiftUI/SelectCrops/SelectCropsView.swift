//
//  SelectCropsView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI

/// SwiftUI view for selecting crops
/// Fully compliant with HIG, supports Dynamic Type, Dark Mode, and VoiceOver
struct SelectCropsView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: SelectCropsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: UUID?
    
    // MARK: - Initialization
    
    init(dataController: DataController = IKisanDataController(), isFromProfile: Bool = false) {
        _viewModel = StateObject(wrappedValue: SelectCropsViewModel(
            dataController: dataController,
            isFromProfile: isFromProfile
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    cropsList
                }
                
                continueButton
            }
        }
        .navigationTitle("Choose crops you sow")
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - View Components
    
    private var cropsList: some View {
        VStack(spacing: 0) {
            // Subtitle
            Text("You can select crops now or add them later from your profile.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .accessibilityLabel("Subtitle")
            
            // Crops List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.crops) { crop in
                        CropRowView(
                            crop: crop,
                            focusedField: $focusedField,
                            onToggle: { viewModel.toggleCropSelection(crop.id) },
                            onFieldAreaChanged: { area in
                                viewModel.updateFieldArea(for: crop.id, area: area)
                            }
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            Text("No crops available at the moment. You can continue to the app and add crops later.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
    
    private var continueButton: some View {
        Button(action: {
            Task {
                await viewModel.continueButtonTapped()
            }
        }) {
            Text(viewModel.buttonTitle)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.298, green: 0.498, blue: 0.345))
                )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .disabled(viewModel.isLoading)
        .accessibilityLabel(viewModel.buttonTitle)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Saving...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray))
            )
        }
    }
}

// MARK: - Crop Row View

/// Individual crop row with selection and field area input
private struct CropRowView: View {
    
    let crop: CropModel
    @FocusState.Binding var focusedField: UUID?
    let onToggle: () -> Void
    let onFieldAreaChanged: (String) -> Void
    
    @State private var fieldAreaText: String
    
    init(
        crop: CropModel,
        focusedField: FocusState<UUID?>.Binding,
        onToggle: @escaping () -> Void,
        onFieldAreaChanged: @escaping (String) -> Void
    ) {
        self.crop = crop
        self._focusedField = focusedField
        self.onToggle = onToggle
        self.onFieldAreaChanged = onFieldAreaChanged
        self._fieldAreaText = State(initialValue: crop.fieldArea)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main row with image and name
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Crop Image
                    AsyncCropImageView(url: crop.imageURL)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .accessibilityHidden(true)
                    
                    // Crop Name
                    Text(crop.name)
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Checkmark
                    if crop.isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                            .font(.body.weight(.semibold))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(crop.name), \(crop.isSelected ? "selected" : "not selected")")
            .accessibilityAddTraits(crop.isSelected ? .isSelected : [])
            .accessibilityHint("Tap to \(crop.isSelected ? "deselect" : "select") this crop")
            
            // Field Area Input (shown when selected)
            if crop.isSelected || !crop.fieldArea.isEmpty {
                fieldAreaInput
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.2), value: crop.isSelected)
            }
            
            // Divider
            Divider()
                .padding(.leading, 76)
        }
    }
    
    private var fieldAreaInput: some View {
        HStack(spacing: 12) {
            TextField("Enter your field area (in acres)", text: $fieldAreaText)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: crop.id)
                .onChange(of: fieldAreaText) { _, newValue in
                    onFieldAreaChanged(newValue)
                }
                .accessibilityLabel("Field area for \(crop.name)")
                .accessibilityHint("Enter the field area in acres")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    NavigationStack {
        SelectCropsView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        SelectCropsView()
    }
    .preferredColorScheme(.dark)
}

#Preview("From Profile") {
    NavigationStack {
        SelectCropsView(isFromProfile: true)
    }
}
