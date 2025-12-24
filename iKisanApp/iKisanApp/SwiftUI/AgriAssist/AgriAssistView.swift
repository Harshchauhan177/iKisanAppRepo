//
//  AgriAssistView.swift
//  iKisanApp
//
//  Created by GitHub Copilot on 24/12/25.
//

import SwiftUI

struct AgriAssistView: View {
    @StateObject private var viewModel = AgriAssistViewModel()
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Crops List
            if viewModel.isLoading {
                ProgressView("Loading crops...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredCrops.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredCrops) { crop in
                            NavigationLink(destination: EquipmentsForCropsView(crop: crop)) {
                                AgriCropRowView(crop: crop)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Select Crop")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search crops")
        .background(Color(.systemGroupedBackground))
        .onChange(of: searchText) { newValue in
            viewModel.searchCrops(with: newValue)
        }
        .task {
            await viewModel.loadCrops()
        }
    }
}

// MARK: - Agri Crop Row View
struct AgriCropRowView: View {
    let crop: AgriCrop
    @State private var image: UIImage?
    
    var body: some View {
        HStack(spacing: 16) {
            // Crop Image - Circular
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "leaf")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.green)
                        .padding(16)
                }
            }
            .frame(width: 64, height: 64)
            .background(Color(.systemGray6))
            .clipShape(Circle())
            
            // Crop Name
            Text(crop.name)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.systemGray3))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard !crop.imageName.isEmpty else { return }
        
        await MainActor.run {
            ImageCache.shared.loadImage(from: crop.imageName) { loadedImage in
                self.image = loadedImage
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No crops found")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AgriAssistView()
}
