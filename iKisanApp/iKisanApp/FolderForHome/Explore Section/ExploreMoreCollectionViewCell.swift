//
//  ExploreMoreCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit

protocol ExploreMoreCollectionViewCellDelegate: AnyObject {
    func didTapViewButton(on cell: ExploreMoreCollectionViewCell)
}

class ExploreMoreCollectionViewCell: UICollectionViewCell {
    
    var faderView: UIView? = nil
    
    @IBOutlet var exploreEquipmentImageView: UIImageView!
    
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var discountedPriceLabel: UILabel!
    @IBOutlet var realPriceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var providerNameLabel: UILabel!
    
    weak var delegate: ExploreMoreCollectionViewCellDelegate?
    
    func updateExploreMoreData(with equipment: Equipment) {
        exploreEquipmentImageView.image = UIImage(named: equipment.equipmentImage)
        equipmentNameLabel.text = equipment.name
        discountedPriceLabel.text = "₹\(equipment.pricePerHour)"
        
        let price = "\(equipment.realPricePerHour)"
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.white
        ]
        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
        realPriceLabel.attributedText = attributedPrice
        ratingLabel.text = "⭐️\(equipment.rating)"
    }

   
    @IBAction func bookNowButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
    }
    
    
}
