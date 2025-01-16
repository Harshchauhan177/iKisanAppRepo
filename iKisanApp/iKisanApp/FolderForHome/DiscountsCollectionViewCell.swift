//
//  DiscountsCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit

class DiscountsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var equipmentImage: UIImageView!
    
    @IBOutlet var equipmentNameLabel: UILabel!
    
    @IBOutlet var discountedPrice: UILabel!
    @IBOutlet var realPrice: UILabel!
    @IBOutlet var rating: UILabel!
    
    
    func updateDiscountsData(with indexPath: IndexPath) {
        equipmentImage.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentImage)
        equipmentNameLabel.text = EquipmentData.equipment[indexPath.row].name
        discountedPrice.text = "\(EquipmentData.equipment[indexPath.row].pricePerHour)"
        rating.text = "⭐️\(EquipmentData.equipment[indexPath.row].rating)"
   
        
        
//        countryFlagImageView.image = UIImage(named: ScreenData.section1Data[indexPath.row].countryFlagImageName)
//        countryFlagImageView.layer.cornerRadius = 7
    }
    
    
    
    
}
