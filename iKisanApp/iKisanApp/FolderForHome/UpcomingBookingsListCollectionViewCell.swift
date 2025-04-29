//
//  UpcomingBookingsListCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

protocol UpcomingBookingsListCellDelegate: AnyObject {
    func didTapViewButton(on cell: UpcomingBookingsListCollectionViewCell)
}

class UpcomingBookingsListCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hostedByLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var equipmentNameLabel: UILabel!

    @IBOutlet weak var bookingType: UILabel!
    weak var delegate: UpcomingBookingsListCellDelegate?
    
    func updateCellData(with booking: Booking, equipment: Equipment) {
        equipmentImageView.image = UIImage(named: equipment.equipmentImage)
        equipmentNameLabel.text = equipment.name
        equipmentImageView.layer.cornerRadius = 7
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        let dateString = dateFormatter.string(from: booking.bookingDate)
        dateLabel.text = "\(dateString) \(booking.timeSlot.rawValue)"
        
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
        
        // Display both booking status and booking type
        statusLabel.text = "\(booking.status.rawValue)"
        bookingType.text =  "\(booking.bookingType.rawValue)"
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        updateCellUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateCellUI()
        
    }
    
    func updateCellUI () {
        self.layer.cornerRadius = 10
        self.backgroundColor = .white
        
    
        //self.backgroundColor = .green.withAlphaComponent(0.4)
    }
    
    
    
    
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
   
 }
    
}
