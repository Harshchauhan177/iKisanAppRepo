import UIKit

class CoequipViewController: UIViewController {
    
    @IBOutlet weak var CoequipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var CoequipTableView: UITableView!
    
    var dataController: DataController? {
        didSet {
            if isViewLoaded {
                // Fetch initial data
                loadInitialData()
                CoequipTableView?.reloadData()
            }
        }
    }
    
    var currentRequest: Request? // Define a property for the current request
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateUI() // Call to update UI when the view loads
        
        // Add observer for request deletion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRequestDeletion(_:)),
            name: .requestDeleted,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📱 CoequipViewController will appear")
        
        // Load data and update UI
        loadInitialData()
        updateUI()
        
        // If we have a current request, scroll to it
        if let currentRequest = currentRequest,
           let dataController = dataController {
            let requests = dataController.getAllCoEquipRequests()
            if let index = requests.firstIndex(where: { $0.id == currentRequest.id }) {
                let indexPath = IndexPath(row: index, section: 0)
                CoequipTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
    
    private func setupTableView() {
        // Register cells from nibs
        CoequipTableView.register(UINib(nibName: "MyRequestTableViewCell", bundle: nil), 
                                forCellReuseIdentifier: "MyRequestTableViewCell")
        CoequipTableView.register(UINib(nibName: "AcceptRequestTableViewCell", bundle: nil), 
                                forCellReuseIdentifier: "AcceptRequestTableViewCell")
        
        CoequipTableView.delegate = self
        CoequipTableView.dataSource = self
        
        CoequipSegmentedControl.selectedSegmentIndex = 0
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        CoequipTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAcceptRequest",
           let destinationVC = segue.destination as? AcceptRequestTableViewController,
           let request = sender as? Request {
            destinationVC.request = request
            destinationVC.dataController = dataController
        } else if segue.identifier == "goToMyRequest1",
                  let destinationVC = segue.destination as? MyRequestViewController1,
                  let request = sender as? Request {
            destinationVC.request = request
            destinationVC.dataController = dataController
            self.currentRequest = request // Set the current request
        } else if segue.identifier == "goToSearchViewController", // Replace with actual segue ID
               let searchVC = segue.destination as? SearchViewController {
                searchVC.dataController = self.dataController
            }
    }

    func someFunction() {
        // Use the currentRequest property
        if let request = currentRequest {
            if let equipment = dataController?.getEquipmentById(request.equipmentId) {
                // Now you can safely use equipment
                print("Equipment name: \(equipment.name)")
                // Continue with your logic...
            } else {
                print("Equipment not found for ID: \(request.equipmentId)")
            }
        }
    }

     func loadInitialData() {
        guard let dataController = dataController else {
            print("⚠️ DataController is nil in CoequipViewController")
            return
        }
        
        print("📱 Loading initial data for CoequipViewController")
        let requests = dataController.getAllCoEquipRequests()
        print("📊 Found \(requests.count) requests")
        
        // If there's a current request, check if it still exists
        if let currentRequest = currentRequest {
            print("🔍 Current request: \(currentRequest.id)")
            
            // If the current request was deleted, clear it
            if !requests.contains(where: { $0.id == currentRequest.id }) {
                print("❌ Current request no longer exists")
                self.currentRequest = nil
            }
        }
        
        DispatchQueue.main.async {
            self.CoequipTableView.reloadData()
        }
    }

    private func updateUI() {
        print("🔄 Updating UI")
        if let request = currentRequest {
            print("📝 Current request ID: \(request.id)")
            if let equipment = dataController?.getEquipmentById(request.equipmentId) {
                print("🔍 Found equipment: \(equipment.name)")
                print("⏰ Time Slot: \(request.timeSlot.rawValue)")
                print("⏱️ Time Period: \(request.timePeriod ?? "nil")")
            }
        }
        CoequipTableView.reloadData()
    }

    // Add method to remove specific request
    func removeRequest(with id: UUID) {
        guard let dataController = dataController else { return }
        
        // Remove from data controller
        dataController.deleteRequest(with: id)
        
        // Clear current request if it was the one deleted
        if currentRequest?.id == id {
            currentRequest = nil
        }
        
        // Reload table view
        loadInitialData()
    }

    @objc private func handleRequestDeletion(_ notification: Notification) {
        if let requestId = notification.userInfo?["requestId"] as? UUID {
            print("📢 Received deletion notification for request: \(requestId)")
            
            // Clear current request if it was deleted
            if currentRequest?.id == requestId {
                currentRequest = nil
            }
            
            // Reload data
            loadInitialData()
        }
    }

    deinit {
        // Remove observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
}

extension CoequipViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataController = dataController else {
            print("⚠️ DataController is nil when getting number of rows")
            return 0
        }
        
        // Get requests based on selected segment
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            let requests = dataController.getAllCoEquipRequests()
            print("📊 Number of co-equip requests: \(requests.count)")
            return requests.count
        } else {
            let requests = dataController.getAcceptedRequests()
            print("📊 Number of accepted requests: \(requests.count)")
            return requests.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataController = dataController else {
            print("⚠️ DataController is nil when configuring cell")
            return UITableViewCell()
        }
        
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestTableViewCell", for: indexPath) as? MyRequestTableViewCell else {
                return UITableViewCell()
            }
            
            let requests = dataController.getAllCoEquipRequests()
            let request = requests[indexPath.row]
            
            if let equipment = dataController.getEquipmentById(request.equipmentId) {
                cell.configure(with: equipment, request: request)
                cell.delegate = self
                print("✅ Configured cell with request ID: \(request.id)")
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptRequestTableViewCell", for: indexPath) as? AcceptRequestTableViewCell else {
                return UITableViewCell()
            }
            
            let acceptedRequests = dataController.getAcceptedRequests()
            let request = acceptedRequests[indexPath.row]
            
            // Get equipment data and configure cell
            if let equipment = dataController.getEquipmentById(request.equipmentId) {
                cell.configure(with: request, equipment: equipment)
                cell.delegate = self
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataController = dataController else { return }
        
        let requests = CoequipSegmentedControl.selectedSegmentIndex == 0 ? 
            dataController.getAllCoEquipRequests() : 
            dataController.getAcceptedRequests()
        
        let request = requests[indexPath.row]
        
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "goToMyRequest1", sender: request)
        } else {
            performSegue(withIdentifier: "goToAcceptRequest", sender: request)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CoequipViewController: MyRequestTableViewCellDelegate {
    func didTapConfirmButton(cell: MyRequestTableViewCell) {
        guard let indexPath = CoequipTableView.indexPath(for: cell),
              let dataController = dataController else { return }
        
        var request = dataController.getAllCoEquipRequests()[indexPath.row]
        request.status = .confirmed
        dataController.updateRequest(request)
        
        CoequipTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func didTapPendingButton(cell: MyRequestTableViewCell) {
        guard let indexPath = CoequipTableView.indexPath(for: cell),
              let dataController = dataController else { return }
        
        var request = dataController.getAllCoEquipRequests()[indexPath.row]
        request.status = .pending
        dataController.updateRequest(request)
        
        performSegue(withIdentifier: "goToMyRequest1", sender: request)
    }
}

extension CoequipViewController: AcceptRequestTableViewCellDelegate {
    func acceptButtonTapped(in cell: AcceptRequestTableViewCell) {
        guard let indexPath = CoequipTableView.indexPath(for: cell),
              let dataController = dataController else { return }
        
        let request = dataController.getAcceptedRequests()[indexPath.row]
        performSegue(withIdentifier: "goToAcceptRequest", sender: request)
    }
    
    func rejectButtonTapped(in cell: AcceptRequestTableViewCell) {
        guard let indexPath = CoequipTableView.indexPath(for: cell),
              let dataController = dataController else { return }
        
        let alertController = UIAlertController(
            title: "Reject Request", 
            message: "Are you sure you want to reject this request?", 
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Reject", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let request = dataController.getAcceptedRequests()[indexPath.row]
            dataController.deleteRequest(with: request.id)
            self.CoequipTableView.deleteRows(at: [indexPath], with: .automatic)
        })
        
        present(alertController, animated: true)
    }
}
