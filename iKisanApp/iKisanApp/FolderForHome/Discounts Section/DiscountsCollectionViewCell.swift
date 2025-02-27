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
    
    
    func updateDiscountsData(with equipment: Equipment) {
        equipmentImage.image = UIImage(named: equipment.equipmentImage)
        equipmentNameLabel.text = equipment.name
        discountedPrice.text = "₹\(equipment.pricePerHour)"
        rating.text = "⭐️\(equipment.rating)"
        
//        let price = "\(equipment.realPricePerHour)"
//        let attributes: [NSAttributedString.Key: Any] = [
//            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
//            .strikethroughColor: UIColor.white
//        ]
//        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
//        realPrice.attributedText = attributedPrice
    }
    
    
}
