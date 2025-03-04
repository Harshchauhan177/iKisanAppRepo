//
//  AgriAssistViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

var myIndex = 0

class AgriAssistViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{
    
    @IBOutlet weak var cropSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    //    let suggestions = ["Rice", "Wheat", "Oats", "Cotton", "Tea", "Maize", "Tobacco", "Sugarcane"]
    //        var filteredCrops: [String] = []
        
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
            
            // Register cell from nib
    //
            
            tableView.delegate = self
            tableView.dataSource = self
            cropSearchBar.delegate = self
            
            // Load data if dataController is already set
            if dataController != nil {
                loadData()
            }
        }
        
        private func loadData() {
            crops = dataController.getAllCrops()
            filteredCrops = crops
            tableView.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredCrops = crops
            }
            else{
                filteredCrops = crops.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
            tableView.reloadData()
        }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        
        
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return filteredCrops.count
            }
            
            // Cell for each row
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CropCell", for: indexPath) as? CropTableViewCell else {
                    return UITableViewCell()
                }
                
                let crop = filteredCrops[indexPath.row]
                cell.configure(with: crop)
                return cell
            }
            
            // Action when a row is selected
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let selectedCrop = filteredCrops[indexPath.row]
                print("Selected crop: \(selectedCrop.name) with ID: \(selectedCrop.id)")
                performSegue(withIdentifier: "SelectCrops", sender: selectedCrop)
            }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "SelectCrops",
               let equipmentsVC = segue.destination as? EquipmentsForCropsViewController,
               let selectedCrop = sender as? AgriCrop {
                equipmentsVC.dataController = dataController
                equipmentsVC.selectedCropId = selectedCrop.id
            }
        }
    
    
    
    }

