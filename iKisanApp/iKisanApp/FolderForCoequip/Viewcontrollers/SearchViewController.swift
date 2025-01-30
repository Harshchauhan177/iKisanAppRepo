//
//  SearchViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 16/01/25.
//

import UIKit

class SearchViewController: UIViewController,UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var searchBarLabel: UISearchBar!
    
    @IBOutlet weak var tableViewLabel: UITableView!
    
    let suggestions = ["Harvester", "Harvester near you", "Rice harvester", "Tractor", "Plough"]
    var filteredSuggestions: [String] = []
    var selectedSuggestion: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBarLabel.delegate = self
        tableViewLabel.delegate = self
        tableViewLabel.dataSource = self
        filteredSuggestions = suggestions
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredSuggestions = suggestions
            } else {
                filteredSuggestions = suggestions.filter { $0.lowercased().contains(searchText.lowercased()) }
            }
        tableViewLabel.reloadData()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = filteredSuggestions[indexPath.row]
                return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            selectedSuggestion = filteredSuggestions[indexPath.row] // Store the selected suggestion
//            performSegue(withIdentifier: "showSecondViewController", sender: selectedSuggestion) // Pass the selected suggestion
//        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showSecondViewController" {
                if let secondVC = segue.destination as? CreateRequestViewController {
                    secondVC.selectedSuggestion = sender as? String
                }
            }
        }
}
