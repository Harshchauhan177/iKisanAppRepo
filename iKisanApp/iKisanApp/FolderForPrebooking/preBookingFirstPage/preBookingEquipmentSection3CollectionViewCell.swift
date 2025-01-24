//
//  preBookingEquipmentSection3CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import UIKit

class preBookingEquipmentSection3CollectionViewCell: UICollectionViewCell {

    
    
    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentDateLabel: UILabel!
    @IBOutlet weak var equipmentStatusLabel: UILabel!
    
    
    
    func updatePreBookingSection3Data(with indexPath :IndexPath){
        equipmentNameLabel.text = PreBookingScreenData.preBookingSection3Data[indexPath.row].equipmentName
        
        equipmentImageView.image = UIImage(named: PreBookingScreenData.preBookingSection3Data[indexPath.row].equipmentImage)
    
        equipmentDateLabel.text = PreBookingScreenData.preBookingSection3Data[indexPath.row].equipmentDate
        
        equipmentStatusLabel.text = PreBookingScreenData.preBookingSection3Data[indexPath.row].equipmentStatus
        if equipmentStatusLabel.text == "Pending"{
            equipmentStatusLabel.textColor = .systemBlue
        }else {
            equipmentStatusLabel.textColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        }
        
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
