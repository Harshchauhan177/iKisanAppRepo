//
//  SameTypeAllEquipmentsViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit


class SameTypeAllEquipmentsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var SameTypeAllEquipmentsCollectionView: UICollectionView!
    @IBOutlet weak var EquipmentsTypeNavHeaderLabel: UINavigationItem!
    
    var selectedCategory: EquipmentCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the navigation title
        EquipmentsTypeNavHeaderLabel.title = selectedCategory?.title
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedCategory?.equipmentList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SameTypeAllEquipmentsCollectionViewCell,
              let equipment = selectedCategory?.equipmentList[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        // Configure the cell with the equipment data
        cell.SameTypeAllEquipmentsImage.image = UIImage(named: equipment.imageName)
        cell.SameTypeAllEquipmentsNameLabel.text = equipment.name
        
        return cell
    }
}
