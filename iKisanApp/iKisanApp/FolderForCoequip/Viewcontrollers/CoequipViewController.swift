

import UIKit

class CoequipViewController: UIViewController  {
    
    var equipmentItems: [Equipment] = []
    var requests: [Request] = []
    @IBOutlet weak var CoequipSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var CoequipTableView: UITableView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        CoequipTableView.dataSource = self
               CoequipTableView.delegate = self
               setupSampleData()
               CoequipTableView.register(CoequipTableViewCell.self, forCellReuseIdentifier: "cell")
        }
    func setupSampleData() {
            equipmentItems = [
                Equipment(id: UUID(), name: "Tractor A", pricePerHour: 100.0, pricePerArea: 50.0, rating: 4.5, providerName: "John Doe", providerLocation: Location(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), imageURL: [URL(string: "https://via.placeholder.com/150")!], category: .tractor, availability: [], description: "Heavy-duty tractor for farm work", reviews: []),
                Equipment(id: UUID(), name: "Plow B", pricePerHour: 80.0, pricePerArea: 40.0, rating: 4.0, providerName: "Jane Smith", providerLocation: Location(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), imageURL: [URL(string: "https://via.placeholder.com/150")!], category: .plow, availability: [], description: "Efficient plow for soil tilling", reviews: [])
            ]
            
            requests = [
                Request(id: UUID(), equipmentId: equipmentItems[0].id, requestedBy: UUID(), status: .pending, requestedDate: Date(), requestedTimeSlot: "Morning", area: 10, location: Location(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), providerId: UUID(), discountThreshold: 200, joinedFarmers: [], minimumAreaForDiscount: 50, paymentStatus: .pending, statusUpdatedDate: nil, notes: nil),
                Request(id: UUID(), equipmentId: equipmentItems[1].id, requestedBy: UUID(), status: .confirmed, requestedDate: Date(), requestedTimeSlot: "Afternoon", area: 20, location: Location(latitude: 28.7041, longitude: 77.1025, area: "Delhi"), providerId: UUID(), discountThreshold: 150, joinedFarmers: [], minimumAreaForDiscount: 30, paymentStatus: .completed, statusUpdatedDate: nil, notes: nil)
            ]
        }
        
    }

extension CoequipViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CoequipTableViewCell {
                   let request = requests[indexPath.row]
                   guard let equipment = equipmentItems.first(where: { $0.id == request.equipmentId }) else {
                       print("Error: Equipment not found for request.")
                       return UITableViewCell()
                   }
                   cell.EquipmentNameLabel.text = equipment.name ?? "Unknown Equipment"
                   cell.AddressLabel.text = equipment.providerName ?? "Unknown Provider"
                   if let imageURLs = equipment.imageURL, let firstImageURL = imageURLs.first {
                       if let imageData = try? Data(contentsOf: firstImageURL) {
                           cell.EquipmentImageLabel.image = UIImage(data: imageData)
                       } else {
                           cell.EquipmentImageLabel.image = UIImage(named: "defaultImage")
                       }
                   } else {
                       cell.EquipmentImageLabel.image = UIImage(named: "defaultImage")
                   }
                   cell.ConfirmButtomTapped.isHidden = (request.status != .pending)
                   cell.PendingButtonTapped.setTitle(request.status == .pending ? "Pending" : "Completed", for: .normal)
                   
                   return cell
               } else {
                   print("Error: Failed to dequeue CoequipCell.")
                   return UITableViewCell()
               }
    }
    
    
}
