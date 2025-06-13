//
//  ReviewsHeaderView.swift
//  iKisanApp
//
//  Created by System on 27/05/2024.
//

import UIKit
import SwiftUICore

class ReviewsHeaderView: UIView {
    
    private let titleLabel = UILabel()
    private let ratingContainer = UIView()
    private let ratingLabel = UILabel()
    private let starStackView = UIStackView()
    private let writeReviewButton = UIButton(type: .system)
    private let separatorView = UIView()
    private let seeAllReviewsButton = UIButton(type: .system)
    private let reviewsCountLabel = UILabel()
    
    var onWriteReviewTapped: (() -> Void)?
    var onSeeAllReviewsTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        //backgroundColor = .systemBackground
        Color("#EBEBEB") // Use this in light mode
            .background(Color(.systemBackground))
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.text = "Ratings & Reviews"
        addSubview(titleLabel)
        
        // Rating Container
        ratingContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(ratingContainer)
        
        // Rating Label
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)  // Increased font size
        ratingLabel.textColor = .label
        ratingLabel.text = "0.0"
        ratingLabel.adjustsFontSizeToFitWidth = true  // Add this to ensure text fits
        ratingLabel.minimumScaleFactor = 0.5  // Allow scaling down if needed
        ratingLabel.textAlignment = .left  // Ensure left alignment
        ratingContainer.addSubview(ratingLabel)
        
        // Star Stack View
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 2
        ratingContainer.addSubview(starStackView)
        
        // Add 5 stars to stack view
        for _ in 0..<5 {
            let starImageView = UIImageView(image: UIImage(systemName: "star"))
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
            starStackView.addArrangedSubview(starImageView)
        }
        
        // Reviews Count Label
        reviewsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewsCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        reviewsCountLabel.textColor = .secondaryLabel
        reviewsCountLabel.text = "0 reviews"
        addSubview(reviewsCountLabel)
        
        // See All Reviews Button
        seeAllReviewsButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllReviewsButton.setTitle("See All", for: .normal)
        seeAllReviewsButton.setTitleColor(UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), for: .normal)
        seeAllReviewsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        seeAllReviewsButton.addTarget(self, action: #selector(seeAllReviewsTapped), for: .touchUpInside)
        seeAllReviewsButton.isHidden = true // Hidden by default
        addSubview(seeAllReviewsButton)
        
        // Write Review Button
        writeReviewButton.translatesAutoresizingMaskIntoConstraints = false
        writeReviewButton.setTitle("Write a Review", for: .normal)
        writeReviewButton.backgroundColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        writeReviewButton.setTitleColor(.white, for: .normal)
        writeReviewButton.layer.cornerRadius = 8
        writeReviewButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        writeReviewButton.addTarget(self, action: #selector(writeReviewTapped), for: .touchUpInside)
        addSubview(writeReviewButton)
        
        // Separator View
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .separator
        addSubview(separatorView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Rating Container
            ratingContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            ratingContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ratingContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),  // Ensure minimum width
            
            // Rating Label
            ratingLabel.topAnchor.constraint(equalTo: ratingContainer.topAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingContainer.trailingAnchor),
            ratingLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),  // Set minimum width for the rating label
            
            // Star Stack View
            starStackView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            starStackView.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor),
            starStackView.trailingAnchor.constraint(equalTo: ratingContainer.trailingAnchor),
            starStackView.bottomAnchor.constraint(equalTo: ratingContainer.bottomAnchor),
            starStackView.heightAnchor.constraint(equalToConstant: 20),
            
            // Reviews Count Label
            reviewsCountLabel.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 4),
            reviewsCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // See All Reviews Button
            seeAllReviewsButton.centerYAnchor.constraint(equalTo: reviewsCountLabel.centerYAnchor),
            seeAllReviewsButton.leadingAnchor.constraint(equalTo: reviewsCountLabel.trailingAnchor, constant: 8),
            
            // Write Review Button
            writeReviewButton.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor),
            writeReviewButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            writeReviewButton.widthAnchor.constraint(equalToConstant: 130),
            writeReviewButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Separator View
            separatorView.topAnchor.constraint(equalTo: reviewsCountLabel.bottomAnchor, constant: 12),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    @objc private func writeReviewTapped() {
        onWriteReviewTapped?()
    }
    
    @objc private func seeAllReviewsTapped() {
        onSeeAllReviewsTapped?()
    }
    
    // Update the rating display
    func configure(with rating: Double, canUserWriteReview: Bool, reviewsCount: Int = 0) {
        // Always format with one decimal place for consistency
        ratingLabel.text = String(format: "%.1f", rating)
        
        // Set a larger content hugging priority to ensure the label gets enough space
        ratingLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Update stars based on rating
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        for (index, view) in starStackView.arrangedSubviews.enumerated() {
            if let starView = view as? UIImageView {
                if index < fullStars {
                    starView.image = UIImage(systemName: "star.fill")
                } else if index == fullStars && hasHalfStar {
                    starView.image = UIImage(systemName: "star.leadinghalf.filled")
                } else {
                    starView.image = UIImage(systemName: "star")
                }
            }
        }
        
        // Update reviews count label
        reviewsCountLabel.text = "\(reviewsCount) \(reviewsCount == 1 ? "review" : "reviews")"
        
        // Show the see all button if there are any reviews
        seeAllReviewsButton.isHidden = reviewsCount < 1
        
        // Show/hide write review button based on authorization
        writeReviewButton.isHidden = !canUserWriteReview
    }
} 
