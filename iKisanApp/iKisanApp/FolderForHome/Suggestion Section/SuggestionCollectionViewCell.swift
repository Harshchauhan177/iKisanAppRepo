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
    
    func updateSuggestionData(with equipment: Equipment) {
        suggestionImageView.image = UIImage(named: equipment.equipmentImage)
        suggestionNameLabel.text = equipment.name
        suggestionDescriptionLabel.text = equipment.description ?? "Available in your area."
    }

    
}
