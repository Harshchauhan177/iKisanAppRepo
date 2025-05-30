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
    
    // Remove the hardcoded start time
    // let validStartTime = "08:00"
    
    // Store equipment capacity for calculations
    private var equipmentCapacityPerHour: Double = 1.0
    private var startTime: String = "08:00" // Default start time if none provided
    
    private func extractLastTimeFromPeriod(_ timePeriod: String?) -> String {
        // Extract the end time from a time period string (e.g., "09:00 - 10:30" -> "10:30")
        if let period = timePeriod,
           let lastTime = period.split(separator: "-").last?.trimmingCharacters(in: .whitespaces) {
            return lastTime
        }
        return "08:00" // Default start time if no valid time period
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch and set user's address
        Task {
            do {
                if let address = try await AuthManager.shared.fetchCurrentUserAddress() {
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.LocationLabel.text = address
                        print("📍 Location set from Supabase: \(address)")
                    }
                } else if let address = dataController?.getCurrentUserAddress() {
                    self.LocationLabel.text = address
                    print("📍 Location set from DataController: \(address)")
                } else {
                    self.LocationLabel.text = "Murshadpur, Greater Noida, U.P"
                    print("📍 Using default location: Murshadpur, Greater Noida, U.P")
                }
            } catch {
                print("Error fetching address: \(error)")
                // Fallback to default location
                self.LocationLabel.text = "Murshadpur, Greater Noida, U.P"
            }
        }
        
        if let request = request,
           let equipment = dataController?.getEquipmentById(request.equipmentId) {
            
            if equipment.equipmentImage.hasPrefix("http") {
                imageLabel.loadImage(from: equipment.equipmentImage)
            } else {
                imageLabel.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
            titleLabel.text = equipment.name
            hostLabel.text = equipment.providerName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            let dateString = dateFormatter.string(from: request.requestedDate)
            dateLabel.text = "\(dateString)"
            let totalPrice = equipment.pricePerAcre 
            priceLabel.text = "₹ \(Int(totalPrice))\nDate: \(dateString)"
            
            // Parse equipment capacity (acres per hour)
            if let capacityValue = parseCapacity(equipment.capacity) {
                equipmentCapacityPerHour = capacityValue
                print("Equipment capacity: \(equipmentCapacityPerHour) acres per hour")
            }
            
            // Use the last time from request's timePeriod as starting time
            startTime = extractLastTimeFromPeriod(request.timePeriod)
            print("Using last time from request as start time: \(startTime)")
        }
        intputArea.addTarget(self, action: #selector(areaInputChanged), for: .editingChanged)
    }
    
    // Helper function to parse capacity string (e.g., "5 acres/hour")
    private func parseCapacity(_ capacityString: String) -> Double? {
        // Extract numeric value from capacity string
        let pattern = "([0-9]+\\.[0-9]*)" // Match numbers with optional decimal points
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: capacityString, range: NSRange(capacityString.startIndex..., in: capacityString)) {
            if let range = Range(match.range(at: 1), in: capacityString) {
                let numberString = String(capacityString[range])
                return Double(numberString)
            }
        }
        return 1.0 // Default to 1 acre per hour if parsing fails
    }
    
    @objc func areaInputChanged() {
        if let areaText = intputArea.text, !areaText.isEmpty {
            updateTimeSlot(basedOn: areaText)
        } else {
            // Clear the time slot when area is empty
            timeSlotLabel.text = ""
        }
    }
    
    func updateTimeSlot(basedOn areaText: String) {
        // Convert area text to double
        guard let area = Double(areaText) else {
            // If conversion fails, try counting words as before
            let areaCount = areaText.split(separator: " ").count
            let durationInMinutes = areaCount * 30
            let endTime = getEndTime(from: startTime, durationInMinutes: durationInMinutes)
            timeSlotLabel.text = "\(startTime) - \(endTime)"
            return
        }
        
        // Calculate duration based on equipment capacity (acres per hour)
        let durationInHours = area / equipmentCapacityPerHour
        let durationInMinutes = Int(durationInHours * 60)
        
        let endTime = getEndTime(from: startTime, durationInMinutes: durationInMinutes)
        timeSlotLabel.text = "\(startTime) - \(endTime)"
    }
    
    func getEndTime(from startTime: String, durationInMinutes: Int) -> String {
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
        
        // Validate time slot calculations
        if let areaValue = Double(area) {
            let durationInHours = areaValue / equipmentCapacityPerHour
            let durationInMinutes = Int(durationInHours * 60)
            let expectedEndTime = getEndTime(from: startTime, durationInMinutes: durationInMinutes)
            
            if timeSlot != "\(startTime) - \(expectedEndTime)" {
                showAlert(title: "Invalid Time Slot", message: "Please enter the area correctly")
                return
            }
        } else {
            let areaCount = area.split(separator: " ").count
            let expectedEndTime = getEndTime(from: startTime, durationInMinutes: areaCount * 30)
            if timeSlot != "\(startTime) - \(expectedEndTime)" {
                showAlert(title: "Invalid Time Slot", message: "Please enter the area correctly")
                return
            }
        }

        // Create a new participant for the current user
        let participant = RequestParticipant(
            id: UUID(),
            requestId: request.id,
            userId: currentUser.userID,
            status: .accepted,
            area: Double(area),
            timeSlot: .morning,
            joinedAt: Date()
        )
        
        // Update the request with the new participant
        var updatedRequest = request
        var participants = updatedRequest.participants ?? []
        participants.append(participant)
        updatedRequest.participants = participants
        updatedRequest.status = .pending
        
        // Update the request in the data controller
        dataController.updateRequest(updatedRequest)
        
        // Navigate back to CoequipViewController
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
            
            // Find and reload CoequipViewController
            if let coequipVC = navigationController.viewControllers.first(where: { $0 is CoequipViewController }) as? CoequipViewController {
                coequipVC.loadInitialData()
            }
        }
    }
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        guard let request = self.request,
              let dataController = self.dataController else {
            return
        }
        
        // Show confirmation alert
        let alertController = UIAlertController(
            title: "Reject Request",
            message: "Are you sure you want to reject this request?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let rejectAction = UIAlertAction(title: "Reject", style: .destructive) { [weak self] _ in
            // Update request with empty participants
            let updatedRequest = Request(
                id: request.id,
                userId: request.userId,
                equipmentId: request.equipmentId,
                requestedDate: request.requestedDate,
                status: request.status,
                type: request.type,
                area: request.area,
                timeSlot: request.timeSlot,
                timePeriod: request.timePeriod,
                location: request.location,
                typeOfRequest: request.typeOfRequest,
                participants: []
            )
            
            dataController.updateRequest(updatedRequest)
            
            // Navigate back and reload
            if let navigationController = self?.navigationController {
                navigationController.popViewController(animated: true)
                
                if let coequipVC = navigationController.viewControllers.first(where: { $0 is CoequipViewController }) as? CoequipViewController {
                    coequipVC.loadInitialData()
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(rejectAction)
        present(alertController, animated: true)
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
