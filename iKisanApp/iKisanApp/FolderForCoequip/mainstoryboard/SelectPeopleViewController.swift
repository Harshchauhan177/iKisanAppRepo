import UIKit

class SelectPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var filterButtonLabel: UIButton!
    @IBOutlet weak var searchBarLabel: UISearchBar!
    @IBOutlet weak var ListTableViewCell: UITableView!
    @IBOutlet weak var filterLabel: UIButton!

    var filteredUsers: [User] = sampleUsers
    var userSelected: [UUID: Bool] = [:]
    var selectedUsers: [User] = []
    var allUsers: [User] = sampleUsers

    var filterOptionsTableView: UITableView!
    var isFilterOptionsVisible = false
    let filterOptions = ["Contact", "Under 1 KM", "Previous"]

    override func viewDidLoad() {
        super.viewDidLoad()
        ListTableViewCell.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        ListTableViewCell.delegate = self
        ListTableViewCell.dataSource = self
        searchBarLabel.delegate = self

        // Setup filter options table view with dropdown style
        filterOptionsTableView = UITableView(frame: .zero, style: .plain)
        filterOptionsTableView.delegate = self
        filterOptionsTableView.dataSource = self
        filterOptionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        filterOptionsTableView.isHidden = true
        filterOptionsTableView.layer.borderWidth = 0.5
        filterOptionsTableView.layer.borderColor = UIColor.lightGray.cgColor
        filterOptionsTableView.layer.cornerRadius = 8
        filterOptionsTableView.layer.shadowColor = UIColor.black.cgColor
        filterOptionsTableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        filterOptionsTableView.layer.shadowRadius = 4
        filterOptionsTableView.layer.shadowOpacity = 0.2
        filterOptionsTableView.backgroundColor = .white
        filterOptionsTableView.separatorInset = .zero
        filterOptionsTableView.rowHeight = 40
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
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = .darkGray
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            
            // Add padding using layout margins
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            
            // Add selection style
            cell.selectionStyle = .gray
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = user.name
        cell.accessoryType = userSelected[user.userID] ?? false ? .checkmark : .none
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
            // Toggle selection
            if userSelected[user.userID] == true {
                userSelected[user.userID] = false
                // Remove from selectedUsers array if exists
                selectedUsers.removeAll { $0.userID == user.userID}
            } else {
                userSelected[user.userID] = true
                // Add to selectedUsers array
                selectedUsers.append(user)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            print("Selected users count: \(selectedUsers.count)")
        }
    }
    func applyFilter(option: String) {
        switch option {
        case "Contact":
            filteredUsers = allUsers.filter { $0.name.lowercased().contains("Contact") }
        case "Under 1 KM":
            filteredUsers = allUsers.filter { $0.name.lowercased().contains("Under 1 KM") }
        case "Previous":
            filteredUsers = allUsers.filter { $0.name.lowercased().contains("Previous") }
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
                user.name.lowercased().contains(searchText.lowercased()) 
            }
        }
        ListTableViewCell.reloadData()
    }
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        isFilterOptionsVisible.toggle()

        if isFilterOptionsVisible {
            // Position dropdown relative to filter button
            let dropdownWidth: CGFloat = 150 // Fixed width for dropdown
            let dropdownHeight = CGFloat(filterOptions.count * 40)
            
            // Center the dropdown under the button
            let xPosition = filterButtonLabel.frame.minX + (filterButtonLabel.frame.width - dropdownWidth) / 2
            
            filterOptionsTableView.frame = CGRect(
                x: xPosition,
                y: filterButtonLabel.frame.maxY + 5,
                width: dropdownWidth,
                height: dropdownHeight
            )
            
            // Animate the appearance
            filterOptionsTableView.alpha = 0
            filterOptionsTableView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.filterOptionsTableView.alpha = 1
            }
        } else {
            // Animate the disappearance
            UIView.animate(withDuration: 0.3) {
                self.filterOptionsTableView.alpha = 0
            } completion: { _ in
                self.filterOptionsTableView.isHidden = true
            }
        }
    }
    @IBAction func DoneButtonTapped(_ sender: Any) {
        // No need to filter again since we're maintaining the selectedUsers array
        print("Final selected users count: \(selectedUsers.count)")
        performSegue(withIdentifier: "unwindToInfoTable", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToInfoTable" {
            if let destinationVC = segue.destination as? InfoTableViewController {
                print("Preparing for unwind segue with \(selectedUsers.count) users")
                destinationVC.selectedUsers = selectedUsers
            }
        }
    }

    // Add method to handle tapping outside the dropdown to dismiss it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !filterOptionsTableView.frame.contains(location) && !filterButtonLabel.frame.contains(location) {
                if isFilterOptionsVisible {
                    filterButtonTapped(filterButtonLabel)
                }
            }
        }
    }
}
