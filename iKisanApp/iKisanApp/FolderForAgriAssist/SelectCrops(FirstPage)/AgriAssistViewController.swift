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
        
    var dataController: DataController!
    private var crops: [AgriCrop] = []
    private var filteredCrops: [AgriCrop] = []
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure dataController is initialized
        guard dataController != nil else {
            print("❌ Error: DataController not initialized in AgriAssistViewController")
            // This shouldn't happen if MainTabBarController is properly set up
            return
        }
        
        // Register cell from nib
    //
            
        tableView.delegate = self
        tableView.dataSource = self
        cropSearchBar.delegate = self
        
        // Setup pull-to-refresh
        setupRefreshControl()
        
        // Load crops data
        loadCropsData()
    }
    
    private func setupRefreshControl() {
     
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        print("Pull-to-refresh triggered in AgriAssistViewController")
        // Start refresh animation
        refreshControl.beginRefreshing()
        
        // Reload data asynchronously
        loadCropsData()
    }
    
    private func loadCropsData() {
        Task {
            do {
                self.crops = try await SupabaseManager.shared.client
                    .from("cropCategories")
                    .select("*")
                    .execute()
                    .value
                self.filteredCrops = self.crops
                
                // Update UI on main thread
                await MainActor.run {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    print("Refresh completed in AgriAssistViewController")
                }
            } catch {
                print("Error loading crops data: \(error)")
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                }
            }
        }
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
        // Pass both the crop and its name
        performSegue(withIdentifier: "SelectCrops", sender: selectedCrop)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectCrops",
           let equipmentsVC = segue.destination as? EquipmentsForCropsViewController,
           let selectedCrop = sender as? AgriCrop {
            equipmentsVC.dataController = dataController
            equipmentsVC.selectedCropId = selectedCrop.id
            // Pass the crop name as well
            equipmentsVC.selectedCropName = selectedCrop.name
        }
    }
}

