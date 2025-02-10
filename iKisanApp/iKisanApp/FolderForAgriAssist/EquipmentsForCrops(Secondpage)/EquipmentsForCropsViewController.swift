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
        
        cell.contentView.layer.cornerRadius = 15 // Set corner radius
        cell.contentView.layer.masksToBounds = true
    
        return cell
    }
    
}
