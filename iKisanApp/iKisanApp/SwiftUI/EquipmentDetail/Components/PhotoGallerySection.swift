//
//  PhotoGallerySection.swift
//  iKisanApp
//
//  Mosaic photo gallery layout with "See More" overlay
//

import SwiftUI

struct PhotoGallerySection: View {
    
    @ObservedObject var viewModel: EquipmentDetailViewModel
    @State private var selectedImageIndex: Int = 0
    
    // Constants for pixel-perfect layout matching UIKit
    private let spacing: CGFloat = 10
    private let cornerRadius: CGFloat = 12
    private let leftWidthRatio: CGFloat = 0.60  // Left image takes 60% width
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Text("Photos")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            // Prepare images array with fallback
            let mainImage = viewModel.equipment.equipmentImage
            let imagesToShow = viewModel.visibleImages.count >= 3 
                ? viewModel.visibleImages 
                : Array(repeating: mainImage, count: 3)
            
            // Photo Gallery Layout - Dynamic Height Based on Width
            HStack(alignment: .top, spacing: spacing) {
                // MARK: - Left Column (Large Primary Image)
                GeometryReader { leftGeo in
                    Button(action: {
                        selectedImageIndex = 0
                        viewModel.selectImage(at: 0)
                    }) {
                        EquipmentImageView(imageName: imagesToShow[0])
                            .frame(width: leftGeo.size.width, height: leftGeo.size.height)
                            .clipped()
                            .cornerRadius(cornerRadius)
                    }
                    .buttonStyle(.plain)
                }
                // Aspect ratio drives the height (3:4 vertical rectangle)
                .aspectRatio(3/4, contentMode: .fit)
                
                // MARK: - Right Column (3 Equal-Height Items)
                GeometryReader { rightGeo in
                    let availableHeight = rightGeo.size.height
                    let totalSpacing = spacing * 2  // 2 gaps between 3 items
                    let itemHeight = (availableHeight - totalSpacing) / 3
                    
                    VStack(spacing: spacing) {
                        // Top Small Image
                        Button(action: {
                            selectedImageIndex = 1
                            viewModel.selectImage(at: 1)
                        }) {
                            EquipmentImageView(imageName: imagesToShow[1])
                                .frame(height: itemHeight)
                                .clipped()
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(.plain)
                        
                        // Middle Small Image
                        Button(action: {
                            selectedImageIndex = 2
                            viewModel.selectImage(at: 2)
                        }) {
                            EquipmentImageView(imageName: imagesToShow[2])
                                .frame(height: itemHeight)
                                .clipped()
                                .cornerRadius(cornerRadius)
                        }
                        .buttonStyle(.plain)
                        
                        // Bottom: "+ X more" Button
                        Button(action: {
                            viewModel.showingImageGallery = true
                        }) {
                            VStack(spacing: 2) {
                                Text("+ \(max(0, viewModel.displayImages.count - 3))")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("more")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: itemHeight)
                            .background(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Equipment Image View Component
struct EquipmentImageView: View {
    let imageName: String
    
    var body: some View {
        if imageName.hasPrefix("http") {
            // Remote URL image
            AsyncImage(url: URL(string: imageName)) { phase in
                switch phase {
                case .empty:
                    Color(.systemGray5)
                        .overlay(
                            ProgressView()
                                .tint(Color(red: 0.298, green: 0.498, blue: 0.345))
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color(.systemGray5)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Color(.systemGray5)
                }
            }
        } else {
            // Local asset image
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Fallback if image not found
                Color(.systemGray5)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}