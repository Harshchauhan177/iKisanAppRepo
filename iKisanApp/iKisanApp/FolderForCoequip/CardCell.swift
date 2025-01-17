//
//  CardCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var hostLabel: UILabel!
    
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var originalPriceLabel: UILabel!
    func configure(title: String, price: String, originalPrice: String, rating: String, host: String) {
            titleLabel.text = title
            priceLabel.text = price
            originalPriceLabel.text = originalPrice
            ratingLabel.text = "⭐️ \(rating)"
            hostLabel.text = host

            // Example styling
            priceLabel.textColor = .systemGreen
            originalPriceLabel.textColor = .systemGray
            ratingLabel.textColor = .systemYellow
            hostLabel.textColor = .systemBlue
        }
}
