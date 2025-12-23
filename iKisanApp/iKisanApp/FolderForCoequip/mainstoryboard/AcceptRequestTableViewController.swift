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
        self.title = "Search Equipment"
        imageLabel.layer.cornerRadius = 7
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
            
            // Show the request creator's name instead of equipment provider's name
            if let requestCreator = dataController?.getUserById(request.userId) {
                hostLabel.text = requestCreator.name
            } else {
                hostLabel.text = "Unknown User"
            }
            
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
            
            // Calculate the correct start time based on existing participants
            startTime = calculateNextAvailableStartTime(for: request)
            print("Calculated next available start time: \(startTime)")
        }
        intputArea.addTarget(self, action: #selector(areaInputChanged), for: .editingChanged)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
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
        // First, fetch the latest request data from the database to get current participants
        guard let currentRequest = self.request else {
            return
        }
        
        // Fetch fresh request data from database
        Task {
            // Use RequestManager to fetch fresh data
            let allRequests = await RequestManager.shared.fetchRequests()
            if let updatedRequest = allRequests.first(where: { $0.id == currentRequest.id }) {
                // Update our local request with fresh data
                await MainActor.run {
                    self.request = updatedRequest
                    
                    // Now calculate start time with updated data
                    let currentStartTime = self.calculateNextAvailableStartTime(for: updatedRequest)
                    print("🕒 Recalculated start time with fresh data: \(currentStartTime)")
                    
                    // Convert area text to double
                    guard let area = Double(areaText) else {
                        let areaCount = areaText.split(separator: " ").count
                        let durationInMinutes = areaCount * 30
                        let endTime = self.getEndTime(from: currentStartTime, durationInMinutes: durationInMinutes)
                        self.timeSlotLabel.text = "\(currentStartTime) - \(endTime)"
                        return
                    }
                    
                    // Calculate duration based on equipment capacity (acres per hour)
                    let durationInHours = area / self.equipmentCapacityPerHour
                    let durationInMinutes = Int(durationInHours * 60)
                    
                    let endTime = self.getEndTime(from: currentStartTime, durationInMinutes: durationInMinutes)
                    self.timeSlotLabel.text = "\(currentStartTime) - \(endTime)"
                    
                    print("⏰ Updated time slot with fresh data: \(currentStartTime) - \(endTime) for area: \(area) acres")
                }
            } else {
                // Fallback to existing logic if request not found
                await MainActor.run {
                    let currentStartTime = self.calculateNextAvailableStartTime(for: currentRequest)
                    print("🕒 Using fallback start time calculation: \(currentStartTime)")
                    
                    guard let area = Double(areaText) else {
                        let areaCount = areaText.split(separator: " ").count
                        let durationInMinutes = areaCount * 30
                        let endTime = self.getEndTime(from: currentStartTime, durationInMinutes: durationInMinutes)
                        self.timeSlotLabel.text = "\(currentStartTime) - \(endTime)"
                        return
                    }
                    
                    let durationInHours = area / self.equipmentCapacityPerHour
                    let durationInMinutes = Int(durationInHours * 60)
                    
                    let endTime = self.getEndTime(from: currentStartTime, durationInMinutes: durationInMinutes)
                    self.timeSlotLabel.text = "\(currentStartTime) - \(endTime)"
                    
                    print("⏰ Updated time slot with fallback: \(currentStartTime) - \(endTime) for area: \(area) acres")
                }
            }
        }
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
        
        // Create participant data for database update with explicit type annotation
        let participantData: [String: String] = [
            "status": "done",
            "area": String(Double(area) ?? 0.0),
            "timeSlotId": timeSlot,
            "updated_at": Date().ISO8601Format()
        ]
        
        // Update database first
        Task {
            do {
                // First update the request_participants table
                try await SupabaseManager.shared.client
                    .from("request_participants")
                    .update(participantData)
                    .eq("requestId", value: request.id.uuidString)
                    .eq("userId", value: currentUser.userID.uuidString)
                    .execute()
                
                print("✅ Updated request_participants table")
                
                // Fetch current request to get existing acceptedUser array with retry logic
                var attempts = 0
                var currentAcceptedUsers: [String] = []
                let maxAttempts = 3
                
                while attempts < maxAttempts {
                    do {
                        let currentRequestData = try await SupabaseManager.shared.client
                            .from("requests")
                            .select("acceptedUser")
                            .eq("id", value: request.id.uuidString)
                            .single()
                            .execute()
                        
                        // Parse the current acceptedUser array more safely
                        if let jsonObject = try JSONSerialization.jsonObject(with: currentRequestData.data) as? [String: Any] {
                            if let acceptedUserArray = jsonObject["acceptedUser"] as? [String] {
                                currentAcceptedUsers = acceptedUserArray
                                print("📊 Current accepted users: \(currentAcceptedUsers)")
                            } else if let acceptedUserArray = jsonObject["acceptedUser"] as? [String?] {
                                currentAcceptedUsers = acceptedUserArray.compactMap { $0 }
                                print("📊 Current accepted users (nullable): \(currentAcceptedUsers)")
                            } else {
                                currentAcceptedUsers = []
                                print("📊 No accepted users found, starting with empty array")
                            }
                        }
                        break // Success, exit retry loop
                        
                    } catch {
                        attempts += 1
                        print("⚠️ Attempt \(attempts) failed: \(error)")
                        if attempts >= maxAttempts {
                            throw error
                        }
                        // Wait 500ms before retry
                        try await Task.sleep(nanoseconds: 500_000_000)
                    }
                }
                
                // Add current user to accepted users if not already present
                let currentUserIdString = currentUser.userID.uuidString
                if !currentAcceptedUsers.contains(currentUserIdString) {
                    currentAcceptedUsers.append(currentUserIdString)
                    print("✅ Added user \(currentUserIdString) to accepted users. New array: \(currentAcceptedUsers)")
                    
                    // Update the requests table with the updated acceptedUser array
                    // Create a properly typed update structure
                    struct RequestUpdate: Encodable {
                        let acceptedUser: [String]
                        let updated_at: String
                    }
                    
                    let updateData = RequestUpdate(
                        acceptedUser: currentAcceptedUsers,
                        updated_at: Date().ISO8601Format()
                    )
                    
                    try await SupabaseManager.shared.client
                        .from("requests")
                        .update(updateData)
                        .eq("id", value: request.id.uuidString)
                        .execute()
                    
                    print("✅ Successfully updated requests table with new acceptedUser array")
                    
                    // Small delay to ensure database consistency
                    try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                    
                } else {
                    print("ℹ️ User \(currentUserIdString) is already in accepted users list")
                }
                
                // If database update successful, update local data
                var updatedRequest = request
                if let participantIndex = updatedRequest.participants?.firstIndex(where: { $0.userId == currentUser.userID }) {
                    // Update existing participant
                    updatedRequest.participants?[participantIndex].status = .done
                    updatedRequest.participants?[participantIndex].area = Double(area) ?? 0.0
                    updatedRequest.participants?[participantIndex].timeSlot = timeSlot
                    
                    // Update request status
                    updatedRequest.status = .pending
                    
                    // Update local accepted users array with the latest from database
                    updatedRequest.acceptedUsers = currentAcceptedUsers.compactMap { UUID(uuidString: $0) }
                    
                    // Update local data
                    dataController.updateRequest(updatedRequest)
                    
                    // Create a CoEquip booking for this participant
                    print("🔧 Creating CoEquip booking for participant: \(currentUser.userID)")
                    
                    // Determine the TimeSlot enum from the string timeSlot
                    let bookingTimeSlot: TimeSlot
                    if let startTimeString = timeSlot.split(separator: "-").first?.trimmingCharacters(in: .whitespaces),
                       let startHour = Int(startTimeString.split(separator: ":").first ?? "") {
                        // Morning: 6:00 - 11:59
                        // Afternoon: 12:00 - 16:59
                        // Evening: 17:00 - 21:00
                        if startHour < 12 {
                            bookingTimeSlot = .morning
                        } else if startHour < 17 {
                            bookingTimeSlot = .afternoon
                        } else {
                            bookingTimeSlot = .evening
                        }
                    } else {
                        bookingTimeSlot = .morning // Default to morning if parsing fails
                    }
                    
                    let participantBooking = Booking(
                        bookingID: UUID(),
                        userID: currentUser.userID,
                        equipmentID: request.equipmentId,
                        bookingType: .coEquip,
                        bookingDate: request.requestedDate,
                        fieldArea: Double(area) ?? 0.0,
                        status: .pending, // Participant's booking is pending until creator confirms
                        timeSlot: bookingTimeSlot,
                        source: .coEquip,
                        bookingLocation: Location(
                            latitude: 0.0,
                            longitude: 0.0,
                            address: request.location
                        )
                    )
                    
                    let bookingSuccess = dataController.addBooking(participantBooking)
                    if bookingSuccess {
                        print("✅ CoEquip booking created successfully for participant")
                    } else {
                        print("❌ Failed to create CoEquip booking for participant")
                    }
                    
                    await MainActor.run {
                        // Show success alert before navigating back
                        let alert = UIAlertController(
                            title: "Success",
                            message: "Request accepted successfully! Your booking has been created.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                            // Navigate back to CoequipViewController after alert is dismissed
                            if let navigationController = self?.navigationController {
                                navigationController.popViewController(animated: true)
                                
                                if let coequipVC = navigationController.viewControllers.first(where: { $0 is CoequipViewController }) as? CoequipViewController {
                                    coequipVC.loadInitialData()
                                }
                            }
                        })
                        present(alert, animated: true)
                    }
                } else {
                    await MainActor.run {
                        self.showAlert(title: "Error", message: "Could not find participant to update")
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: "Failed to update request: \(error.localizedDescription)")
                }
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
        guard let request = request,
              let equipment = dataController?.getEquipmentById(request.equipmentId) else {
            showAlert(title: "Error", message: "Equipment data not available")
            return
        }
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let equipmentDescVC = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            equipmentDescVC.equipment = equipment
            equipmentDescVC.bookingSource = .coEquipViewOnly  // Use view-only mode for request card views
            equipmentDescVC.selectedDate = request.requestedDate
            navigationController?.pushViewController(equipmentDescVC, animated: true)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Add new method to calculate the next available start time
    private func calculateNextAvailableStartTime(for request: Request) -> String {
        var latestEndTime = "08:00" // Default start time if no participants
        
        // Check if there are any participants with .done status
        if let participants = request.participants {
            let acceptedParticipants = participants.filter { $0.status == .done }
            
            if !acceptedParticipants.isEmpty {
                print("Found \(acceptedParticipants.count) accepted participants")
                
                // Find the latest end time from all accepted participants
                for participant in acceptedParticipants {
                    if let timeSlot = participant.timeSlot {
                        print("Participant \(participant.userId) has time slot: \(timeSlot)")
                        
                        // Extract end time from time slot (e.g., "08:20 - 09:20" -> "09:20")
                        if let endTime = extractEndTimeFromTimeSlot(timeSlot) {
                            print("Extracted end time: \(endTime)")
                            
                            // Compare and keep the latest end time
                            if isTimeLater(endTime, than: latestEndTime) {
                                latestEndTime = endTime
                                print("Updated latest end time to: \(latestEndTime)")
                            }
                        }
                    }
                }
            } else {
                // No accepted participants yet, use the original request creator's end time
                if let timePeriod = request.timePeriod {
                    latestEndTime = extractLastTimeFromPeriod(timePeriod)
                    print("No accepted participants, using request creator's end time: \(latestEndTime)")
                }
            }
        }
        
        return latestEndTime
    }
    
    // Helper method to extract end time from a time slot string
    private func extractEndTimeFromTimeSlot(_ timeSlot: String) -> String? {
        // Extract end time from "08:20 - 09:20" format
        let components = timeSlot.split(separator: "-")
        if components.count == 2 {
            let endTime = components[1].trimmingCharacters(in: .whitespaces)
            return endTime
        }
        return nil
    }
    
    // Helper method to compare if one time is later than another
    private func isTimeLater(_ time1: String, than time2: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date1 = formatter.date(from: time1),
              let date2 = formatter.date(from: time2) else {
            return false
        }
        
        return date1 > date2
    }
}
