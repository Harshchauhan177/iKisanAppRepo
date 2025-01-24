

import UIKit

class SelectPeopleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    
    
    @IBOutlet weak var filterButtonLabel: UIButton!
    
    @IBOutlet weak var searchBarLabel: UISearchBar!
    
    @IBOutlet weak var ListTableViewCell: UITableView!
    
    @IBOutlet weak var filterLabel: UIButton!
    
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

            searchBarLabel.delegate = self
            
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
               return cell
            
        }
        
    
    @IBAction func FilterbuttonTapped(_ sender: Any) {
        
    }
    
    @IBAction func DoneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindToInfo", sender: self)
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
