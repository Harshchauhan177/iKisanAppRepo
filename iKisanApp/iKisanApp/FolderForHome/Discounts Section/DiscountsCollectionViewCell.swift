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
    
    @IBOutlet var faderView: UIView!
    
    
    
    func updateDiscountsData(with indexPath: IndexPath) {
        equipmentImage.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentImage)
        equipmentNameLabel.text = EquipmentData.equipment[indexPath.row].name
        discountedPrice.text = "₹\(EquipmentData.equipment[indexPath.row].pricePerHour)"
        
        rating.text = "⭐️\(EquipmentData.equipment[indexPath.row].rating)"
        
        let price = "\(EquipmentData.equipment[indexPath.row].realPricePerHour)"
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.white
        ]
        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
        //realPrice.text = "\(attributedPrice)"
        
        realPrice.attributedText = attributedPrice
        //"\(EquipmentData.equipment[indexPath.row].realPricePerHour)"
   
        //faderView.backgroundColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 0.3)
        

    }
    
    
    
    
}
