//
//  DiscountsCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit

class DiscountsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var equipmentImage: UIImageView!
    
    @IBOutlet var equipmentNameLabel: UILabel!
    
    @IBOutlet var discountedPrice: UILabel!
    @IBOutlet var realPrice: UILabel!
    @IBOutlet var rating: UILabel!
    
    @IBOutlet var faderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureForDynamicType()
    }
    
    private func configureForDynamicType() {
        // Enable dynamic type adjustment with scaling constraints
        equipmentNameLabel.adjustsFontForContentSizeCategory = true
        discountedPrice.adjustsFontForContentSizeCategory = true
        rating.adjustsFontForContentSizeCategory = true
        
        // Set appropriate text styles but maintain original sizes
        let nameFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let priceFont = UIFont.systemFont(ofSize: 10, weight: .semibold)
        let ratingFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        // Apply text styles with maximum font scale to prevent layout issues
        equipmentNameLabel.font = UIFontMetrics.default.scaledFont(for: nameFont, maximumPointSize: 14)
        discountedPrice.font = UIFontMetrics.default.scaledFont(for: priceFont, maximumPointSize: 12)
        rating.font = UIFontMetrics.default.scaledFont(for: ratingFont, maximumPointSize: 12)
        
        // Register for trait collection changes to refresh layout when text size changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func contentSizeCategoryDidChange() {
        // Refresh font sizes when user changes text size in settings
        configureForDynamicType()
        setNeedsLayout()
    }
    
    func updateDiscountsData(with equipment: Equipment, reviews: [ReviewData]) {
        // Safely unwrap all IBOutlet properties with optional binding
        
        // Handle equipment image
        if let imgView = equipmentImage {
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imgView.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                imgView.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
        }
        
        // Handle equipment name
        if let nameLabel = equipmentNameLabel {
            nameLabel.text = equipment.name
        }
        
        // Handle price display
        if let priceLabel = discountedPrice {
            priceLabel.text = "₹\(equipment.pricePerHour)"
        }
        
        // Filter reviews for this specific equipment and calculate average rating
        let equipmentReviews = reviews.filter { review in
            if let reviewEquipmentID = review.equipmentID {
                return reviewEquipmentID.lowercased() == equipment.equipmentID.uuidString.lowercased()
            }
            return review.equipmentName?.lowercased() == equipment.name.lowercased()
        }
        
        let averageRating = equipmentReviews.isEmpty ? 0.0 : 
            equipmentReviews.reduce(0.0) { $0 + $1.rating } / Double(equipmentReviews.count)
            
        if let ratingLabel = rating {
            ratingLabel.text = String(format: "⭐️%.1f", averageRating)
        }
        
        // Handle fader view (if needed)
        if let fader = faderView {
            fader.backgroundColor = UIColor(white: 0, alpha: 0.3)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Extension for making bold fonts
extension UIFont {
    func bold() -> UIFont {
        return with(.traitBold)
    }
    
    private func with(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0) // Size 0 maintains the size from the descriptor
    }
}
