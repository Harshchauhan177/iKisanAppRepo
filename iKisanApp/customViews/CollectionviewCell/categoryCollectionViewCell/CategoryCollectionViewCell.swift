//
//  CategoryCollectionViewCell.swift
//  iKisanApp
//
//  Created by chandan kumar on 21/01/25.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
 
    static let identifier = "CategoryCollectionViewCell"
    
    @IBOutlet weak var categoryLabel: UILabel!
    func update(category: CropCatergory){
        categoryLabel.text = category.name
    }

}
