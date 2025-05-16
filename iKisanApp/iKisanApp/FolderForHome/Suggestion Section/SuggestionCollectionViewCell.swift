//
//  SuggestionCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit

class SuggestionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var suggestionImageView: UIImageView!
    @IBOutlet var suggestionNameLabel: UILabel!
    @IBOutlet var suggestionDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureForDynamicType()
    }
    
    private func configureForDynamicType() {
        // Enable dynamic type adjustment
        suggestionNameLabel.adjustsFontForContentSizeCategory = true
        suggestionDescriptionLabel.adjustsFontForContentSizeCategory = true
        
        // Set appropriate text styles with controlled sizing
        let nameFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let descriptionFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        // Apply text styles with maximum font scale to prevent layout issues
        suggestionNameLabel.font = UIFontMetrics.default.scaledFont(for: nameFont, maximumPointSize: 18)
        suggestionDescriptionLabel.font = UIFontMetrics.default.scaledFont(for: descriptionFont, maximumPointSize: 16)
        
        // Register for content size category changes
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
    
    func updateSuggestionData(with equipment: Equipment) {
        // Safely unwrap IBOutlets to prevent crashes
        if let imageView = suggestionImageView {
            // Check if the equipmentImage is a URL or a local asset name
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                imageView.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
        }
        
        if let nameLabel = suggestionNameLabel {
            nameLabel.text = equipment.name
        }
        
        if let descriptionLabel = suggestionDescriptionLabel {
            descriptionLabel.text = equipment.description ?? "Available in your area."
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
