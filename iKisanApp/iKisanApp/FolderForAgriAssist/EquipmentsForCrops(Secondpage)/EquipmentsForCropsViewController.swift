//
//  EquipmentsForCropsViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 19/01/25.
//

import UIKit


var eData = [
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"])
    
]

class EquipmentsForCropsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return eData.count
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
