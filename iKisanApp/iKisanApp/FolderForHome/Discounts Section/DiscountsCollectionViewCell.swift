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
    
    func updateDiscountsData(with equipment: Equipment) {
        // Safely unwrap all IBOutlet properties with optional binding
        if let imgView = equipmentImage {
            // Check if the equipmentImage is a URL or a local asset name
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imgView.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                imgView.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
        }
        
        if let nameLabel = equipmentNameLabel {
            nameLabel.text = equipment.name
        }
        
        if let priceLabel = discountedPrice {
            priceLabel.text = "₹\(equipment.pricePerHour)"
        }
        
        if let ratingLabel = rating {
            ratingLabel.text = "⭐️\(equipment.rating)"
        }
        
//        let price = "\(equipment.realPricePerHour)"
//        let attributes: [NSAttributedString.Key: Any] = [
//            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
//            .strikethroughColor: UIColor.white
//        ]
//        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
//        realPrice.attributedText = attributedPrice
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
