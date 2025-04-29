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
        // Initialization code
    }
    
    
    func updateUpcomingBookingsData(with booking: Booking, equipment: Equipment) {
        imageView.image = UIImage(named: equipment.equipmentImage)
        imageView.layer.cornerRadius = 7
        equipmentNameLabel.text = equipment.name
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        let dateString = dateFormatter.string(from: booking.bookingDate)
        bookingDateLabel.text = "\(dateString) \(booking.timeSlot.rawValue)"
        
        bookingStatusLabel.text = booking.status.rawValue
        
        // Set color based on booking status
        bookingStatusLabel.textColor = booking.status == .confirmed ?
            UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1) :
            UIColor.systemGray
        
        // Display the actual booking type from the enum
        coEquipedOrNotLabel.text = booking.bookingType.rawValue
        
        // Use the equipment's providerName if available
        if let providerName = equipment.providerName, !providerName.isEmpty {
            hostedByLabel.text = providerName
        } else {
            // If providerName is not available in the equipment object,
            // fetch it from the equipment's providerID
            hostedByLabel.text = "Loading..."
            
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
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
        
    }
    
}
