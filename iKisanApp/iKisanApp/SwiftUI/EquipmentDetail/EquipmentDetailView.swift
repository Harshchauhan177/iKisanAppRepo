//
//  EquipmentDetailView.swift
//  iKisanApp
//
//  SwiftUI Equipment Detail Screen with Modern Clean Architecture
//

import SwiftUI

struct EquipmentDetailView: View {
    
    @StateObject var viewModel: EquipmentDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var showBackButton = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(spacing: 0) {
                    // Floating Header Card
                    EquipmentHeaderCard(viewModel: viewModel)
                        .padding(.top, 56)
                        .padding(.horizontal, 16)
                    
                    // Photo Gallery - Using UIKit Cell for consistency with existing flow
                    PhotosSectionEnhanced(viewModel: viewModel)
                        .padding(.top, 20)
                    
                    // Reviews Section
                    ReviewsSection(viewModel: viewModel)
                        .padding(.top, 24)
                    
                    // Location Section
                    LocationSection(viewModel: viewModel)
                        .padding(.top, 24)
                        .padding(.horizontal, 16)
                    
                    // Specifications Section
                    SpecificationsSection(viewModel: viewModel)
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGray6))
            .scrollIndicators(.hidden)
            
            // Custom Back Button (Floating with blur background)
            if showBackButton {
                Button(action: {
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    dismiss()
                }) {
                    ZStack {
                        // Blur background
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                        
                        // Border
                        Circle()
                            .strokeBorder(Color(.systemGray4), lineWidth: 0.5)
                            .frame(width: 40, height: 40)
                        
                        // Icon
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                .accessibilityLabel("Back")
                .accessibilityHint("Return to previous screen")
                .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showingImageGallery) {
            ImageGalleryView(
                images: viewModel.displayImages,
                initialIndex: viewModel.selectedImageIndex
            )
            .presentationDragIndicator(.hidden)
        }
        .onAppear {
            viewModel.loadReviews()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        EquipmentDetailView(
            viewModel: EquipmentDetailViewModel(
                equipment: Equipment.sampleEquipment,
                bookingSource: .home,
                dataController: nil,
                navigationCoordinator: nil
            )
        )
    }
}
