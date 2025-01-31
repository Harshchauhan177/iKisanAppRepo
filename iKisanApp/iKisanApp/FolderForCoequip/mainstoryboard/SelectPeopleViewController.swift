import UIKit

class SelectPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var filterButtonLabel: UIButton!
    @IBOutlet weak var searchBarLabel: UISearchBar!
    @IBOutlet weak var ListTableViewCell: UITableView!
    @IBOutlet weak var filterLabel: UIButton!

    var filteredUsers: [CoEquipUser] = sampleUsers
    var userSelected: [UUID: Bool] = [:]
    var selectedUsers: [CoEquipUser] = []
    var allUsers: [CoEquipUser] = sampleUsers

    var filterOptionsTableView: UITableView!
    var isFilterOptionsVisible = false
    let filterOptions = ["Contact", "Under 1 KM", "Previous"]

    override func viewDidLoad() {
        super.viewDidLoad()
        ListTableViewCell.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        ListTableViewCell.delegate = self
        ListTableViewCell.dataSource = self
        searchBarLabel.delegate = self

        filterOptionsTableView = UITableView(frame: CGRect(x: filterButtonLabel.frame.origin.x, y: filterButtonLabel.frame.origin.y + filterButtonLabel.frame.height, width: filterButtonLabel.frame.width, height: 150))
            filterOptionsTableView.delegate = self
            filterOptionsTableView.dataSource = self
            filterOptionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
            filterOptionsTableView.isHidden = true
            self.view.addSubview(filterOptionsTableView)
            filteredUsers = allUsers
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filterOptionsTableView {
            return filterOptions.count
        }
        return filteredUsers.count
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == filterOptionsTableView {
            let selectedOption = filterOptions[indexPath.row]
            applyFilter(option: selectedOption)
            isFilterOptionsVisible.toggle()
            filterOptionsTableView.isHidden = !isFilterOptionsVisible
        } else {
            let user = filteredUsers[indexPath.row]
            userSelected[user.id] = !(userSelected[user.id] ?? false)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    func applyFilter(option: String) {
        switch option {
        case "Contact":
            filteredUsers = allUsers.filter { $0.name?.lowercased().contains("Contact") ?? false }
        case "Under 1 KM":
            filteredUsers = allUsers.filter { $0.name?.lowercased().contains("Under 1 KM") ?? false }
        case "Previous":
            filteredUsers = allUsers.filter { $0.name?.lowercased().contains("Previous") ?? false }
        default:
            filteredUsers = allUsers
        }
        ListTableViewCell.reloadData()
    }
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
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        isFilterOptionsVisible.toggle()

            if isFilterOptionsVisible {filterOptionsTableView.frame = CGRect(x: filterButtonLabel.frame.origin.x,y: filterButtonLabel.frame.origin.y + filterButtonLabel.frame.height,width: filterButtonLabel.frame.width,height: CGFloat(filterOptions.count * 44))
                filterOptionsTableView.isHidden = false
            } else {
                filterOptionsTableView.isHidden = true
            }
    }
    @IBAction func DoneButtonTapped(_ sender: Any) {
        selectedUsers = filteredUsers.filter { userSelected[$0.id] == true }
        let storyboard = UIStoryboard(name: "Main", bundle: nil) 
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
                destinationVC.selectedUsers = selectedUsers
                navigationController?.pushViewController(destinationVC, animated: true)
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToInfo" {
                if let destinationVC = segue.destination as? InfoTableViewController,
                   let selectedUsers = sender as? [CoEquipUser] {
                    destinationVC.selectedUsers = selectedUsers
                }
            }    }
}
