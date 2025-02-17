//
//  EquipmentsForCropsViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 19/01/25.
//

import UIKit

class EquipmentsForCropsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, MyTableViewCellDelegate {

    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var EquipmentsForCropsLabel: UINavigationItem!
    
    var dataController: DataController!
    var selectedCropId: UUID!
    private var equipmentCategories: [EquipmentCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Selected crop ID: \(selectedCropId?.uuidString ?? "nil")")
        equipmentCategories = dataController.getEquipmentCategories(forCrop: selectedCropId)
        print("Found \(equipmentCategories.count) equipment categories")
        
        if let cropCategory = dataController.getCropCategory(forCrop: selectedCropId) {
            print("Found crop category: \(cropCategory.cropName)")
            EquipmentsForCropsLabel.title = cropCategory.equipmentsForCrops
        }
        
        myTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return equipmentCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? myTableViewCell else {
            return UITableViewCell()
        }
        
        let category = equipmentCategories[indexPath.section]
        cell.dataController = dataController
        cell.selectedCropId = selectedCropId
        cell.sectionIndex = indexPath.section
        cell.configure(with: category)
        
        // Set the delegate for the cell
        cell.delegate = self // Ensure you have a delegate property in myTableViewCell
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.tintColor = .orange
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAllEquipments",
           let destinationVC = segue.destination as? SameTypeAllEquipmentsViewController,
           let category = sender as? EquipmentCategory {
            print("Navigating to ShowAllEquipments with category: \(category.title)")
            destinationVC.dataController = dataController
            destinationVC.selectedCategoryId = category.id
            destinationVC.title = "\(category.title)"
        } else if segue.identifier == "ShowEquipmentDetails",
                  let destinationVC = segue.destination as? infoAboutEquipmentsViewController,
                  let equipment = sender as? EquipmentAgri {
            print("Preparing ShowEquipmentDetails segue")
            print("Equipment: \(equipment.name) with ID: \(equipment.id)")
            print("DataController exists: \(dataController != nil)")
            
            destinationVC.dataController = self.dataController
            destinationVC.selectedEquipmentId = equipment.id
            
            
            
            print("After setting - DataController exists: \(destinationVC.dataController != nil)")
            print("After setting - SelectedEquipmentId: \(destinationVC.selectedEquipmentId?.uuidString ?? "nil")")
        }
    }
    
    // When the see all button is tapped in myTableViewCell
    func didTapSeeAll(for category: EquipmentCategory) {
        performSegue(withIdentifier: "ShowAllEquipments", sender: category)
    }

}
