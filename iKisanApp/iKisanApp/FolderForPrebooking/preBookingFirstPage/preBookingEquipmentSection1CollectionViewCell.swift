//
//  preBookingEquipmentSection1CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import UIKit

class preBookingEquipmentSection1CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentDescriptionLabel: UILabel!
    
    
    
    func updatePreBookingSection1Data(with indexPath :IndexPath){
        equipmentNameLabel.text = PreBookingScreenData.preBookingSection1Data[indexPath.row].equipmentName
        
        equipmentImageView.image = UIImage(named: PreBookingScreenData.preBookingSection1Data[indexPath.row].equipmentImage)
    
        equipmentDescriptionLabel.text = PreBookingScreenData.preBookingSection1Data[indexPath.row].equipmentDescription
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
