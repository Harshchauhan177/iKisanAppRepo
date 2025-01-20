//
//  Section2CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit

class Section2CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var categoryImage: UIImageView!
    
    
    @IBOutlet weak var categoryDataTitle: UILabel!
    
    @IBOutlet weak var categoryDataPrice: UILabel!
    
    @IBOutlet weak var categoryDataOriginalPrice: UILabel!
    
    @IBOutlet weak var categoryEquipmentHost: UILabel!
    
    @IBOutlet weak var categoryDataReview: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateSection2Data(with indexPath: IndexPath) {
           
            let equipmentDetail = EquipmentScreenData.equipmentDetails[indexPath.row]
            
           
            categoryDataTitle.text = equipmentDetail.name
           
            categoryImage.image = UIImage(named: equipmentDetail.imageName)
            
             
            categoryDataPrice.text = "$999.99"
            categoryDataOriginalPrice.text = "$1199.99"
            categoryEquipmentHost.text = "Available from XYZ Equipment Co."
            categoryDataReview.setTitle("4.5 ★ Review", for: .normal)
        }
    
    
}
