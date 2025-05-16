//
//  ExploreMoreCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit

protocol ExploreMoreCollectionViewCellDelegate: AnyObject {
    func didTapViewButton(on cell: ExploreMoreCollectionViewCell)
}

class ExploreMoreCollectionViewCell: UICollectionViewCell {
    
    var faderView: UIView? = nil
    
    @IBOutlet var exploreEquipmentImageView: UIImageView!
    
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var discountedPriceLabel: UILabel!
   // @IBOutlet var realPriceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
   // @IBOutlet var providerNameLabel: UILabel!
    
    weak var delegate: ExploreMoreCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureForDynamicType()
    }
    
    private func configureForDynamicType() {
        // Enable dynamic type adjustment for all text labels
        equipmentNameLabel.adjustsFontForContentSizeCategory = true
        discountedPriceLabel.adjustsFontForContentSizeCategory = true
       // realPriceLabel.adjustsFontForContentSizeCategory = true
        ratingLabel.adjustsFontForContentSizeCategory = true
     //   providerNameLabel.adjustsFontForContentSizeCategory = true
        
        // Set appropriate text styles but maintain original sizes to prevent layout issues
        let nameFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let discountedPriceFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let realPriceFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let ratingFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let providerFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        // Apply text styles with maximum font scale to prevent layout issues
        equipmentNameLabel.font = UIFontMetrics.default.scaledFont(for: nameFont, maximumPointSize: 18)
        discountedPriceLabel.font = UIFontMetrics.default.scaledFont(for: discountedPriceFont, maximumPointSize: 16)
//        realPriceLabel.font = UIFontMetrics.default.scaledFont(for: realPriceFont, maximumPointSize: 14)
        ratingLabel.font = UIFontMetrics.default.scaledFont(for: ratingFont, maximumPointSize: 14)
//        providerNameLabel.font = UIFontMetrics.default.scaledFont(for: providerFont, maximumPointSize: 14)
        
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
    
    func updateExploreMoreData(with equipment: Equipment) {
        // Safely unwrap IBOutlets to prevent crashes
        if let imageView = exploreEquipmentImageView {
            // Check if the equipmentImage is a URL or a local asset name
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                imageView.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
        }
        
        if let nameLabel = equipmentNameLabel {
            nameLabel.text = equipment.name
        }
        
        if let priceLabel = discountedPriceLabel {
            priceLabel.text = "₹\(equipment.pricePerHour)"
        }
        
        // Create attributed string for real price with strikethrough
        let price = "\(equipment.realPricePerHour)"
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.white
        ]
        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
        
//        if let realPrice = realPriceLabel {
//            realPrice.attributedText = attributedPrice
//        }
        
        if let rating = ratingLabel {
            rating.text = "⭐️\(equipment.rating)"
        }
    }

   
    @IBAction func bookNowButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
