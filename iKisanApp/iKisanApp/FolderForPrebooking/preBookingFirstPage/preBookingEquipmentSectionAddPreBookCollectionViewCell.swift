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
        // Initialization code
    }
    
    
    @IBAction func preBookingButton1(_ sender: Any) {
        
        delegate?.didTapViewButton(on: self)
         
    }
    
    func configure(with equipment: Equipment) {
        equipmentImageView.image = UIImage(named: equipment.equipmentImage)
        equipmentNameLabel.text = equipment.name
        equipmentPriceLabel.text = "₹\(equipment.pricePerHour)"
        equipmentStatusLabel.text = "Available"
        equipmentOwnerNameLabel.text = "Hosted By \(equipment.providerName ?? "Unknown")"
        
        // Add any additional UI configuration
        equipmentImageView.layer.cornerRadius = 8
        equipmentImageView.clipsToBounds = true
    }
    
    
    
    

}
