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
    
    
    var peoplesData = pupil.allPeopleData
      
    var people: [PersonList] = []

    var selectedPeople: [PersonList] = []
   
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            ListTableViewCell.delegate = self
            ListTableViewCell.dataSource = self
            guard ListTableViewCell != nil else {
                       print("Table view is not connected!")
                       return
                   }
//            ListTableViewCell.register(SelectPeopleListTableViewCell.self, forCellReuseIdentifier: "selectPeople")
            searchBarLabel.delegate = self
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return pupil.allPeopleData.count
            print("count : \(peoplesData.count)")
            return peoplesData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

          guard let cell = tableView.dequeueReusableCell(withIdentifier: "selectPeople", for: indexPath) as? SelectPeopleListTableViewCell else {
                   fatalError("Could not dequeue cell with identifier: SelectPeopleListTableViewCell")
               }
            let people = peoplesData[indexPath.row]
            print(people.name)
            print(indexPath.row)
            cell.UpdateCellData(with: people)
//            cell.UpdateCellData(with: people)
               return cell
            
        }
        
        // MARK: - Table View Delegate
        

       //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            var persons = people[indexPath.row]
//            persons.isSelected.toggle() // Toggle the selection state
//            
//            people[indexPath.row] = persons
//            
//            
//            tableView.reloadData() // Reload the table to reflect changes
//        }
        
    
    @IBAction func FilterbuttonTapped(_ sender: Any) {
    }
    
   

}
extension SelectPeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            people = peoplesData
        } else {
            people = peoplesData.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        ListTableViewCell.reloadData()
    }
}
