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
        
        // Fix layout issues and ensure button is properly set up for interaction
        fixButtonAccessibility()
        fixConstraintConflicts()
    }
    
    private func fixButtonAccessibility() {
        // If there's a fader view, ensure it doesn't block the button
        if let faderView = self.faderView {
            // Make sure the fader view doesn't block user interaction
            faderView.isUserInteractionEnabled = false
            
            // Find the Book Now button in the hierarchy by looking for views with action handlers
            for subview in self.contentView.subviews where subview is UIButton {
                if let button = subview as? UIButton {
                    // Bring the button to the front of the view hierarchy
                    contentView.bringSubviewToFront(button)
                    // Ensure it's enabled and user-interactive
                    button.isEnabled = true
                    button.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    // Fix constraint conflicts that are causing layout warnings
    private func fixConstraintConflicts() {
        // Find all buttons in the cell's view hierarchy
        for case let button as UIButton in contentView.subviews.flatMap({ $0.subviews }) {
            // Remove any fixed width constraints on the button
            for constraint in button.constraints where constraint.firstAttribute == .width {
                button.removeConstraint(constraint)
            }
            
            // Remove fixed button width setting that's causing layout conflicts
            // Allow button to size dynamically based on container width
            if button.constraints.isEmpty {
                button.translatesAutoresizingMaskIntoConstraints = true
                button.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
            }
        }
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
        
        // Apply the button accessibility fix again after data update
        // This ensures any dynamic UI changes don't affect button accessibility
        fixButtonAccessibility()
    }

   
    @IBAction func bookNowButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
