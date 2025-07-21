import UIKit

class CoequipViewController: UIViewController {
    
    @IBOutlet weak var CoequipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var CoequipTableView: UITableView!
    
    var dataController: DataController!
    var currentRequest: Request?
    private var myRequests: [Request] = []  // Cache for my requests
    private var joinRequests: [Request] = [] // Cache for join requests
    
    // Pull-to-refresh control
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        updateUI()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRequestDeletion(_:)),
            name: .requestDeleted,
            object: nil
        )
    }
    
    // Setup refresh control
    private func setupRefreshControl() {
 
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        CoequipTableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        print("Pull-to-refresh triggered in CoequipViewController")
        // Start refresh animation
        refreshControl.beginRefreshing()
        
        // Reload data asynchronously
        Task {
            await dataController.loadDataFromBackend()
            
            await MainActor.run {
                self.updateUI()
                self.refreshControl.endRefreshing()
                print("Refresh completed in CoequipViewController")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUser = dataController.getCurrentUser() else {
            print("No current user found")
            return
        }
        
        Task {
            await dataController.loadDataFromBackend()
            
            await MainActor.run {
                self.updateCachedRequests()
                self.updateUI()
                
                if let currentRequest = self.currentRequest {
                    let requests = self.CoequipSegmentedControl.selectedSegmentIndex == 0 ? self.myRequests : self.joinRequests
                    
                    if let index = requests.firstIndex(where: { $0.id == currentRequest.id }) {
                        let indexPath = IndexPath(row: index, section: 0)
                        if indexPath.row < self.CoequipTableView.numberOfRows(inSection: 0) {
                            self.CoequipTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func updateCachedRequests() {
        guard let currentUser = dataController.getCurrentUser() else { return }
        
        let allRequests = dataController.getAllCoEquipRequests()
        
        // Update my requests - sorted by creation date, newest first
        myRequests = allRequests
            .filter { request in
                request.userId == currentUser.userID &&
                request.typeOfRequest == .myRequest
            }
            .sorted { $0.requestedDate > $1.requestedDate }
        
        // Update join requests - sorted by creation date, newest first
        joinRequests = allRequests
            .filter { request in
                request.participants?.contains { participant in
                    participant.userId == currentUser.userID &&
                    participant.status == .pending
                } ?? false
            }
            .sorted { $0.requestedDate > $1.requestedDate }
    }

    @objc private func handleRequestUpdate(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    private func setupTableView() {
        CoequipTableView.register(UINib(nibName: "MyRequestTableViewCell", bundle: nil), 
                                forCellReuseIdentifier: "MyRequestTableViewCell")
        CoequipTableView.register(UINib(nibName: "AcceptRequestTableViewCell", bundle: nil), 
                                forCellReuseIdentifier: "AcceptRequestTableViewCell")
        
        CoequipTableView.delegate = self
        CoequipTableView.dataSource = self
        CoequipSegmentedControl.selectedSegmentIndex = 0
    }
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateCachedRequests()
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
            self.currentRequest = request
        } else if segue.identifier == "goToSearchViewController",
               let searchVC = segue.destination as? SearchViewController {
                searchVC.dataController = self.dataController
            }
    }

    private func updateUI() {
        updateCachedRequests()
        CoequipTableView.reloadData()
    }

    func loadInitialData() {
        guard let dataController = dataController else { return }
        updateCachedRequests()
        
        if let currentRequest = currentRequest {
            let requests = CoequipSegmentedControl.selectedSegmentIndex == 0 ? myRequests : joinRequests
            if !requests.contains(where: { $0.id == currentRequest.id }) {
                self.currentRequest = nil
            }
        }
        
        DispatchQueue.main.async {
            self.CoequipTableView.reloadData()
        }
    }

    func removeRequest(with id: UUID) {
        guard let dataController = dataController else { return }
        dataController.deleteRequest(with: id)
       
        if currentRequest?.id == id {
            currentRequest = nil
        }
        loadInitialData()
    }

    @objc private func handleRequestDeletion(_ notification: Notification) {
        if let requestId = notification.userInfo?["requestId"] as? UUID {
            if currentRequest?.id == requestId {
                currentRequest = nil
            }
            loadInitialData()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CoequipViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoequipSegmentedControl.selectedSegmentIndex == 0 ? myRequests.count : joinRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataController = self.dataController,
              let currentUser = dataController.getCurrentUser() else { return UITableViewCell() }
        
        let requests = CoequipSegmentedControl.selectedSegmentIndex == 0 ? myRequests : joinRequests
        
        // Safety check to prevent index out of range
        guard indexPath.row < requests.count else { return UITableViewCell() }
        
        let request = requests[indexPath.row]
        guard let equipment = dataController.getEquipment(byId: request.equipmentId) else {
            return UITableViewCell()
        }
        
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestTableViewCell", for: indexPath) as! MyRequestTableViewCell
            cell.configure(with: equipment, request: request)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptRequestTableViewCell", for: indexPath) as! AcceptRequestTableViewCell
            
            // Find the participant for the current user
            if let participant = request.participants?.first(where: { $0.userId == currentUser.userID }) {
                cell.configure(participant: participant, request: request, equipment: equipment)
            } else {
                let pendingParticipant = RequestParticipant(
                    id: UUID(),
                    requestId: request.id,
                    userId: currentUser.userID,
                    status: .pending,
                    area: nil,
                    timeSlot: nil,
                    joinedAt: Date()
                )
                cell.configure(participant: pendingParticipant, request: request, equipment: equipment)
            }
            cell.request = request
            cell.dataController = dataController
            cell.delegate = self
            return cell
        }
    }
    
    // Add didSelectRowAt to handle cell taps for navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let dataController = self.dataController,
              let currentUser = dataController.getCurrentUser() else { return }
        
        let requests = CoequipSegmentedControl.selectedSegmentIndex == 0 ? myRequests : joinRequests
        
        // Safety check to prevent index out of bounds
        guard indexPath.row < requests.count else { return }
        
        let request = requests[indexPath.row]
        
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            // My requests section - navigate to MyRequestViewController1
            performSegue(withIdentifier: "goToMyRequest1", sender: request)
        } else {
            // Join requests section - navigate to AcceptRequestTableViewController
            performSegue(withIdentifier: "goToAcceptRequest", sender: request)
        }
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
        // Remove navigation functionality - pending button no longer redirects
        // The button will remain visible for status display only
        print("Pending button tapped - no navigation action")
    }
    
    // Add the missing delegate method for cell tap
    func didTapCell(cell: MyRequestTableViewCell) {
        guard let indexPath = CoequipTableView.indexPath(for: cell),
              let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else { return }
        
        // Get the filtered requests that match the current user and type
        let requests = dataController.getAllCoEquipRequests().filter { request in
            request.userId == currentUser.userID &&
            request.typeOfRequest == .myRequest
        }
        
        // Safety check to prevent index out of bounds
        guard indexPath.row < requests.count else { return }
        
        let request = requests[indexPath.row]
        performSegue(withIdentifier: "goToMyRequest1", sender: request)
    }
}
//goToAcceptRequest
extension CoequipViewController: AcceptRequestTableViewCellDelegate {
    func acceptButtonTapped(in cell: AcceptRequestTableViewCell) {
        guard let indexPath = CoequipTableView.indexPath(for: cell),
              let dataController = dataController,
              let currentUser = dataController.getCurrentUser(),
              let request = cell.request else { return }
        
        // Get the current participant for this request
        if let participant = request.participants?.first(where: { $0.userId == currentUser.userID }) {
            // Update participant status
            var updatedParticipant = participant
            updatedParticipant.status = .accepted
            
            // Update the request with the new participant status
            var updatedRequest = request
            updatedRequest.status = .pending
            
            // Update in data controller
            dataController.updateRequest(updatedRequest)
            
            // Perform segue to accept request view
            performSegue(withIdentifier: "goToAcceptRequest", sender: updatedRequest)
        }
    }
    
    func rejectButtonTapped(in cell: AcceptRequestTableViewCell) {
        guard let request = cell.request else { return }
        
        let alertController = UIAlertController(
            title: "Delete Request",
            message: "Are you sure you want to delete this request?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Delete from Supabase
            Task {
                do {
                    try await SupabaseManager.shared.client
                        .from("requests")
                        .delete()
                        .eq("id", value: request.id)
                        .execute()
                    
                    // Update UI after successful deletion
                    await MainActor.run {
                        self.removeRequest(with: request.id)
                    }
                } catch {
                    // Show error alert
                    await MainActor.run {
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "Failed to delete request: \(error.localizedDescription)",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        })
        
        present(alertController, animated: true)
    }
}
