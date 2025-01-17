//
//  CategoryCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    func configure(category: String) {
            categoryLabel.text = category
            categoryLabel.textAlignment = .center
            categoryLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            categoryLabel.textColor = .white
            self.contentView.backgroundColor = .systemBlue
            self.contentView.layer.cornerRadius = 8
            self.contentView.layer.masksToBounds = true
        }
    
}
