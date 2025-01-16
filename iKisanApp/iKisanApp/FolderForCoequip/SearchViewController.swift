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
//        let selectedText = filteredSuggestions[indexPath.row]
//            searchBarLabel.text = selectedText
//            searchBarLabel.resignFirstResponder()
//            selectedSuggestion = selectedText
//            if let createRequestVC = storyboard?.instantiateViewController(withIdentifier: "createRequestfromsearch") as? CreateRequestViewController {
//                createRequestVC.selectedSuggestion = selectedSuggestion
//                createRequestVC.modalPresentationStyle = .fullScreen
//                present(createRequestVC, animated: true, completion: nil)
//            }
//       }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "createRequestfromsearch" {
//            if let createRequestVC = segue.destination as? CreateRequestViewController {
//                createRequestVC.selectedSuggestion = selectedSuggestion
//            }
//        }
//    }


}
