//
//  preBookingEquipmentSectionAddPreBookCollectionViewCell.swift
//  iKisanApp
//
//  Created by harsh chauhan on 23/01/25.
//

import UIKit

protocol preBookingEquipmentSectionAddPreBookCollectionViewCellDelegate: AnyObject {
    func didTapViewButton(on cell: preBookingEquipmentSectionAddPreBookCollectionViewCell)
}
class preBookingEquipmentSectionAddPreBookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentPriceLabel: UILabel!
    @IBOutlet weak var equipmentStatusLabel: UILabel!
    @IBOutlet weak var equipmentOwnerNameLabel: UILabel!
    
    weak var delegate: preBookingEquipmentSectionAddPreBookCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureForDynamicType()
    }
    
    private func configureForDynamicType() {
        // Configure label fonts for dynamic type
        let labelConfigs: [(UILabel?, CGFloat, UIFont.Weight, UIFont.TextStyle)] = [
            (equipmentNameLabel, 16, .semibold, .headline),
            (equipmentPriceLabel, 14, .bold, .subheadline),
            (equipmentStatusLabel, 12, .medium, .footnote),
            (equipmentOwnerNameLabel, 12, .regular, .caption1)
        ]
        
        // Apply settings to each label
        for (label, size, weight, style) in labelConfigs {
            if let lbl = label {
                // Enable dynamic type adjustment
                lbl.adjustsFontForContentSizeCategory = true
                
                // Create a base font with appropriate size and weight
                let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
                
                // Apply font scaling with metrics
                lbl.font = UIFontMetrics(forTextStyle: style).scaledFont(for: baseFont, maximumPointSize: size * 1.5)
            }
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
        // Refresh fonts when text size settings change
        configureForDynamicType()
        setNeedsLayout()
    }
    
    @IBAction func preBookingButton1(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
    }
    
    func configure(with equipment: Equipment) {
        // Safely unwrap IBOutlets to prevent crashes
        if let imageView = equipmentImageView {
            imageView.image = UIImage(named: equipment.equipmentImage)
            imageView.layer.cornerRadius = 8
            imageView.clipsToBounds = true
        }
        
        if let nameLabel = equipmentNameLabel {
            nameLabel.text = equipment.name
        }
        
        if let priceLabel = equipmentPriceLabel {
            priceLabel.text = "₹\(equipment.pricePerHour)"
        }
        
        if let statusLabel = equipmentStatusLabel {
            statusLabel.text = "Available"
        }
        
        if let ownerLabel = equipmentOwnerNameLabel {
            ownerLabel.text = "Hosted By \(equipment.providerName ?? "Unknown")"
        }
    }
    
    deinit {
        // Remove notification observer when cell is deallocated
        NotificationCenter.default.removeObserver(self)
    }
}
