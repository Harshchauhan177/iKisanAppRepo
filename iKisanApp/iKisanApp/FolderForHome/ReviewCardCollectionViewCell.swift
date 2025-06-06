//
//  ReviewCardCollectionViewCell.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 17/01/25.
//

import UIKit

class ReviewCardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet var feedbackHeadingLabel: UILabel!
    @IBOutlet var star1Image: UIImageView!
    @IBOutlet var star2Image: UIImageView!
    @IBOutlet var star3Image: UIImageView!
    @IBOutlet var star4Image: UIImageView!
    @IBOutlet var star5Image: UIImageView!
    @IBOutlet var feedbackTextLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel?
    @IBOutlet var reviewDateLabel: UILabel?
    @IBOutlet var starStackView: UIStackView?
    
    // MARK: - Properties
    private var starImageViews: [UIImageView] {
        return [star1Image, star2Image, star3Image, star4Image, star5Image].compactMap { $0 }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset labels
        feedbackHeadingLabel.text = nil
        feedbackTextLabel.text = nil
        userNameLabel?.text = nil
        reviewDateLabel?.text = nil
        
        // Reset stars
        for starImageView in starImageViews {
            starImageView.image = UIImage(named: "star_empty")
        }
    }
    
    // MARK: - Setup
    private func setupCell() {
        // Apply card styling
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        // Configure star stack view if available
        starStackView?.spacing = 4
        
        // Configure labels
        feedbackHeadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        feedbackHeadingLabel.textColor = .label
        feedbackHeadingLabel.numberOfLines = 2
        
        feedbackTextLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        feedbackTextLabel.textColor = .secondaryLabel
        feedbackTextLabel.numberOfLines = 0 // Allow unlimited lines
        // Add some bottom padding to ensure text is not cut off
        feedbackTextLabel.contentMode = .top
        feedbackTextLabel.lineBreakMode = .byWordWrapping
        
        userNameLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        userNameLabel?.textColor = .secondaryLabel
        
        reviewDateLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        reviewDateLabel?.textColor = .tertiaryLabel
        
        // Add card shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 2
        layer.masksToBounds = false
        
        // Add a separator line at the bottom
        let separatorView = UIView()
        separatorView.backgroundColor = .separator
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        // Set content hugging and compression resistance to ensure proper layout
        feedbackHeadingLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        feedbackHeadingLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        feedbackTextLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        feedbackTextLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    // MARK: - Update Data
    func updateReviewCardData(reviewData: ReviewData) {
        feedbackHeadingLabel.text = reviewData.reviewHeading
        feedbackTextLabel.text = reviewData.reviewDescription
        
        // Set reviewer name if we have one, otherwise use placeholder
        userNameLabel?.text = "Farmer User"
        
        // Set review date to current date as placeholder
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        reviewDateLabel?.text = dateFormatter.string(from: Date())
        
        // Update star rating
        updateStarRating(with: reviewData.rating)
    }
    
    private func updateStarRating(with rating: Double) {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        for (index, starImageView) in starImageViews.enumerated() {
            if index < fullStars {
                starImageView.image = UIImage(systemName: "star.fill")
            } else if index == fullStars && hasHalfStar {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
            } else {
                starImageView.image = UIImage(systemName: "star")
            }
            
            // Apply green tint color to stars
            starImageView.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        }
    }
}
