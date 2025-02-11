//
//  EquipmentsForCropsViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 19/01/25.
//

import UIKit

class EquipmentsForCropsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var EquipmentsForCropsLabel: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EquipmentsForCropsLabel.title = EData.EquipmentsForCropsData[myIndex].EquipmentsForCrops
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return EData.EquipmentsForCropsData[myIndex].equipments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! myTableViewCell
        
        // Pass the section index and equipment category
        cell.sectionIndex = indexPath.section
        cell.equipmentCategory = EData.EquipmentsForCropsData[myIndex].equipments[indexPath.section]
        
        // Add the callback for view all button
        cell.onViewAllTapped = { [weak self] category in
            self?.performSegue(withIdentifier: "ShowAllEquipments", sender: category)
        }
          
        cell.contentView.layer.cornerRadius = 15 // Set corner radius
        cell.contentView.layer.masksToBounds = true
    
        return cell
    }
    // Add prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAllEquipments",
           let category = sender as? EquipmentCategory,
           let destinationVC = segue.destination as? SameTypeAllEquipmentsViewController {
            destinationVC.selectedCategory = category
        }
    }
}
