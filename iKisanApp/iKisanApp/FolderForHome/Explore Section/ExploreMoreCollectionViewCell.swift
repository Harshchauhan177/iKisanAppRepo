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
    func updateExploreMoreData(with indexPath: IndexPath) {
        
        exploreEquipmentImageView.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentImage)
        equipmentNameLabel.text = EquipmentData.equipment[indexPath.row].name
        discountedPriceLabel.text = "₹\(EquipmentData.equipment[indexPath.row].pricePerHour)"
        
        let price = "\(EquipmentData.equipment[indexPath.row].realPricePerHour)"
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.white
        ]
        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
        realPriceLabel.attributedText = attributedPrice
        //realPriceLabel.text = "₹\(EquipmentData.equipment[indexPath.row].pricePerHour)"
        ratingLabel.text = "⭐️\(EquipmentData.equipment[indexPath.row].rating)"
        

    }
   
    @IBAction func bookNowButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
    }
    
    
}
