//
//  InfoAboutEquipmentSection2CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 21/01/25.
//

import UIKit

class InfoAboutEquipmentSection2CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentLikedByLabel: UILabel!
    
    
    func updateSection2Data(with indexPath :IndexPath){
        equipmentNameLabel.text = ScreenData.section2Data[indexPath.row].equipmentName
        
        equipmentImageView.image = UIImage(named: ScreenData.section2Data[indexPath.row].equipmentImage)
        
        equipmentLikedByLabel.text = ScreenData.section2Data[indexPath.row].equipmentLikedBy
        
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
