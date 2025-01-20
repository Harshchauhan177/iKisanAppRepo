//
//  Section1CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit

class Section1CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var CategoryLabel: UILabel!
    func updateSection1Data(with indexPath: IndexPath) {
        CategoryLabel.text = EquipmentScreenData.equipmentNames[indexPath.row].name
       }

}
