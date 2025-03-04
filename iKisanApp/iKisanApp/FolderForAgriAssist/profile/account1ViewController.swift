//
//  accountViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 18/02/25.
//

import UIKit

class account1ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var accountTableView: UITableView!
    
    
    
    var dataController: DataController! {
        didSet {
            // Load data when dataController is set
            if isViewLoaded {
                loadData()
            }
        }
    }
    private var crops: [AgriCrop] = []
    private var filteredCrops: [AgriCrop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTableView.delegate = self
        accountTableView.dataSource = self
        
        // Load data if dataController is already set
        if dataController != nil {
            loadData()
        }
    }
    
    private func loadData() {
        crops = dataController.getAllCrops()
        filteredCrops = crops
        accountTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return filteredCrops.count
        1
        }
        
        // Cell for each row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = accountTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? accountTableViewCell else {
                return UITableViewCell()
            }
            
//            let crop = filteredCrops[1]
//            cell.configure(with: crop)
            return cell
        }
        

}
