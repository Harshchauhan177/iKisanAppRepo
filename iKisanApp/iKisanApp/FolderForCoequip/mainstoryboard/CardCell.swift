//
//  CardCell.swift
//  iKisanApp
//
//  Created by chandan kumar on 21/01/25.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var PriceLabel: UILabel!
    
    @IBOutlet weak var OrigianlPriceLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var hostLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
        ImageView.contentMode = .scaleAspectFill
                TitleLabel.numberOfLines = 2 
                PriceLabel.numberOfLines = 1
                hostLabel.numberOfLines = 1
                ratingLabel.numberOfLines = 1
        }
}
