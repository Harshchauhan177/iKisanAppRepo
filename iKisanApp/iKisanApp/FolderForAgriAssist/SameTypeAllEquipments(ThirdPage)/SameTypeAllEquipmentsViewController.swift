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
    
    var dataController: DataController!
    var selectedCategoryId: UUID!
    var equipments: [EquipmentAgri] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Load equipment data for the selected category
        if let categoryId = selectedCategoryId {
            equipments = dataController.getEquipmentsByCategory(categoryId: categoryId)
            print("Loaded \(equipments.count) equipments for category ID: \(categoryId)")
        } else {
            print("No category ID provided.")
        }
        
        SameTypeAllEquipmentsCollectionView.reloadData() // Reload the collection view with the new data
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return equipments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SameTypeAllEquipmentsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let equipment = equipments[indexPath.item]
        cell.configure(with: equipment)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let equipment = equipments[indexPath.item]
        performSegue(withIdentifier: "ShowEquipmentDetails", sender: equipment)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEquipmentDetails",
           let destinationVC = segue.destination as? infoAboutEquipmentsViewController,
           let equipment = sender as? EquipmentAgri {
            destinationVC.dataController = dataController
            destinationVC.selectedEquipmentId = equipment.id
        }
    }
}
