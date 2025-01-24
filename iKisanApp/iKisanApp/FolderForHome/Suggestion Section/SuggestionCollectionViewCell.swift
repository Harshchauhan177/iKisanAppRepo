//
//  SuggestionCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit


class SuggestionCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var suggestionImageView: UIImageView!
    @IBOutlet  var suggestionNameLabel: UILabel!
    @IBOutlet  var suggestionDescriptionLabel: UILabel!
    
    func updateSuggestionData(with indexPath: IndexPath){
        suggestionImageView.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentImage)
        suggestionNameLabel.text = EquipmentData.equipment[indexPath.row].name
        suggestionDescriptionLabel.text = "Available in your area."//EquipmentData.equipment[indexPath.row].description
    }
    
}
