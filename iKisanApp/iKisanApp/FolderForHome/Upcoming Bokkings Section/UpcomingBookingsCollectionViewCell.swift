//
//  UpcomingBookingsCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

protocol UpcomingBookingsCollectionViewCellDelegate: AnyObject {
    func didTapViewButton(on cell: UpcomingBookingsCollectionViewCell)
}

class UpcomingBookingsCollectionViewCell: UICollectionViewCell {

    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var bookingDateLabel: UILabel!
    @IBOutlet var hostedByLabel: UILabel!
    @IBOutlet var bookingStatusLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var coEquipedOrNotLabel: UILabel!
    
    weak var delegate: UpcomingBookingsCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Enable dynamic type support
        configureForDynamicType()
    }
    
    private func configureForDynamicType() {
        // Enable dynamic type adjustment for all text labels
        equipmentNameLabel.adjustsFontForContentSizeCategory = true
        bookingDateLabel.adjustsFontForContentSizeCategory = true
        hostedByLabel.adjustsFontForContentSizeCategory = true
        bookingStatusLabel.adjustsFontForContentSizeCategory = true
        coEquipedOrNotLabel.adjustsFontForContentSizeCategory = true
        
        // Set appropriate text styles with controlled sizing to match original design
        let equipmentFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let dateFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let hostedByFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let statusFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let bookingTypeFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        // Apply font metrics with maximum sizes to prevent layout issues
        equipmentNameLabel.font = UIFontMetrics.default.scaledFont(for: equipmentFont, maximumPointSize: 20)
        bookingDateLabel.font = UIFontMetrics.default.scaledFont(for: dateFont, maximumPointSize: 16)
        hostedByLabel.font = UIFontMetrics.default.scaledFont(for: hostedByFont, maximumPointSize: 14)
        bookingStatusLabel.font = UIFontMetrics.default.scaledFont(for: statusFont, maximumPointSize: 14)
        coEquipedOrNotLabel.font = UIFontMetrics.default.scaledFont(for: bookingTypeFont, maximumPointSize: 14)
        
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
    
    func updateUpcomingBookingsData(with booking: Booking, equipment: Equipment) {
        // Safely unwrap IBOutlets to prevent crashes
        if let imgView = imageView {
            // Check if the equipmentImage is a URL or a local asset name
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imgView.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                imgView.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
            imgView.layer.cornerRadius = 7
        }
        
        if let nameLabel = equipmentNameLabel {
            nameLabel.text = equipment.name
        }
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        let dateString = dateFormatter.string(from: booking.bookingDate)
        
        if let dateLabel = bookingDateLabel {
            dateLabel.text = "\(dateString) \(booking.timeSlot.rawValue)"
        }
        
        if let statusLabel = bookingStatusLabel {
            statusLabel.text = booking.status.rawValue
            
            // Set color based on booking status
            statusLabel.textColor = booking.status == .confirmed ?
                UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1) :
                UIColor.systemGray
        }
        
        // Display the actual booking type from the enum
        if let bookingTypeLabel = coEquipedOrNotLabel {
            bookingTypeLabel.text = booking.bookingType.rawValue
        }
        
        // Use the equipment's providerName if available
        if let hostLabel = hostedByLabel {
            if let providerName = equipment.providerName, !providerName.isEmpty {
                hostLabel.text = providerName
            } else {
                // If providerName is not available in the equipment object,
                // fetch it from the equipment's providerID
                hostLabel.text = "Loading..."
                
                Task {
                    do {
                        // Try to get the provider name from Supabase using the equipment's providerID
                        let result = try await SupabaseManager.shared.client
                            .from("users")
                            .select("name")
                            .eq("userID", value: equipment.providerID.uuidString)
                            .single()
                            .execute()
                        
                        // Process the response
                        do {
                            if let dict = try JSONSerialization.jsonObject(with: result.data) as? [String: Any],
                               let providerName = dict["name"] as? String {
                                // Update UI on main thread
                                await MainActor.run {
                                    self.hostedByLabel.text = providerName
                                }
                            } else {
                                await MainActor.run {
                                    self.hostedByLabel.text = "Provider"
                                }
                            }
                        } catch {
                            print("Error parsing provider data: \(error)")
                            await MainActor.run {
                                self.hostedByLabel.text = "Provider"
                            }
                        }
                    } catch {
                        print("Error fetching provider name: \(error)")
                        // Fallback on error
                        await MainActor.run {
                            self.hostedByLabel.text = "Provider"
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
