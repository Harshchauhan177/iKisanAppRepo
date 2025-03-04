//
//  myCollectionViewCell.swift
//  iKisanApp
//
//  Created by harsh chauhan on 19/01/25.
//

import UIKit

class myCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var myEquipmentImage: UIImageView!
    @IBOutlet weak var myEquipmentsName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        myEquipmentImage.layer.cornerRadius = myEquipmentImage.frame.size.width / 2
        myEquipmentImage.clipsToBounds = true
        myEquipmentImage.layer.borderWidth = 1.5
        myEquipmentImage.layer.borderColor = UIColor.gray.cgColor
    }
    
    func configure(with equipment: EquipmentAgri) {
        myEquipmentsName.text = equipment.name
        if let image = UIImage(named: equipment.imageName) {
            myEquipmentImage.image = image
        } else {
            print("Warning: Image not found for \(equipment.imageName)")
            myEquipmentImage.image = UIImage(named: "placeholder_image") // Use a placeholder
        }
    }
}
