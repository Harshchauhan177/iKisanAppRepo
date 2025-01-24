//
//  AgriAssistViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

var crops: [AgriCrop] = [
    AgriCrop(id: 1, name: "Rice", imageName: UIImage(named: "Rice") ?? UIImage()),
    AgriCrop(id: 2, name: "Wheat", imageName: UIImage(named: "Wheat") ?? UIImage()),
    AgriCrop(id: 3, name: "Oats", imageName: UIImage(named: "Oats") ?? UIImage()),
    AgriCrop(id: 4, name: "Cotton", imageName: UIImage(named: "Cotton") ?? UIImage()),
    AgriCrop(id: 5, name: "Tea", imageName: UIImage(named: "Tea") ?? UIImage()),
    AgriCrop(id: 6, name: "Maize", imageName: UIImage(named: "Maize") ?? UIImage()),
    AgriCrop(id: 7, name: "Tobacco", imageName: UIImage(named: "Tobacco") ?? UIImage()),
    AgriCrop(id: 8, name: "Sugarcane", imageName: UIImage(named: "Sugarcane") ?? UIImage())
]

var myIndex = 0

class AgriAssistViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{
    
    
    @IBOutlet weak var cropSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

//    let suggestions = ["Rice", "Wheat", "Oats", "Cotton", "Tea", "Maize", "Tobacco", "Sugarcane"]
//        var filteredCrops: [String] = []
    
    var filteredCrops: [AgriCrop] = []
//   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        cropSearchBar.delegate = self
        filteredCrops = crops
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
            
            // Configure the cell
//            let crop = crops[indexPath.row]
//            cell.cropNameLabel.text = crop.name
//            cell.cropImageView.image = crop.imageName
//            
//            return cell
            
            let crop = filteredCrops[indexPath.row]
                    cell.cropNameLabel.text = crop.name
                    cell.cropImageView.image = crop.imageName
                    
                    return cell
        }
        
        // Action when a row is selected
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCrop = filteredCrops[indexPath.row]
            print("Selected Crop: \(selectedCrop.name)")
            
            
            
            myIndex = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "SelectCrops", sender: self)
        }
}

