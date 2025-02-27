//
//  preBookingEquipmentSection1CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import UIKit

class preBookingRecommendedForYouCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentDescriptionLabel: UILabel!
    
    
    
    func configure(with equipment: Equipment) {
        equipmentNameLabel.text = equipment.name
        equipmentImageView.image = UIImage(named: equipment.equipmentImage)
        equipmentDescriptionLabel.text = equipment.description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
