//
//  SameTypeAllEquipmentsViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit

var Data = [
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["1","2","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle3","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle4","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle5","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle6","cultivater","harrow","hhaarrooww","herahero"])
    
]

class SameTypeAllEquipmentsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var SameTypeAllEquipmentsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    
//    var currentData: EquipmentsForCrops?
//
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            
//            // Initially load the first row data (first item in Data array)
//            currentData = Data.first
//        }
//        
//        // Button actions to show different data
//
//        @IBAction func onViewAllFirstRow(_ sender: UIButton) {
//            // When View All is clicked for the first row, load the first row data
//            currentData = Data[0]
//            SameTypeAllEquipmentsCollectionView.reloadData()
//        }
//
//        @IBAction func onViewAllSecondRow(_ sender: UIButton) {
//            // When View All is clicked for the second row, load the second row data
//            currentData = Data[1]
//            SameTypeAllEquipmentsCollectionView.reloadData()
//        }
//
//        @IBAction func onViewAllThirdRow(_ sender: UIButton) {
//            // When View All is clicked for the third row, load the third row data
//            currentData = Data[2]
//            SameTypeAllEquipmentsCollectionView.reloadData()
//        }
//
//        // UICollectionView DataSource methods
//        
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            // Return the count of images in the currentData (filtered based on selected row)
//            return currentData?.Equipmentsimage.count ?? 0
//        }
//
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            // Dequeue the cell
//            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SameTypeAllEquipmentsCollectionViewCell {
//                
//                // Get the image and name from the currentData array for the selected row
//                let imageName = currentData?.Equipmentsimage[indexPath.item] ?? ""
//                let name = currentData?.EquipmentsName[indexPath.item] ?? ""
//                
//                // Set the image and name for the cell
//                cell.SameTypeAllEquipmentsImage.image = UIImage(named: imageName)
//                cell.SameTypeAllEquipmentsNameLabel.text = name
//                
//                return cell
//            }
//            
//            return UICollectionViewCell()
//        }

}
