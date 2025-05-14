import UIKit
import Foundation

class InfoTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ImageLabel: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var InputAreaLabel: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var TimeSlotLabel: UILabel!
    @IBOutlet weak var FarmerListLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    
    // Properties
    var location: String = "Murshadpur, Greater Noida, U.P"  // Default location
    var timeSlot: String = "08:00"
    var date: Date? = nil  // Don't set default date here, wait for proper initialization
    var cardData: Equipment?
    let startTime = 8 * 60 // Start at 8 AM
    var selectedUsers: [User] = []
    var isModifying = false
    var existingRequest: Request?
    var dataController: DataController?
    private var currentTimeSlot: TimeSlot = .morning
    private var timeSlots: [String] = []
    var updateCompletionHandler: ((Request) -> Void)?
    
    // Helper function to get current user location from AuthManager
    private func getCurrentUserLocationFromAuthManager() -> String {
        print("🔍 Getting user location - START")
        var sourceDescription = "unknown"
        
        // Try to get from AuthManager first (this is the primary source)
        if let authUser = AuthManager.shared.currentUser {
            // If we have address directly on the user
            if let userAddress = authUser.address, !userAddress.isEmpty {
                sourceDescription = "AuthManager.currentUser.address"
                print("📍 Using address directly from AuthManager: \(userAddress)")
                return userAddress
            }
            // If we have a location object with address
            else if let userLocation = authUser.location, let address = userLocation.address, !address.isEmpty {
                sourceDescription = "AuthManager.currentUser.location.address"
                print("📍 Using location object from AuthManager: \(address)")
                return address
            }
            // We have a user but no valid address
            else {
                print("⚠️ AuthManager user has no valid address")
            }
        } else {
            print("⚠️ No current user in AuthManager")
        }
        
        // Try fallback to the shared user singleton
        if let user = currentUser.shared.user {
            if let address = user.location.address, !address.isEmpty {
                sourceDescription = "currentUser.shared.user.location.address"
                print("📍 Using address from currentUser singleton: \(address)")
                return address
            }
        } else {
            print("⚠️ No user found in currentUser.shared")
        }
        
        // Last resort - use hardcoded default
        sourceDescription = "default hardcoded value"
        let defaultLocation = "Murshadpur, Greater Noida, U.P"
        print("📍 Using default hardcoded location: \(defaultLocation)")
        print("🔍 Getting user location - END (Source: \(sourceDescription))")
        return defaultLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔄 InfoTableVC viewDidLoad - START")
        
        // Detailed DEBUG information about this view controller
        print("🔎 DEBUG InfoTableVC state at viewDidLoad:")
        if let dateValue = self.date {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateValue)
            print("  - Date: \(df.string(from: dateValue))")
            print("  - Components: Y:\(dateComponents.year!) M:\(dateComponents.month!) D:\(dateComponents.day!) H:\(dateComponents.hour ?? 0) M:\(dateComponents.minute ?? 0)")
        } else {
            print("  - Date: nil")
        }
        print("  - Location: \(self.location)")
        
        // Setup UI basics
        ImageLabel.layer.cornerRadius = 7
        InputAreaLabel.delegate = self
        
        // Set location directly from AuthManager
        self.location = getCurrentUserLocationFromAuthManager()
        LocationLabel.text = self.location
        print("📍 Location set in viewDidLoad: \(self.location)")
        
        // Set date if not already set
        if let dateValue = self.date {
            let df = DateFormatter()
            df.dateFormat = "E, d MMM"
            let dateString = df.string(from: dateValue)
            dateLabel.text = dateString
            print("📅 Using existing date in viewDidLoad: \(dateString)")
            
            // Print date components for debugging
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateValue)
            print("📅 Date components: Y:\(components.year!) M:\(components.month!) D:\(components.day!) H:\(components.hour ?? 0) Min:\(components.minute ?? 0)")
        } else {
            print("⚠️ Date is nil in viewDidLoad, using current date as fallback!")
            // Default to today if nil
            let currentDate = Date()
            
            // Normalize to noon to avoid timezone issues
            var components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
            components.hour = 12
            components.minute = 0
            components.second = 0
            
            if let normalizedDate = Calendar.current.date(from: components) {
                self.date = normalizedDate
                
                let df = DateFormatter()
                df.dateFormat = "E, d MMM"
                let dateString = df.string(from: normalizedDate)
                dateLabel.text = dateString
                print("📅 Using fallback current date (normalized): \(dateString)")
            } else {
                // Fallback if normalization fails
                self.date = currentDate
                let df = DateFormatter()
                df.dateFormat = "E, d MMM"
                let dateString = df.string(from: currentDate)
                dateLabel.text = dateString
                print("📅 Using fallback current date (not normalized): \(dateString)")
            }
        }
        
        // Add listener for area input changes
        InputAreaLabel.addTarget(self, action: #selector(areaInputChanged(_:)), for: .editingChanged)
        
        // Setup UI with equipment data if available
        if let data = cardData {
            print("📦 Setting up UI with equipment: \(data.name)")
            TitleLabel.text = data.name
            priceLabel.text = "₹ \(data.pricePerHour)"
            hostName.text = data.providerName ?? "Unknown Provider"
            ImageLabel.image = UIImage(named: data.equipmentImage)
        } else {
            print("⚠️ No equipment data available in viewDidLoad")
        }
        
        // Setup for modifying existing request
        if isModifying, let request = existingRequest {
            InputAreaLabel.text = String(request.area)
            TimeSlotLabel.text = request.timePeriod
            currentTimeSlot = request.timeSlot
            updateFarmerList()
            navigationItem.rightBarButtonItem?.title = "Update"
        }
        
        updateFarmerList()
        
        // Verify configuration
        verifyConfiguration()
        
        print("🔄 InfoTableVC viewDidLoad - COMPLETED")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("🔄 InfoTableVC viewWillAppear called")
        
        // Only refresh location if we don't have one already
        if self.location.isEmpty {
            self.location = getCurrentUserLocationFromAuthManager()
            print("📍 Location initialized in viewWillAppear: \(self.location)")
        }
        LocationLabel.text = self.location
        print("📍 Location displayed in viewWillAppear: \(self.location)")
        
        // Update date display only if we have a date
        if let dateValue = self.date {
            let df = DateFormatter()
            df.dateFormat = "E, d MMM"
            let dateString = df.string(from: dateValue)
            dateLabel.text = dateString
            print("📅 Date displayed in viewWillAppear: \(dateString)")
        } else {
            print("⚠️ Date is still nil in viewWillAppear!")
        }
        
        updateFarmerList()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // This is an additional check to ensure the date is displayed correctly
        // It will run multiple times during view transitions
        if let dateValue = self.date {
            // Only update if the label doesn't match the date
            let df = DateFormatter()
            df.dateFormat = "E, d MMM"
            let expectedDisplay = df.string(from: dateValue)
            
            if dateLabel.text != expectedDisplay {
                print("⚠️ Date label doesn't match expected date, fixing...")
                print("  - Current label: \(dateLabel.text ?? "nil")")
                print("  - Should be: \(expectedDisplay)")
                
                dateLabel.text = expectedDisplay
                
                // Also print the raw date for debugging
                let debugDF = DateFormatter()
                debugDF.dateFormat = "yyyy-MM-dd HH:mm:ss"
                print("  - Raw date value: \(debugDF.string(from: dateValue))")
            }
        }
    }
    
    // Modified to properly handle the passed data
    func configure(with equipment: Equipment, dataController: DataController, date: Date) {
        print("⚙️ configure called with equipment: \(equipment.name), date: \(date)")
        
        // Store the data
        self.cardData = equipment
        self.dataController = dataController
        
        // CRITICAL: Set the date explicitly and normalize it
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        components.minute = 0
        components.second = 0
        
        if let normalizedDate = Calendar.current.date(from: components) {
            self.date = normalizedDate
            
            // Debug date
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("📅 Date set in configure (normalized): \(df.string(from: normalizedDate))")
            
            // Add more date debugging info
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: normalizedDate)
            print("📅 Configure date components: Y:\(components.year!) M:\(components.month!) D:\(components.day!) H:\(components.hour ?? 0) Min:\(components.minute ?? 0)")
        } else {
            // If normalization fails, use the original date
            self.date = date
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("⚠️ Date normalization failed, using original: \(df.string(from: date))")
        }
        
        // Get location from AuthManager
        self.location = getCurrentUserLocationFromAuthManager()
        print("📍 Location set in configure: \(self.location)")
        
        // If view is already loaded, update UI immediately
        if isViewLoaded {
            print("🔧 View is loaded, updating UI immediately")
            
            // Update UI elements
            TitleLabel.text = equipment.name
            priceLabel.text = "₹ \(equipment.pricePerHour)"
            hostName.text = equipment.providerName ?? "Unknown Provider"
            ImageLabel.image = UIImage(named: equipment.equipmentImage)
            
            // Update location label
            LocationLabel.text = self.location
            
            // Update date label using our helper
            forceDateDisplay()
            
            updateFarmerList()
            
            // Verify configuration was successful
            verifyConfiguration()
        } else {
            print("⚠️ View not loaded yet, UI will be updated in viewDidLoad")
        }
    }
    
    // Helper method to verify configuration
    private func verifyConfiguration() {
        print("🔍 Verifying InfoTableVC configuration...")
        
        if let dateValue = self.date {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            print("✅ Date verified: \(df.string(from: dateValue))")
        } else {
            print("❌ ERROR: Date is nil after configuration!")
        }
        
        print("✅ Location verified: \(self.location)")
        
        if let equipment = self.cardData {
            print("✅ Equipment verified: \(equipment.name)")
        } else {
            print("❌ ERROR: Equipment is nil after configuration!")
        }
        
        print("🔍 Verification complete")
    }
    
    @IBAction func viewButtomTapped(_ sender: Any) {
    }
    
    @IBAction func AddFarmerButtonTapped(_ sender: Any) {
        // Create and configure the UserListViewController
        let userListVC = UserListViewController()
        userListVC.dataController = self.dataController
        userListVC.title = "Select Farmers"
        
        // Set up a callback to receive selected users
        userListVC.onUserSelected = { [weak self] selectedUser in
            guard let self = self else { return }
            
            // Add the user to our selected users if not already present
            if !self.selectedUsers.contains(where: { $0.userID == selectedUser.userID }) {
                self.selectedUsers.append(selectedUser)
                self.updateFarmerList()
            }
        }
        
        // Present modally with a navigation controller
        let navController = UINavigationController(rootViewController: userListVC)
        present(navController, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, let area = Double(text) {
            calculateTimeSlot(for: area)
        }
        textField.resignFirstResponder()
        return true
    }

    private func calculateTimeSlot(for area: Double) {
        // Get equipment capacity (acres/hour)
        let acresPerHour: Double
        if let equipment = cardData {
            // Parse capacity string to extract numeric value
            let capacityString = equipment.capacity
            // Extract digits from the capacity string
            let digits = capacityString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let capacity = Double(digits), capacity > 0 {
                acresPerHour = capacity
            } else {
                // Default capacity if unable to extract
                acresPerHour = 2.0
            }
        } else {
            // Default capacity if no equipment data
            acresPerHour = 2.0
        }
        
        // Calculate time required in minutes
        let timeRequired = (area / acresPerHour) * 60
        
        timeSlots.removeAll()
        var currentTime = startTime // Start at 8 AM
        
        // End of workday at 5 PM
        let endOfDay = 17 * 60
        
        while currentTime < endOfDay {
            let endTime = min(currentTime + Int(timeRequired), endOfDay)
            let timeSlotString = formatTimeSlot(start: currentTime, end: endTime)
            timeSlots.append(timeSlotString)
            
            // Increment by 30 minutes for next slot
            currentTime += 30
        }
        
        if let firstSlot = timeSlots.first {
            self.timeSlot = firstSlot
            TimeSlotLabel.text = firstSlot
            
            // Determine time slot category
            let hourAtMiddle = (currentTime + Int(timeRequired)/2) / 60
            if hourAtMiddle < 12 {
                currentTimeSlot = .morning
            } else if hourAtMiddle < 15 {
                currentTimeSlot = .afternoon
            } else {
                currentTimeSlot = .evening
            }
        }
    }

    private func formatTimeSlot(start: Int, end: Int) -> String {
        let startHour = start / 60
        let startMinute = start % 60
        let endHour = end / 60
        let endMinute = end % 60
        
        return String(format: "%02d:%02d - %02d:%02d", startHour, startMinute, endHour, endMinute)
    }
    
    @IBAction func unwindToInfoTableViewController(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? SelectPeopleViewController {
            selectedUsers = sourceVC.selectedUsers
            updateFarmerList()
        }
    }
    
    func updateFarmerList() {
        if selectedUsers.isEmpty {
            FarmerListLabel.text = "No farmers selected"
            FarmerListLabel.textColor = .gray
        } else {
            let farmerNames = selectedUsers.map { user in
                return user.name
            }
            let farmersText = farmerNames.joined(separator: ", ")
            FarmerListLabel.text = farmersText
            FarmerListLabel.textColor = .black
        }
    }
    
    func clearSelectedFarmers() {
        selectedUsers.removeAll()
        updateFarmerList()
    }
    
    @IBAction func CreateButtonTapped(_ sender: Any) {
        print("🔄 Create button tapped")
        
        guard let dataController = self.dataController else {
            print("❌ Error: Data controller not found")
            showAlert(message: "System error: Data controller not found")
            return
        }
        
        // 1. Validate all required fields
        guard let equipment = cardData else {
            print("❌ Error: No equipment data")
            showAlert(message: "Error: No equipment selected")
            return
        }
        
        guard let selectedDate = date else {
            print("❌ Error: No date selected")
            showAlert(message: "Please select a date")
            return
        }
        
        guard let areaText = InputAreaLabel.text,
              !areaText.isEmpty,
              let area = Double(areaText) else {
            print("❌ Error: Invalid area input")
            showAlert(message: "Please enter a valid area")
            return
        }
        
        guard !location.isEmpty else {
            print("❌ Error: No location specified")
            showAlert(message: "Please specify a location")
            return
        }
        
        // 2. Get current user ID
        guard let currentUserId = AuthManager.shared.currentUser?.id ?? currentUser.shared.user?.userID else {
            print("❌ Error: No user logged in")
            showAlert(message: "Error: No user logged in")
            return
        }
        
        // Debug logging
        print("📝 Creating request with:")
        print("👤 User ID: \(currentUserId)")
        print("🚜 Equipment ID: \(equipment.equipmentID)")
        print("📅 Date: \(selectedDate)")
        print("📏 Area: \(area)")
        print("📍 Location: \(location)")
        print("⏰ Time Slot: \(currentTimeSlot)")
        print("👥 Selected Users: \(selectedUsers.map { $0.name }.joined(separator: ", "))")
        
        // 3. Normalize the date to noon to avoid timezone issues
        var normalizedComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        normalizedComponents.hour = 12
        normalizedComponents.minute = 0
        normalizedComponents.second = 0
        
        let finalDate = Calendar.current.date(from: normalizedComponents) ?? selectedDate
        print("📅 Normalized date: \(finalDate)")
        
        if isModifying {
            print("🔄 Modifying existing request")
            guard let existingRequest = existingRequest else {
                print("❌ Error: Original request not found")
                showAlert(message: "Error: Original request not found")
                return
            }
            
            // Create updated request
            let updatedRequest = Request(
                id: existingRequest.id,
                userId: currentUserId,
                equipmentId: equipment.equipmentID,
                requestedDate: finalDate,
                status: existingRequest.status,
                type: .coEquip,
                area: area,
                timeSlot: currentTimeSlot,
                timePeriod: timeSlot,
                location: location,
                typeOfRequest: .myRequest,
                selectedUsers: selectedUsers,
                joinedFarmers: selectedUsers.map { $0.userID }
            )
            
            print("📤 Updating request in DataController")
            dataController.updateRequest(updatedRequest)
            updateCompletionHandler?(updatedRequest)
            
            showSuccessAlert(message: "Request updated successfully") { [weak self] in
                print("✅ Request update completed")
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            print("🔄 Creating new request")
            // Create new request
            let newRequest = Request(
                id: UUID(),
                userId: currentUserId,
                equipmentId: equipment.equipmentID,
                requestedDate: finalDate,
                status: .pending,
                type: .coEquip,
                area: area,
                timeSlot: currentTimeSlot,
                timePeriod: timeSlot,
                location: location,
                typeOfRequest: .myRequest,
                selectedUsers: selectedUsers,
                joinedFarmers: selectedUsers.map { $0.userID }
            )
            
            print("📤 Saving new request to DataController")
            dataController.addNewCoEquipRequest(newRequest)
            
            showSuccessAlert(message: "Request created successfully") { [weak self] in
                print("✅ Request creation completed")
                // Navigate back to CoequipViewController
                let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
                if let coequipVC = storyboard.instantiateViewController(withIdentifier: "CoequipViewController") as? CoequipViewController {
                    coequipVC.dataController = self?.dataController
                    coequipVC.currentRequest = newRequest
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showSuccessAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Alert",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCoequip",
           let destinationVC = segue.destination as? CoequipViewController,
           let request = sender as? Request {
            destinationVC.currentRequest = request // Pass the request to CoequipViewController
        }
    }
    
    @objc func areaInputChanged(_ textField: UITextField) {
        if let text = textField.text, let area = Double(text) {
            calculateTimeSlot(for: area)
        }
    }
    
    // Public method to explicitly set the date and update UI
    func setDate(_ newDate: Date) {
        print("📅 Setting date explicitly: \(newDate)")
        
        // Print detailed debug info
        let debugDateFormatter = DateFormatter()
        debugDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("🔎 DEBUG setDate called with: \(debugDateFormatter.string(from: newDate))")
        
        // Debug components
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: newDate)
        print("📅 Input date components: Y:\(components.year!) M:\(components.month!) D:\(components.day!) H:\(components.hour ?? 0) Min:\(components.minute ?? 0)")
        
        // Ensure we preserve time component by setting it to noon
        // This prevents date issues across time zones or day boundaries
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: newDate)
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        
        if let adjustedDate = Calendar.current.date(from: dateComponents) {
            // Store the date with normalized time
            self.date = adjustedDate
            
            // Update UI if view is loaded
            if isViewLoaded {
                let df = DateFormatter()
                df.dateFormat = "E, d MMM"
                let dateString = df.string(from: adjustedDate)
                dateLabel.text = dateString
                print("📅 Date label updated to: \(dateString)")
                
                // Additional debug output
                print("🔎 DEBUG: Date after normalization:")
                print("  - Original: \(debugDateFormatter.string(from: newDate))")
                print("  - Normalized: \(debugDateFormatter.string(from: adjustedDate))")
                print("  - Display string: \(dateString)")
            } else {
                print("⚠️ View not loaded yet, date label will be updated in viewDidLoad")
            }
            
            // Log for debugging
            print("📅 Date set to (normalized): \(debugDateFormatter.string(from: adjustedDate))")
        } else {
            // If normalization fails, use the original date
            print("⚠️ Date normalization failed, using original date")
            self.date = newDate
            
            // Update UI
            if isViewLoaded {
                let df = DateFormatter()
                df.dateFormat = "E, d MMM"
                let dateString = df.string(from: newDate)
                dateLabel.text = dateString
                print("📅 Date label updated to (non-normalized): \(dateString)")
            }
        }
    }
    
    // Public method to explicitly set the location and update UI
    func setLocation(_ newLocation: String) {
        print("📍 Setting location explicitly: \(newLocation)")
        
        // Store the location
        self.location = newLocation
        
        // Update UI if view is loaded
        if isViewLoaded {
            LocationLabel.text = newLocation
            print("📍 Location label updated")
        } else {
            print("⚠️ View not loaded yet, location label will be updated in viewDidLoad")
        }
    }
    
    // Helper method to force the date display to match the stored date
    private func forceDateDisplay() {
        if let dateValue = self.date {
            // Format using E, d MMM format (Wed, 17 May)
            let df = DateFormatter()
            df.dateFormat = "E, d MMM"
            let dateString = df.string(from: dateValue)
            
            // Update the label
            dateLabel.text = dateString
            
            print("🔧 Forced date display: \(dateString)")
        } else {
            print("⚠️ Cannot force date display - date is nil!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure date display is correct when view appears
        print("🔄 InfoTableVC viewDidAppear called")
        forceDateDisplay()
    }
}

