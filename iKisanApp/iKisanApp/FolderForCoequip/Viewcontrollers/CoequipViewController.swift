import UIKit

class CoequipViewController: UIViewController {
    
    @IBOutlet weak var CoequipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var CoequipTableView: UITableView!
    
    var dataController: DataController!
    var currentRequest: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateUI()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRequestDeletion(_:)),
            name: .requestDeleted,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUser = dataController.getCurrentUser() else {
            print("No current user found")
            return
        }
        
        Task {
            do {
                // Make sure to load both requests and participants
                await dataController.loadDataFromBackend()
                print("Debug: Loaded data from backend")
                
                await MainActor.run {
                    self.updateUI()
                    print("Debug: Updated UI after loading data")
                }
            } catch {
                print("Debug: Error loading data: \(error)")
            }
        }
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


     func loadInitialData() {
        guard let dataController = dataController else {
            return
        }
        let requests = dataController.getAllCoEquipRequests()
        if let currentRequest = currentRequest {
            if !requests.contains(where: { $0.id == currentRequest.id }) {
                self.currentRequest = nil
            }
        }
        DispatchQueue.main.async {
            self.CoequipTableView.reloadData()
        }
    }

    private func updateUI() {
        CoequipTableView.reloadData()
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
        guard let dataController = self.dataController,
              let currentUser = dataController.getCurrentUser() else { return 0 }
        
        let requests = dataController.getAllCoEquipRequests()
        print("Debug: Total requests: \(requests.count)")
        
        let filteredRequests = requests.filter { request in
            if CoequipSegmentedControl.selectedSegmentIndex == 0 {
                // My Requests tab
                let isMyRequest = request.userId == currentUser.userID &&
                                request.typeOfRequest == .myRequest
                print("Debug: Found my request: \(isMyRequest)")
                return isMyRequest
            } else {
                // Join Requests tab - show requests where current user is a pending participant
                if let participants = request.participants {
                    print("Debug: Request \(request.id) has \(participants.count) participants")
                    let isParticipant = participants.contains { participant in
                        let matches = participant.userId == currentUser.userID &&
                                    participant.status == .pending // Use enum case directly
                        print("Debug: Participant matches - userID: \(participant.userId == currentUser.userID), status: \(participant.status == .pending)")
                        return matches
                    }
                    print("Debug: Is participant request: \(isParticipant)")
                    return isParticipant
                }
                print("Debug: Request has no participants")
                return false
            }
        }
        
        print("Debug: Filtered requests count: \(filteredRequests.count)")
        return filteredRequests.count
    }
    
    // Update the cellForRowAt with the same filtering logic
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataController = self.dataController,
              let currentUser = dataController.getCurrentUser() else { return UITableViewCell() }
        
        let requests = dataController.getAllCoEquipRequests()
        let filteredRequests = requests.filter { request in
            if CoequipSegmentedControl.selectedSegmentIndex == 0 {
                return request.userId == currentUser.userID &&
                       request.typeOfRequest == .myRequest
            } else {
                return request.participants?.contains { participant in
                    participant.userId == currentUser.userID &&
                    participant.status.rawValue == "pending" // Compare with string value
                } ?? false
            }
        }
        
        // Safety check to prevent index out of range
        guard indexPath.row < filteredRequests.count else { return UITableViewCell() }
        
        let request = filteredRequests[indexPath.row]
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
            guard let participant = request.participants?.first(where: { $0.userId == currentUser.userID }) else {
                // Handle case where participant is not found (e.g., return an empty cell or log an error)
                return UITableViewCell()
            }
            
            // Pass the request, the specific participant, and the equipment to the configure function
            cell.configure(participant: participant, request: request, equipment: equipment )
            cell.request = request
            cell.dataController = dataController
            cell.delegate = self
            return cell
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
        
        var request = requests[indexPath.row]
        request.status = .pending
        dataController.updateRequest(request)
        performSegue(withIdentifier: "goToMyRequest1", sender: request)
    }
}
//goToAcceptRequest
extension CoequipViewController: AcceptRequestTableViewCellDelegate {
    func acceptButtonTapped(in cell: AcceptRequestTableViewCell) {
        guard let indexPath = CoequipTableView.indexPath(for: cell),
              let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else { return }
        
        let requests = dataController.getAllCoEquipRequests().filter { request in
            request.participants?.contains { participant in
                participant.userId == currentUser.userID
            } ?? false
        }
        
        guard indexPath.row < requests.count else { return }
        
        var request = requests[indexPath.row]
        
        // Update the participant status in Supabase
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("request_participants")
                    .update([
                        "status": ParticipantStatus.accepted.rawValue // Fixed: Use rawValue
                    ])
                    .eq("requestId", value: request.id)
                    .eq("userId", value: currentUser.userID)
                    .execute()
                
                // Update local state and UI
                await MainActor.run {
                    request.status = .pending
                    dataController.updateRequest(request)
                    performSegue(withIdentifier: "goToAcceptRequest", sender: request)
                }
            } catch {
                await MainActor.run {
                    let errorAlert = UIAlertController(
                        title: "Error",
                        message: "Failed to accept request: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
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
            guard let self = self,
                  let currentUser = self.dataController.getCurrentUser() else { return }
            
            // Delete from Supabase request_participants table
            Task {
                do {
                    try await SupabaseManager.shared.client
                        .from("request_participants")
                        .delete()
                        .eq("requestId", value: request.id)
                        .eq("userId", value: currentUser.userID)
                        .execute()
                    
                    // Update UI after successful deletion
                    await MainActor.run {
                        self.removeRequest(with: request.id)
                    }
                } catch {
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
