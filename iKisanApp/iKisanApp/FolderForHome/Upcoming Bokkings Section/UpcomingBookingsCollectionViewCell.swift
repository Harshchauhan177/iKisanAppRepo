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
        
        coEquipedOrNotLabel.text = booking.bookingType == .coEquip ? "Co-Equipped" : "Individual"
        hostedByLabel.text = "Time Slot: \(booking.timeSlot.rawValue)"
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
        
    }
    
}
