//
//  preBookingEquipmentSection1CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import UIKit

class preBookingRecommendedForYouCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureForDynamicType()
    }
    
    private func configureForDynamicType() {
        // Enable dynamic type adjustment for labels
        if let nameLabel = equipmentNameLabel {
            nameLabel.adjustsFontForContentSizeCategory = true
            let nameFont = UIFont.systemFont(ofSize: 16, weight: .bold)
            nameLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: nameFont)
        }
        
        if let descLabel = equipmentDescriptionLabel {
            descLabel.adjustsFontForContentSizeCategory = true
            let descFont = UIFont.systemFont(ofSize: 14, weight: .regular)
            descLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: descFont)
        }
        
        // Register for content size category changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func contentSizeCategoryDidChange() {
        // Refresh font sizes when user changes text size settings
        configureForDynamicType()
        setNeedsLayout()
    }
    
    func configure(with equipment: Equipment) {
        // Safely unwrap IBOutlets to prevent crashes
        if let nameLabel = equipmentNameLabel {
            nameLabel.text = equipment.name
        }
        
        if let imageView = equipmentImageView {
            // Check if the equipmentImage is a URL or a local asset name
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                imageView.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
        }
        
        if let descLabel = equipmentDescriptionLabel {
            descLabel.text = equipment.description
        }
    }
    
    deinit {
        // Remove notification observer to prevent memory leaks
        NotificationCenter.default.removeObserver(self)
    }
}
