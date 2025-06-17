import UIKit

class MyRequestViewController1: UIViewController {

    var request: Request?
    var dataController: DataController?
    
    @IBOutlet weak var firstViewLabel: UIView!
    @IBOutlet weak var equipmentImageLabel: UIImageView!
    @IBOutlet weak var equipmentTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewButtonLabel: UIButton!
    @IBOutlet weak var secondViewLabel: UIView!
    @IBOutlet weak var minimumAreaLabel: UILabel!
    @IBOutlet weak var currentAreaLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var modifyRequestLabel: UIButton!
    @IBOutlet weak var deleteRequestLabel: UIButton!
    
    
    // Keep track of both UUIDs and Users
    private var selectedUserIds: [UUID] = []
    private var acceptedRequestPeopleList: [User] = []
    
    // Add property to store user areas and time slots
    private var userAreas: [UUID: Double] = [:]
    private var userTimeSlots: [UUID: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad started")
        print("Request details: \(String(describing: request))")
        
        // Setup table view and register nib
        setupTableView()
        
        if let request = request,
           let equipment = dataController?.getEquipmentById(request.equipmentId) {
            // Setup equipment details
            if equipment.equipmentImage.hasPrefix("http") {
                equipmentImageLabel.loadImage(from: equipment.equipmentImage)
            } else {
                equipmentImageLabel.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
            equipmentTitleLabel.text = equipment.name
            hostNameLabel.text = equipment.providerName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            let dateString = dateFormatter.string(from: request.requestedDate)
            dateLabel.text = "\(dateString)"
            let totalPrice = equipment.pricePerAcre 
            priceLabel.text = "₹ \(Int(totalPrice))\nDate: \(dateString)"
            
            // Clear and populate accepted users list
            acceptedRequestPeopleList.removeAll()
            
            // Calculate total area from participants
            var totalArea: Double = 0
            if let participants = request.participants {
                for participant in participants {
                    if let area = participant.area {
                        totalArea += area
                    }
                }
            }
            
            // Update current area label
            currentAreaLabel.text = String(format: "%.2f acres", totalArea)
            
            // Get accepted users from the request
            if let acceptedUserIds = request.acceptedUsers {
                print("Processing accepted users: \(acceptedUserIds)")
                
                for userId in acceptedUserIds {
                    print("Looking up user with ID: \(userId)")
                    if let user = dataController?.getUserById(userId) {
                        print("Found user: \(user.name)")
                        acceptedRequestPeopleList.append(user)
                        
                        // Store user's area and time slot
                        if let participant = request.participants?.first(where: { $0.userId == userId }) {
                            if let area = participant.area {
                                userAreas[userId] = area
                            }
                            if let timeSlot = participant.timeSlot {
                                userTimeSlots[userId] = timeSlot
                            }
                        }
                    }
                }
                
                print("Total accepted users found: \(acceptedRequestPeopleList.count)")
            }
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.listTableView.reloadData()
            }
        } else {
            print("Failed to load request or equipment data")
        }
        
        setupViewAppearance()
    }
    
    private func setupTableView() {
        print("Setting up table view")
        
        // Ensure table view outlet is connected
        guard listTableView != nil else {
            print("Error: listTableView outlet is not connected!")
            return
        }
        
        // Register the nib file
        let nibName = "MyRequestInfoTableViewCell"
        let nib = UINib(nibName: nibName, bundle: nil)
        
        // Verify nib loaded successfully
        guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
            print("Error: Could not find \(nibName).nib file!")
            return
        }
        
        listTableView.register(nib, forCellReuseIdentifier: "cell")
        listTableView.delegate = self
        listTableView.dataSource = self
        
        print("Table view setup completed")
    }
    
    private func setupViewAppearance() {
        firstViewLabel.layer.cornerRadius = 7
        secondViewLabel.layer.cornerRadius = 7
        equipmentImageLabel.layer.cornerRadius = 7
        deleteRequestLabel.layer.cornerRadius = 7
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Request", 
                                              message: "Are you sure you want to delete this request?", 
                                              preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteRequest()
        }
        alertController.addAction(deleteAction)
        present(alertController, animated: true)
    }
    
    private func deleteRequest() {
        if let requestToDelete = request,
           let dataController = dataController {
            dataController.deleteRequest(with: requestToDelete.id)
            if let navigationController = self.navigationController,
               let coequipVC = navigationController.viewControllers.first(where: { $0 is CoequipViewController }) as? CoequipViewController {
                coequipVC.loadInitialData()
            }
            let successAlert = UIAlertController(
                title: "Success", 
                message: "Request deleted successfully", 
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(successAlert, animated: true)
        }
    }
    
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        guard let request = request,
              let equipment = dataController?.getEquipmentById(request.equipmentId) else {
            showAlert(message: "Equipment data not available")
            return
        }
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let equipmentDescVC = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            equipmentDescVC.equipment = equipment
            equipmentDescVC.bookingSource = .coEquip
            equipmentDescVC.selectedDate = request.requestedDate
            navigationController?.pushViewController(equipmentDescVC, animated: true)
        }
    }
    

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Alert",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func configure(with request: Request) {
        self.request = request
    }
}

extension MyRequestViewController1: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = acceptedRequestPeopleList.count
        print("Number of rows in table: \(count)")
        return acceptedRequestPeopleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyRequestInfoTableViewCell
        let user = acceptedRequestPeopleList[indexPath.row]
        print("Configuring cell for user: \(user.name)")
        
        // Get user's area and time slot if available
        let area = userAreas[user.userID]
        let timeSlot = userTimeSlots[user.userID]
        
        cell.configure(with: user, area: area, timeSlot: timeSlot)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}
