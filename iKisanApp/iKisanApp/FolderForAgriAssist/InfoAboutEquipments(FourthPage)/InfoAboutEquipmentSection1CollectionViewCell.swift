//
//  InfoAboutEquipmentSection1CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 21/01/25.
//

import UIKit

class InfoAboutEquipmentSection1CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var equipmentTypeNameLabel: UILabel!
    @IBOutlet weak var equipmentTypeImageView: UIImageView!
    @IBOutlet weak var equipmentTypeLikedByLabel: UILabel!
    @IBOutlet weak var equipmentTypePurposeLabel: UILabel!
    @IBOutlet weak var equipmentTypeBestForLabel: UILabel!
    @IBOutlet weak var equipmentTypeAverageCostLabel: UILabel!
    @IBOutlet weak var equipmentTypeNeedsLabel: UILabel!
    
    
    
    func updateSection1Data(with indexPath: IndexPath){
        equipmentTypeNameLabel.text = ScreenData.section1Data[indexPath.row].equipmentTypeName
    
        equipmentTypeImageView.image = UIImage(named: ScreenData.section1Data[indexPath.row].equipmentTypeImage)
        
        equipmentTypeLikedByLabel.text = ScreenData.section1Data[indexPath.row].equipmentTypeLikedBy
        
        equipmentTypePurposeLabel.text = ScreenData.section1Data[indexPath.row].equipmentTypePurpose
        
        equipmentTypeBestForLabel.text = ScreenData.section1Data[indexPath.row].equipmentTypeBestFor
        
        equipmentTypeAverageCostLabel.text = ScreenData.section1Data[indexPath.row].equipmentTypeAverageCost
        
        equipmentTypeNeedsLabel.text = ScreenData.section1Data[indexPath.row].equipmentTypeNeeds
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
