//
//  accountTableViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 18/02/25.
//

import UIKit

class accountTableViewCell: UITableViewCell {

    @IBOutlet weak var accountImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Add any custom UI setup here
        accountImageView.contentMode = .scaleAspectFit
        accountImageView.clipsToBounds = true
        
        // Optional: Add corner radius to image
        accountImageView.layer.cornerRadius = 8
        accountImageView.layer.masksToBounds = true
    }
    
    func configure(with crop: Crop) {
//        cropNameLabel.text = crop.name
        // Use the existing ImageCache utility to load and cache the image
        if !crop.imageURL.isEmpty {
            accountImageView.loadImage(from: crop.imageURL, placeholder: UIImage(systemName: "leaf"))
        } else {
            accountImageView.image = UIImage(systemName: "leaf")
        }
    }
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
