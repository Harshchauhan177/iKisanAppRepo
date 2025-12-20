//
//  ReviewsSection.swift
//  iKisanApp
//
//  Reviews section with rating summary and horizontal scrolling cards
//

import SwiftUI

struct ReviewsSection: View {
    
    @ObservedObject var viewModel: EquipmentDetailViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header with Rating and Write Review Button
            HStack(alignment: .center, spacing: 12) {
                // Rating display
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.formattedAverageRating)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: starIcon(for: index, rating: viewModel.averageRating))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(viewModel.reviewCountText)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Write a Review button - Always visible
                Button(action: {
                    viewModel.writeReview()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                        
                        Text("Write a Review")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    }
                    .frame(width: 90)
                }
                
                // See All button
                Button(action: {
                    // Show all reviews
                }) {
                    Text("See All")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
            }
            .padding(.horizontal, 16)
            
            // Reviews List (Horizontal Scroll)
            if !viewModel.filteredReviews.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.filteredReviews, id: \.id) { review in
                            ReviewCard(review: review)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    private func starIcon(for index: Int, rating: Double) -> String {
        if Double(index) < rating {
            if Double(index + 1) <= rating {
                return "star.fill"
            } else if Double(index) + 0.5 <= rating {
                return "star.leadinghalf.filled"
            }
        }
        return "star"
    }
}

// MARK: - Review Card Component
struct ReviewCard: View {
    let review: ReviewData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Heading and Stars
            VStack(alignment: .leading, spacing: 6) {
                // Review Heading
                if !review.reviewHeading.isEmpty {
                    Text(review.reviewHeading)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Rating Stars
                HStack(spacing: 3) {
                    ForEach(0..<5) { index in
                        Image(systemName: starIcon(for: index))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            // Review Description
            Text(review.reviewDescription)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
            
            // Reviewer info at bottom
            Divider()
                .padding(.top, 4)
            
            HStack(spacing: 8) {
                // Reviewer initial avatar
                Circle()
                    .fill(Color(red: 0.298, green: 0.498, blue: 0.345).opacity(0.15))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(String(review.reviewerName.prefix(1).uppercased()))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(formatDate(review.date))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(14)
        .frame(width: 280, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 2)
        )
    }
    
    private func starIcon(for index: Int) -> String {
        let rating = review.rating
        if Double(index) < rating {
            if Double(index + 1) <= rating {
                return "star.fill"
            } else if Double(index) + 0.5 <= rating {
                return "star.leadinghalf.filled"
            }
        }
        return "star"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
