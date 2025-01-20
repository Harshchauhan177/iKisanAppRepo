//
//  SameTypeAllEquipmentsCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit

class SameTypeAllEquipmentsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var SameTypeAllEquipmentsImage: UIImageView!
    @IBOutlet weak var SameTypeAllEquipmentsNameLabel: UILabel!
    
//    override func awakeFromNib() {
//            super.awakeFromNib()
//            
//            // Make the image circular by setting the corner radius to half of the image's width
//            SameTypeAllEquipmentsImage.layer.cornerRadius = 45
//            
//            // Clip the image to the circular shape
//            SameTypeAllEquipmentsImage.clipsToBounds = true
//            
//            // Add a border around the image
//            SameTypeAllEquipmentsImage.layer.borderWidth = 3  // Border width
//        SameTypeAllEquipmentsImage.layer.borderColor = UIColor.black.cgColor  // Border color
//        }
//        
//        // Configure the cell with the image and name
//        func configureCell(image: UIImage?, name: String) {
//            SameTypeAllEquipmentsImage.image = image
//            SameTypeAllEquipmentsNameLabel.text = name
//        }
    
    
    
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
            // Make the image view square
            // Since the image has a width of 990px and height of 90px,
            // we'll set the height of the image view to 90px (same as the image height),
            // but the width will also be set to 90px for a square shape.
            SameTypeAllEquipmentsImage.layer.cornerRadius = SameTypeAllEquipmentsImage.frame.size.width / 2
            
            // Clip the image to the circular shape
            SameTypeAllEquipmentsImage.clipsToBounds = true
            
            // Add a border around the image
            SameTypeAllEquipmentsImage.layer.borderWidth = 3  // Border width
        SameTypeAllEquipmentsImage.layer.borderColor = UIColor.gray.cgColor  // Border color
        }
        
        // Configure the cell with the image and name
        func configureCell(image: UIImage?, name: String) {
            SameTypeAllEquipmentsImage.image = image
            SameTypeAllEquipmentsNameLabel.text = name
            
            // Important: Update the corner radius and border width after setting the image
            SameTypeAllEquipmentsImage.layer.cornerRadius = SameTypeAllEquipmentsImage.frame.size.width / 2
        }
    
}
