//
//  ImageViewCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 20/01/25.
//

import UIKit

class ImageViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    
    func updateCellData(with image : String) {
        print("Loading image in cell: \(image)")
        
        // Check if image name is a URL
        if image.hasPrefix("http") {
            print("Loading URL image: \(image)")
            // It's a URL, use our ImageCache utility to load it
            imageView.loadImage(from: image)
        } else {
            print("Loading local asset: \(image)")
            // Local asset
            imageView.image = UIImage(named: image) ?? UIImage(named: "placeholder_image")
        }
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        updateCellUI()
    }
   
    override func awakeFromNib() {
           super.awakeFromNib()
           imageView.contentMode = .scaleAspectFill
           imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 13
       }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateCellUI()
    }
    
    func updateCellUI () {
        self.layer.cornerRadius = 5
        
       
    }
}
