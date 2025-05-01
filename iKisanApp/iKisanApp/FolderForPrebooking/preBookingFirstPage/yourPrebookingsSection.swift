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
        equipmentImageView.image = UIImage(named: equipment.equipmentImage)
        equipmentNameLabel.text = equipment.name
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM"
        let dateString = dateFormatter.string(from: booking.bookingDate)
        equipmentDateLabel.text = "\(dateString) \(booking.timeSlot.rawValue)"
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        equipmentDateLabel.text = dateFormatter.string(from: booking.bookingDate)
        
        equipmentStatusLabel.text = booking.status.rawValue
        equipmentStatusLabel.textColor = booking.status.color
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        
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
