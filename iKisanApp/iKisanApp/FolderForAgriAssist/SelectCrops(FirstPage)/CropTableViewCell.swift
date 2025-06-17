//
//  CropTableViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 16/01/25.
//

import UIKit

class CropTableViewCell: UITableViewCell {

    @IBOutlet weak var cropImageView: UIImageView!
    @IBOutlet weak var cropNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Add any custom UI setup here
        cropImageView.contentMode = .scaleAspectFit
        cropImageView.clipsToBounds = true
        
        // Optional: Add corner radius to image
        cropImageView.layer.cornerRadius = 8
        cropImageView.layer.masksToBounds = true
    }
    
    func configure(with crop: AgriCrop) {
        cropNameLabel.text = crop.name
        // Use the existing ImageCache utility to load and cache the image
        if !crop.imageName.isEmpty {
            cropImageView.loadImage(from: crop.imageName, placeholder: UIImage(systemName: "leaf"))
        } else {
            cropImageView.image = UIImage(systemName: "leaf")
        }
    }
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
