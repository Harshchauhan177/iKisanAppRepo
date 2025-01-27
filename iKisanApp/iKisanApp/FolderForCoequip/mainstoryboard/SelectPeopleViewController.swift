import UIKit

class SelectPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var filterButtonLabel: UIButton!
    @IBOutlet weak var searchBarLabel: UISearchBar!
    @IBOutlet weak var ListTableViewCell: UITableView!
    @IBOutlet weak var filterLabel: UIButton!

    var filteredUsers: [CoequipUser] = sampleUsers
    var userSelected: [UUID: Bool] = [:]
    var selectedUsers: [CoequipUser] = []
    var allUsers: [CoequipUser] = sampleUsers

    // Custom filter options table
    var filterOptionsTableView: UITableView!
    var isFilterOptionsVisible = false
    let filterOptions = ["Category 1", "Category 2", "Category 3"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the table view cell for users
        ListTableViewCell.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")

        // Set delegates
        ListTableViewCell.delegate = self
        ListTableViewCell.dataSource = self
        searchBarLabel.delegate = self

        filterOptionsTableView = UITableView(frame: CGRect(x: filterButtonLabel.frame.origin.x, y: filterButtonLabel.frame.origin.y + filterButtonLabel.frame.height, width: filterButtonLabel.frame.width, height: 150))
            filterOptionsTableView.delegate = self
            filterOptionsTableView.dataSource = self
            filterOptionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
            
            // Hide filter options initially
            filterOptionsTableView.isHidden = true
            self.view.addSubview(filterOptionsTableView)
            
            // Initially, filteredUsers will be the same as allUsers
            filteredUsers = allUsers
    }

    // TableView Delegate and DataSource for users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filterOptionsTableView {
            return filterOptions.count // Show filter options
        }
        return filteredUsers.count // Show filtered users
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == filterOptionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
            cell.textLabel?.text = filterOptions[indexPath.row]
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = user.name
        cell.accessoryType = userSelected[user.id] ?? false ? .checkmark : .none
        return cell
    }

    // Handle user row selection for check/uncheck
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == filterOptionsTableView {
            let selectedOption = filterOptions[indexPath.row]
            applyFilter(option: selectedOption)
            // Hide the filter options after selection
            isFilterOptionsVisible.toggle()
            filterOptionsTableView.isHidden = !isFilterOptionsVisible
        } else {
            // Toggle selection of users
            let user = filteredUsers[indexPath.row]
            userSelected[user.id] = !(userSelected[user.id] ?? false)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    // Apply the filter based on the selected option
    func applyFilter(option: String) {
        switch option {
        case "Category 1":
            filteredUsers = allUsers.filter { $0.name?.lowercased().contains("category1") ?? false }
        case "Category 2":
            filteredUsers = allUsers.filter { $0.name?.lowercased().contains("category2") ?? false }
        case "Category 3":
            filteredUsers = allUsers.filter { $0.name?.lowercased().contains("category3") ?? false }
        default:
            filteredUsers = allUsers
        }
        ListTableViewCell.reloadData() // Reload table with the filtered data
    }

    // Search Bar Filter
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter { user in
                user.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        ListTableViewCell.reloadData()
    }

    // Show the filter options table when the button is tapped
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        isFilterOptionsVisible.toggle()
            
            if isFilterOptionsVisible {
                // Set height of the filter table to fit its content
                filterOptionsTableView.frame = CGRect(x: filterButtonLabel.frame.origin.x,
                                                      y: filterButtonLabel.frame.origin.y + filterButtonLabel.frame.height,
                                                      width: filterButtonLabel.frame.width,
                                                      height: CGFloat(filterOptions.count * 44)) // 44 is the typical row height for UITableViewCell
                
                filterOptionsTableView.isHidden = false
            } else {
                filterOptionsTableView.isHidden = true
            }
    }

    // Done button to pass selected users back to InfoViewController
    @IBAction func DoneButtonTapped(_ sender: Any) {
        selectedUsers = filteredUsers.filter { userSelected[$0.id] == true }
            print("Selected Users: \(selectedUsers)")  // Ensure selected users are populated
            performSegue(withIdentifier: "unwindToInfo", sender: selectedUsers)
    }

    // Prepare for the unwind segue to InfoViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToInfo" {
                if let destinationVC = segue.destination as? InfoTableViewController,
                   let selectedUsers = sender as? [CoequipUser] {
                    destinationVC.selectedUsers = selectedUsers
                }
            }    }
}
