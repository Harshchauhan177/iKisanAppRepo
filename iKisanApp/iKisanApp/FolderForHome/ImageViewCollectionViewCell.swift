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
        imageView.image = UIImage(named: image)
       
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        updateCellUI()
    }
   
    override func awakeFromNib() {
           super.awakeFromNib()
           imageView.contentMode = .scaleAspectFill // Adjust to your preference
           imageView.clipsToBounds = true
       }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateCellUI()
    }
    
    func updateCellUI () {
        self.layer.cornerRadius = 5
        
       // self.backgroundColor = .systemBrown.withAlphaComponent(0.7)
        //self.backgroundColor = .green.withAlphaComponent(0.4)
    }
}
