//
//  preBookingEquipmentSection3CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//


import UIKit

protocol PreBookingSection3CellDelegate: AnyObject {
    func didTapModifyButton(for booking: Booking, equipment: Equipment)
    func didTapCancelButton(for booking: Booking, equipment: Equipment)
}

class yourPrebookingsSection: UICollectionViewCell {
    weak var delegate: PreBookingSection3CellDelegate?
    private var currentBooking: Booking?
    private var currentEquipment: Equipment?
    
    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentDateLabel: UILabel!
    @IBOutlet weak var equipmentStatusLabel: UILabel!
    func configure(with booking: Booking, equipment: Equipment) {
        self.currentBooking = booking
        self.currentEquipment = equipment
        
        // Safely unwrap IBOutlets to prevent crashes
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
        
        if let nameLabel = equipmentNameLabel {
            nameLabel.text = equipment.name
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        let dateString = dateFormatter.string(from: booking.bookingDate)
        
        if let dateLabel = equipmentDateLabel {
            dateLabel.text = "\(dateString) \(booking.timeSlot.rawValue)"
        }
        
        if let statusLabel = equipmentStatusLabel {
            statusLabel.text = booking.status.rawValue
            statusLabel.textColor = booking.status.color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureForDynamicType()
    }
    
    private func configureForDynamicType() {
        // Configure label fonts for dynamic type
        let labelConfigs: [(UILabel?, CGFloat, UIFont.Weight, UIFont.TextStyle)] = [
            (equipmentNameLabel, 16, .semibold, .headline),
            (equipmentDateLabel, 14, .regular, .subheadline),
            (equipmentStatusLabel, 14, .medium, .subheadline)
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
    
    deinit {
        // Remove notification observer when cell is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func modifyButtonTapped(_ sender: Any) {
        
        guard let booking = currentBooking,
              let equipment = currentEquipment else { return }
        delegate?.didTapModifyButton(for: booking, equipment: equipment)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        guard let booking = currentBooking,
              let equipment = currentEquipment else { return }
        delegate?.didTapCancelButton(for: booking, equipment: equipment)
    }
    
   

}

extension BookingStatus {
    var color: UIColor {
        switch self {
        case .pending:
            return .systemBlue
        case .confirmed:
            return .systemGreen
     
        case .completed:
            return .systemGray
        }
    }
}
