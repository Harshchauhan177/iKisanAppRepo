import UIKit

class AcceptRequestTableViewController: UITableViewController {
    var request: Request?
    var dataController: DataController?
    
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewLabel: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var intputArea: UITextField!
    @IBOutlet weak var timeSlotLabel: UILabel!
    
    let validStartTime = "08:00"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let request = request,
           let equipment = dataController?.getEquipmentById(request.equipmentId) {
            // Check if the equipmentImage is a URL or a local asset name
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageLabel.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                imageLabel.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
            titleLabel.text = equipment.name
            hostLabel.text; equipment.providerID.uuidString
           
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            let dateString = dateFormatter.string(from: request.requestedDate)
            dateLabel.text = "\(dateString)"
            let totalPrice = equipment.pricePerAcre * request.area
            priceLabel.text = "₹ \(Int(totalPrice))\nDate: \(dateString)"
            
           
            
            
        }
        intputArea.addTarget(self, action: #selector(areaInputChanged), for: .editingChanged)
        
        // Configure the main accept button at bottom (if using programmatic UI)
        // If using storyboard, configure in Interface Builder instead
    }
    @objc func areaInputChanged() {
    
        if let areaText = intputArea.text, !areaText.isEmpty {
                    updateTimeSlot(basedOn: areaText)
                }
        }
    func updateTimeSlot(basedOn areaText: String) {
        let areaCount = areaText.split(separator: " ").count
                let durationInMinutes = areaCount * 30
                let startTime = validStartTime
                let endTime = getEndTime(from: startTime, durationInMinutes:durationInMinutes)
                timeSlotLabel.text = "\(startTime) - \(endTime)"
    }
    func getEndTime(from startTime: String,durationInMinutes: Int) -> String {
        let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                if let startDate = formatter.date(from: startTime) {
                    let endDate = startDate.addingTimeInterval(Double(durationInMinutes * 60))
                    return formatter.string(from: endDate)
                }
                return startTime
        }
    
    @IBAction func AcceptButtonTapped(_ sender: Any) {
        guard let request = self.request,
              let dataController = self.dataController,
              let currentUser = dataController.getCurrentUser(),
              let area = intputArea.text, !area.isEmpty,
              let timeSlot = timeSlotLabel.text, !timeSlot.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all the required details.")
            return
        }
        
        // Validate area and time slot
        let areaCount = area.split(separator: " ").count
        let expectedEndTime = getEndTime(from: validStartTime, durationInMinutes: areaCount * 30)
        if timeSlot != "\(validStartTime) - \(expectedEndTime)" {
            showAlert(title: "Invalid Time Slot", message: "Please enter the area correctly")
            return
        }
        
        // Create a new request with updated values instead of modifying existing one
        let updatedRequest = Request(
            id: request.id,
            userId: request.userId,
            equipmentId: request.equipmentId,
            requestedDate: request.requestedDate,
            status: .confirmed,
            type: request.type,
            area: Double(area) ?? 0.0,
            timeSlot: .morning, // Set appropriate time slot based on your business logic
            timePeriod: request.timePeriod,
            location: request.location,
            typeOfRequest: request.typeOfRequest,
            selectedUsers: [], // We'll update this below
            joinedFarmers: request.joinedFarmers
        )
        
        // Add current user to selected users if not already present
        var selectedUsers = request.selectedUsers
        if !selectedUsers.contains(currentUser.userID) {
            selectedUsers.append(currentUser.userID)
        }
        
        // Update the request in data controller
        dataController.updateRequest(updatedRequest)
        
        // Update Supabase
        Task {
            do {
                // Convert selected users to JSON string
                let selectedUsersJson = try JSONEncoder().encode(selectedUsers)
                let selectedUsersString = String(data: selectedUsersJson, encoding: .utf8) ?? "[]"
                
                try await SupabaseManager.shared.client
                    .from("requests")
                    .update(["area": area,
                            "time_slot": updatedRequest.timeSlot.rawValue,
                            "status": "confirmed",
                            "selected_users": selectedUsersString])
                    .eq("id", value: request.id)
                    .execute()
                
                await MainActor.run {
                    showAlert(title: "Success", message: "Request accepted successfully")
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    showAlert(title: "Error", message: "Failed to update request: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    
    @IBAction func viewButtonTapped(_ sender: Any) {
    }
    
    
    func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }

//    func configure(with request: Request) {
//        self.request = request
//        
//        // Configure equipment details section
//        titleLabel.text = "Rice Harvester"  // Equipment name
//        priceLabel.text = "Price ₹1100/ac"
//        hostLabel.text = "Host By Veer Pal"
//        
//        // Configure location section
//        LocationLabel.text = "Murshadpur, Greater Noida, U.P"
//        
//        // Configure date section (currently shows "Label" in UI)
//        dateLabel.text = request.requestedDate.formatted(date: .abbreviated, time: .omitted)
//        
//        // Configure time slot
//        timeSlotLabel.text = "8 Am - 9 Am"
//        
//        // Configure area input placeholder
//        intputArea.placeholder = "Enter Your Area"
//        
//        // Configure image with corner radius
//        if let imageURL = URL(string: request.equipmentId.description) {
//            imageLabel.loadImage(from: imageURL.absoluteString)
//        }
//        imageLabel.layer.cornerRadius = 7
//        imageLabel.clipsToBounds = true
//        
//        // Style the view button if needed
//        viewLabel.layer.cornerRadius = 5
//        viewLabel.backgroundColor = UIColor(named: "AccentColor") // Your green color
//        viewLabel.setTitleColor(.white, for: .normal)
//    }
}
