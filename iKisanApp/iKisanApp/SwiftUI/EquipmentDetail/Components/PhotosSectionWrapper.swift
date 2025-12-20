//
//  PhotosSectionWrapper.swift
//  iKisanApp
//
//  SwiftUI wrapper for UIKit PhotosSectionUiKitCell
//  Following Apple HIG for bridging UIKit and SwiftUI
//

import SwiftUI
import UIKit

struct PhotosSectionWrapper: UIViewRepresentable {
    
    let images: [String]
    let remainingCount: Int
    let onImageTapped: (Int) -> Void
    let onMoreTapped: () -> Void
    
    func makeUIView(context: Context) -> PhotosSectionUiKitCell {
        let cell = PhotosSectionUiKitCell(frame: .zero)
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    
    func updateUIView(_ uiView: PhotosSectionUiKitCell, context: Context) {
        // Configure the cell with images and callbacks
        uiView.configure(with: images, remainingCount: remainingCount)
        uiView.onImageTapped = onImageTapped
        uiView.onMoreTapped = onMoreTapped
    }
}

// MARK: - Enhanced Photos Section using UIKit Cell
struct PhotosSectionEnhanced: View {
    
    @ObservedObject var viewModel: EquipmentDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header following HIG
            Text("Photos")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .accessibilityAddTraits(.isHeader)
            
            // UIKit Photo Gallery Cell
            PhotosSectionWrapper(
                images: viewModel.displayImages, // Pass all images, not just visible
                remainingCount: max(0, viewModel.displayImages.count - 4), // Calculate remaining after 4 images
                onImageTapped: { index in
                    viewModel.selectImage(at: index)
                },
                onMoreTapped: {
                    viewModel.showAllPhotos()
                }
            )
            .frame(height: 180) // Fixed height matching UIKit layout
            .padding(.horizontal, 16)
        }
        //.background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    PhotosSectionEnhanced(
        viewModel: EquipmentDetailViewModel(
            equipment: Equipment.sampleEquipment,
            bookingSource: .home,
            dataController: nil,
            navigationCoordinator: nil
        )
    )
}
