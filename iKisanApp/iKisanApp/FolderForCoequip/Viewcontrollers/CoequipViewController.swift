
import UIKit

class CoequipViewController: UIViewController {
    
    var equipmentItems: [Equipment] = []
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
    }
    
    func setupSampleData() {
        equipmentItems = [
            Equipment(id: UUID(), name: "Tractor A", pricePerHour: 100.0, pricePerArea: 50.0, rating: 4.5, providerName: "John Doe", providerLocation: Location(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), imageURL: UIImage(named: "102")!, category: .tractor, availability: [], description: "Heavy-duty tractor for farm work", reviews: []),
            Equipment(id: UUID(), name: "Plow B", pricePerHour: 80.0, pricePerArea: 40.0, rating: 4.0, providerName: "Jane Smith", providerLocation: Location(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), imageURL: UIImage(named: "103")!, category: .plow, availability: [], description: "Efficient plow for soil tilling", reviews: [])
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
                cell.EquipmentTitleLabel.text = equipment.name
                cell.LocationLabel.text = equipment.providerName
                //cell.DateLabel.text = " \(request.requestedDate)"
                let dateFormatter = DateFormatter()
                                dateFormatter.dateStyle = .short
                                cell.DateLabel.text = dateFormatter.string(from: request.requestedDate)
                                
                cell.PendingButtonTapped.isHidden = (request.status != .pending)
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
                cell.EquipmentTitleLabel.text = equipment.name
                cell.LocationLabel.text = equipment.providerName
                //cell.DateLabel.text = "\(request.requestedDate)"
                let dateFormatter = DateFormatter()
                                dateFormatter.dateStyle = .short
                                cell.DateLabel.text = dateFormatter.string(from: request.requestedDate)
                cell.PriceLabel.text = "₹\(request.area * equipment.pricePerArea)"
                cell.CreatorLabel.image = equipment.imageURL
                return cell
            } else {
                print("Error: Failed to dequeue AcceptRequestTableViewCell.")
                return UITableViewCell()
            }
        }
    }
}
    
