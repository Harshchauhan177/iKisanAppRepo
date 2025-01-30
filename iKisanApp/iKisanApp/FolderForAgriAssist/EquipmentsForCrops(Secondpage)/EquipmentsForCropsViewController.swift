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
        //        EquipmentsForCropsLabel.text = eData.EquipmentsForCropsData[myIndex].EquipmentsForCrops
        
        // Do any additional setup after loading the view.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
//        return eData.EquipmentsForCropsData.count
        5
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return eData[section].sectionType
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! myTableViewCell
        cell.myCollectionView.tag = indexPath.section
        cell.contentView.layer.cornerRadius = 15 // Set corner radius
        cell.contentView.layer.masksToBounds = true
//        cell.contentView.layer.borderWidth = 5
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.tintColor = .orange
//
//    }
    
    


}
