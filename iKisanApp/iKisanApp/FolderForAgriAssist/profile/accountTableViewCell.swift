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
    
    func configure(with crop: AgriCrop) {
//        cropNameLabel.text = crop.name
        accountImageView.image = UIImage(named: crop.imageName)
    }
}
