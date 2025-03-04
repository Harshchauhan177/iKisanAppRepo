//
//  SearchViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 16/01/25.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBarLabel: UISearchBar!
    @IBOutlet weak var tableViewLabel: UITableView!
    
    var dataController: DataController?
    var filteredSuggestions: [String] = []
    var selectedSuggestion: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewLabel.delegate = self
        tableViewLabel.dataSource = self
        searchBarLabel.delegate = self
        filteredSuggestions = []
        searchBarLabel.delegate = self
        tableViewLabel.delegate = self
        tableViewLabel.dataSource = self
        searchBarLabel.placeholder = "Search equipment..."
        searchBarLabel.searchBarStyle = .minimal
        if let textField = searchBarLabel.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .systemGray6
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredSuggestions = []
        } else {
            filteredSuggestions = (dataController?.getEquipmentSuggestions() ?? []).filter {
                $0.lowercased().contains(searchText.lowercased())
            }
        }
        tableViewLabel.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let suggestion = filteredSuggestions[indexPath.row]
        if let searchText = searchBarLabel.text, !searchText.isEmpty {
            let attributedString = NSMutableAttributedString(string: suggestion)
            let range = (suggestion.lowercased() as NSString).range(of: searchText.lowercased())
            if range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
                cell.textLabel?.attributedText = attributedString
            } else {
                cell.textLabel?.text = suggestion
            }
        } else {
            cell.textLabel?.text = suggestion
        }
        
        return cell
    }
    
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSuggestion = filteredSuggestions[indexPath.row]
        if let navController = self.navigationController {
            if let existingVC = navController.viewControllers.first(where: { $0 is CreateRequestViewController }) as? CreateRequestViewController {
                existingVC.selectedSuggestion = selectedSuggestion
                existingVC.dataController = self.dataController
                existingVC.applySearchFilter()
                navController.popToViewController(existingVC, animated: true)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let createRequestVC = storyboard.instantiateViewController(withIdentifier: "CreateRequestViewController") as? CreateRequestViewController {
                createRequestVC.dataController = self.dataController
                createRequestVC.selectedSuggestion = self.selectedSuggestion
                navigationController?.pushViewController(createRequestVC, animated: true)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreateRequestViewController",
           let createRequestVC = segue.destination as? CreateRequestViewController {
            createRequestVC.dataController = self.dataController
            createRequestVC.selectedSuggestion = self.selectedSuggestion
        } 
    }
}
