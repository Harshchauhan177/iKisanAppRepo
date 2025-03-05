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
       
        loadInitialData()
        updateUI()
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
        guard let dataController = dataController else {
            return 0
        }
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            let requests = dataController.getAllCoEquipRequests()
            return requests.count
        } else {
            let requests = dataController.getAcceptedRequests()
            return requests.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataController = dataController else {
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
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptRequestTableViewCell", for: indexPath) as? AcceptRequestTableViewCell else {
                return UITableViewCell()
            }
            let acceptedRequests = dataController.getAcceptedRequests()
            let request = acceptedRequests[indexPath.row]
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
