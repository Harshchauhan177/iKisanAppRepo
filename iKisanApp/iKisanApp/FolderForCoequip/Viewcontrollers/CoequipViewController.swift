import UIKit

class CoequipViewController: UIViewController {
    
    @IBOutlet weak var CoequipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var CoequipTableView: UITableView!
    
    var dataController: DataController!
    var currentRequest: Request?
    
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
                self.updateUI()
                if let currentRequest = self.currentRequest {
                    // Get the filtered requests that match the current user and type
                    let requests = self.dataController.getAllCoEquipRequests().filter { request in
                        request.userId == currentUser.userID &&
                        request.typeOfRequest == (self.CoequipSegmentedControl.selectedSegmentIndex == 0 ? .myRequest : .acceptedRequest)
                    }
                    
                    if let index = requests.firstIndex(where: { $0.id == currentRequest.id }) {
                        let indexPath = IndexPath(row: index, section: 0)
                        // Add safety check before scrolling
                        if indexPath.row < self.CoequipTableView.numberOfRows(inSection: 0) {
                            self.CoequipTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        }
                    }
                }
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
        guard let dataController = self.dataController else { return 0 }
        
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            return dataController.getAllCoEquipRequests().filter { 
                $0.userId == dataController.getCurrentUser()?.userID && 
                $0.typeOfRequest == .myRequest 
            }.count
        } else {
            return dataController.getAllCoEquipRequests().filter {
                $0.userId == dataController.getCurrentUser()?.userID &&
                $0.typeOfRequest == .acceptedRequest
            }.count
        }
    }
    
    // Add this method to safely scroll to a row
    private func scrollToRequest(_ request: Request) {
        guard let dataController = self.dataController else { return }
        
        let requests = dataController.getAllCoEquipRequests().filter { 
            $0.userId == dataController.getCurrentUser()?.userID && 
            $0.typeOfRequest == (CoequipSegmentedControl.selectedSegmentIndex == 0 ? .myRequest : .acceptedRequest)
        }
        
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            if indexPath.row < CoequipTableView.numberOfRows(inSection: 0) {
                CoequipTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataController = self.dataController,
              let currentUser = dataController.getCurrentUser() else { return UITableViewCell() }
        
        let requests = dataController.getAllCoEquipRequests().filter { request in
            request.userId == currentUser.userID &&
            request.typeOfRequest == (CoequipSegmentedControl.selectedSegmentIndex == 0 ? .myRequest : .acceptedRequest)
        }
        
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
            cell.configure(with: request, equipment: equipment)
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
            request.userId == currentUser.userID &&
            request.typeOfRequest == .acceptedRequest
        }
        
        guard indexPath.row < requests.count else { return }
        
        var request = requests[indexPath.row]
        request.status = .pending
        dataController.updateRequest(request)
        performSegue(withIdentifier: "goToAcceptRequest", sender: request)
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
