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
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

//        EquipmentsTypeNavHeaderLabel.title = EData.EquipmentsForCropsData[myIndex].EquipmentsForCrops
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return Data.flatMap { $0.Equipmentsimage }.count
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = SameTypeAllEquipmentsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)as! SameTypeAllEquipmentsCollectionViewCell
//        cell.SameTypeAllEquipmentsImage.image = UIImage(named: Data[EquipmentsForCrops.row].Equipmentsimage)
//        cell.SameTypeAllEquipmentsNameLabel.text =
//        return cell
        
        
        
        let flattenedData = Data.flatMap { $0.Equipmentsimage }
                let imageName = flattenedData[indexPath.item]
                
                // Get the corresponding name from the EquipmentsName array
                let name = Data.flatMap { $0.EquipmentsName }[indexPath.item]

                // Dequeue the cell
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SameTypeAllEquipmentsCollectionViewCell {
                    // Set the image and name for the cell
                    cell.SameTypeAllEquipmentsImage.image = UIImage(named: imageName)
                    cell.SameTypeAllEquipmentsNameLabel.text = name
                    return cell
                }
                
                return UICollectionViewCell()
    }
}
