//
//  SelectPeopleViewController.swift
//  iKisanApp
//
//  Created by chandan kumar on 23/01/25.
//

import UIKit

class SelectPeopleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    
    
    @IBOutlet weak var filterButtonLabel: UIButton!
    
    @IBOutlet weak var searchBarLabel: UISearchBar!
    
    @IBOutlet weak var ListTableViewCell: UITableView!
    
    var allPeopleData: [PersonList] = [
            PersonList(name: "John Doe", image: UIImage(named: "person1") ?? UIImage(), isSelected: false),
            PersonList(name: "Jane Smith", image: UIImage(named: "person2") ?? UIImage(), isSelected: false),
            PersonList(name: "Paul Walker", image: UIImage(named: "person3") ?? UIImage(), isSelected: false),
            PersonList(name: "Robert Johnson", image: UIImage(named: "person4") ?? UIImage(), isSelected: false),
            PersonList(name: "Emily Davis", image: UIImage(named: "person5") ?? UIImage(), isSelected: false)
        ]
    
       // This will hold the filtered data
    var people: [PersonList] = []

       // This will hold the selected people when the user presses Done
    var selectedPeople: [PersonList] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            people = allPeopleData
            ListTableViewCell.delegate = self
            ListTableViewCell.dataSource = self
            guard ListTableViewCell != nil else {
                       print("Table view is not connected!")
                       return
                   }
            ListTableViewCell.register(SelectPeopleListTableViewCell.self, forCellReuseIdentifier: "selectPeople")
            searchBarLabel.delegate = self
            
        }

        // MARK: - Table View Data Source
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return people.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectPeople", for: indexPath) as! SelectPeopleListTableViewCell
            
            let persons = people[indexPath.row]
            cell.NameLabel.text = persons.name
            cell.ImageLabel.image = persons.image
            cell.checkboxButton.isSelected = persons.isSelected
            
            return cell
        }
        
        // MARK: - Table View Delegate
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            var persons = people[indexPath.row]
            persons.isSelected.toggle() // Toggle the selection state
            
            people[indexPath.row] = persons
            
            
            tableView.reloadData() // Reload the table to reflect changes
        }
        
    
    @IBAction func FilterbuttonTapped(_ sender: Any) {
    }
    
   

}
extension SelectPeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Reset the filter if search text is empty
            people = allPeopleData // `allPeopleData` should be your full array of people.
        } else {
            people = allPeopleData.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        ListTableViewCell.reloadData()
    }
}
