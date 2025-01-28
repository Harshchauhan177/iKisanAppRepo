
import UIKit

class CoequipViewController: UIViewController {
    var receivedRequestInfo: RequestInfo?
    var equipmentItems: [CoequipEquipment] = []
  var requests: [Request] = []
    var acceptedRequests: [Request] = []
    
    @IBOutlet weak var CoequipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var CoequipTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoequipTableView.dataSource = self
        CoequipTableView.delegate = self
        setupSampleData()
        CoequipTableView.register(UINib(nibName: "MyRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "MyRequestTableViewCell")
             CoequipTableView.register(UINib(nibName: "AcceptRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "AcceptRequestTableViewCell")
       
        setAllRequestsToPending()
    }
    func setAllRequestsToPending() {
            for i in 0..<requests.count {
                requests[i].status = .pending
            }
            CoequipTableView.reloadData()
        }
    func setupSampleData() {
        equipmentItems = [
                    CoequipEquipment(id: UUID(), name: "Rice Harvester", pricePerHour: 100.0, pricePerArea: 50.0, rating: 4.5, providerName: "Murshadpur Greater Noida U.P", providerLocation: CoequipLocation(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), imageURL: UIImage(named: "102")!, category: .tractor, availability: [], description: "Heavy-duty Harvester for farm work", reviews: []),
                    CoequipEquipment(id: UUID(), name: "Wheat Harvester", pricePerHour: 80.0, pricePerArea: 40.0, rating: 4.0, providerName: "Dankaur Greater Noida U.P", providerLocation: CoequipLocation(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), imageURL: UIImage(named: "103")!, category: .plow, availability: [], description: "Efficient plow for soil tilling", reviews: [])
                ]
                
                requests = [
                    Request(id: UUID(), equipmentId: equipmentItems[0].id, requestedBy: UUID(), status: .pending, requestedDate: Date(), requestedTimeSlot: "Morning", area: 10, location: "Delhi", providerId: UUID(), discountThreshold: 200, joinedFarmers: [], minimumAreaForDiscount: 50, paymentStatus: .pending, statusUpdatedDate: nil, notes: nil),
                    Request(id: UUID(), equipmentId: equipmentItems[1].id, requestedBy: UUID(), status: .confirmed, requestedDate: Date(), requestedTimeSlot: "Afternoon", area: 20, location: "Delhi", providerId: UUID(), discountThreshold: 150, joinedFarmers: [], minimumAreaForDiscount: 30, paymentStatus: .completed, statusUpdatedDate: nil, notes: nil)
                ]
                
                acceptedRequests = [
                    requests[0],
                    requests[1]
                ]
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        CoequipTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToAcceptRequest" {
                if let destinationVC = segue.destination as? AcceptRequestTableViewController {
                    if let indexPath = CoequipTableView.indexPathForSelectedRow {
                        let request = acceptedRequests[indexPath.row]
                        destinationVC.request = request
                    }
                }
            } else if segue.identifier == "goToMyRequest" {
                if let destinationVC = segue.destination as? MyRequestViewController {
                    if let indexPath = CoequipTableView.indexPathForSelectedRow {
                        let request = requests[indexPath.row]
                        destinationVC.request = request
                    }
                }
            }
        }
}


extension CoequipViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            return requests.count
        } else {
            return acceptedRequests.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if CoequipSegmentedControl.selectedSegmentIndex == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestTableViewCell", for: indexPath) as? MyRequestTableViewCell {
                let request = requests[indexPath.row]
                guard let equipment = equipmentItems.first(where: { $0.id == request.equipmentId }) else {
                    print("Error: Equipment not found for request.")
                    return UITableViewCell()
                }
                cell.EquipmentImageLabel.image = equipment.imageURL
                cell.EquipmentImageLabel.layer.cornerRadius = 7
                cell.EquipmentTitleLabel.text = equipment.name
                cell.LocationLabel.text = equipment.providerName
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM"
                cell.DateLabel.text = dateFormatter.string(from: request.requestedDate)
                cell.PendingButtonTapped.isHidden = (request.status != .pending)
                cell.delegate = self

                return cell
            } else {
                print("Error: Failed to dequeue MyRequestTableViewCell.")
                return UITableViewCell()
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AcceptRequestTableViewCell", for: indexPath) as? AcceptRequestTableViewCell {
                let request = acceptedRequests[indexPath.row]
                guard let equipment = equipmentItems.first(where: { $0.id == request.equipmentId }) else {
                    print("Error: Equipment not found for accepted request.")
                    return UITableViewCell()
                }
                cell.EquipmentIimageLabel.image = equipment.imageURL
                cell.EquipmentIimageLabel.layer.cornerRadius = 7
                cell.EquipmentTitleLabel.text = equipment.name
                cell.LocationLabel.text = equipment.providerName
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM"
                cell.DateLabel.text = dateFormatter.string(from: request.requestedDate)
                cell.delegate = self

                return cell
            } else {
                print("Error: Failed to dequeue AcceptRequestTableViewCell.")
                return UITableViewCell()
            }
        }
    }
}

extension CoequipViewController: MyRequestTableViewCellDelegate {
    func didTapConfirmButton(cell: MyRequestTableViewCell) {
        if let indexPath = CoequipTableView.indexPath(for: cell) {
            let request = requests[indexPath.row]
            print("Confirmed request: \(request.id)")
            requests[indexPath.row].status = .confirmed
            CoequipTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func didTapPendingButton(cell: MyRequestTableViewCell) {
        if let indexPath = CoequipTableView.indexPath(for: cell) {
            let request = requests[indexPath.row]
            requests[indexPath.row].status = .pending
            performSegue(withIdentifier: "goToMyRequest", sender: self)
        }
    }
}

extension CoequipViewController: AcceptRequestTableViewCellDelegate {
    func acceptButtonTapped(in cell: AcceptRequestTableViewCell) {
        if let indexPath = CoequipTableView.indexPath(for: cell) {
            let request = acceptedRequests[indexPath.row]
           // selectedRequestIndexPath = indexPath
            performSegue(withIdentifier: "goToAcceptRequest", sender: self)
        }
    }
    
    func rejectButtonTapped(in cell: AcceptRequestTableViewCell) {
        if let indexPath = CoequipTableView.indexPath(for: cell) {
                    let request = acceptedRequests[indexPath.row]
                    
                    // Show confirmation alert
                    let alertController = UIAlertController(title: "Reject Request", message: "Are you sure you want to reject this request?", preferredStyle: .alert)
                    
                    // Add Cancel action
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    // Add Done action
                    let doneAction = UIAlertAction(title: "Done", style: .destructive) { _ in
                        // On confirmation, remove the request from acceptedRequests
                        self.acceptedRequests.remove(at: indexPath.row)
                        
                        // Reload the table view to reflect the changes
                        self.CoequipTableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    alertController.addAction(doneAction)
                    
                    // Present the alert
                    self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
}
