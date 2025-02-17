//
//  InfoAboutEquipmentSection2CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 21/01/25.
//

import UIKit

class InfoAboutEquipmentSection2CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentLikedByLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with equipment: EquipmentAgri) {
        print("Configuring section 2 cell with equipment: \(equipment.name)")
        
        equipmentNameLabel?.text = equipment.name
        
        if let image = UIImage(named: equipment.imageName) {
            equipmentImageView?.image = image
        } else {
            print("Warning: Image not found for \(equipment.imageName)")
            equipmentImageView?.image = UIImage(named: "placeholder_image")
        }
        
        // Configure other labels as needed
      //  equipmentPurposeLabel?.text = equipment.purpose ?? "N/A"
        equipmentLikedByLabel?.text = "\(equipment.likedBy)"
    }
}
