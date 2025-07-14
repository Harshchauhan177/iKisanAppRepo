import UIKit
import Foundation
import SwiftUI

class InfoTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ImageLabel: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var InputAreaLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var TimeSlotLabel: UILabel!
    @IBOutlet weak var FarmerListLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var ViewButtonTapped: UIButton!
    // Properties
    var location: String = "Murshadpur, Greater Noida, U.P"
    var timeSlot: String = "08:00"
    var date: Date? = nil  // Don't set default date here, wait for proper initialization
    var cardData: Equipment?
    //let startTime = 8 * 60 // Start at 8 AM
    var selectedUsers: [User] = []
    var isModifying = false
    var existingRequest: Request?
    var dataController: DataController?
    private var currentTimeSlot: TimeSlot = .morning
    private var timeSlots: [String] = []
    var updateCompletionHandler: ((Request) -> Void)?
    var selectedDate: Date?
    
    // Helper function to get current user location from AuthManager
    private func getCurrentUserLocationFromAuthManager() -> String {
        print("🔍 Getting user location - START")
        
        // Use the new DataController function
        if let dataController = self.dataController,
           let address = dataController.getCurrentUserAddress() {
            print("📍 Using address from DataController: \(address)")
            return address
        }
        
        // Fallback to default if no address found
        let defaultLocation = "Murshadpur, Greater Noida, U.P"
        print("📍 Using default hardcoded location: \(defaultLocation)")
        return defaultLocation
    }
    
    // Add new properties for time calculation
    private let startTime = 8 * 60 // 8 AM in minutes
    private let endTime = 18 * 60  // 6 PM in minutes
    private let minutesPerHour = 60
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == InputAreaLabel {
            calculateTimeSlot()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == InputAreaLabel {
            // Get the updated text that will be in the text field after this change
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Update on main thread
            DispatchQueue.main.async {
                self.InputAreaLabel.text = updatedText
                if updatedText.isEmpty {
                    // Reset time slot if input is empty
                    self.TimeSlotLabel.text = "8 AM - 10 AM"
                } else if let _ = Double(updatedText) {
                    // Calculate time slot for valid number input
                    self.calculateTimeSlot()
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func calculateTimeSlot() {
        guard let areaText = InputAreaLabel.text,
              let area = Double(areaText),
              let equipment = cardData else {
            return
        }
        
        // Get equipment capacity and convert to Double
        let capacityPerHour = Double(equipment.capacity ?? "1") ?? 1.0
        
        // Calculate exact hours needed
        let hoursNeeded = area / capacityPerHour
        
        // Convert hours to minutes and calculate end time
        let minutesNeeded = hoursNeeded * 60.0 // Convert hours to minutes
        let endTimeInMinutes = Double(startTime) + minutesNeeded
        
        // Ensure end time doesn't exceed 6 PM (18:00)
        let finalEndTime = min(endTimeInMinutes, Double(endTime))
        
        // Format the time slot string with hours and minutes
        let startHour = startTime / minutesPerHour
        let endHour = Int(finalEndTime) / minutesPerHour
        let endMinutes = Int(finalEndTime) % minutesPerHour
        
        if endMinutes == 0 {
            TimeSlotLabel.text = String(format: "%02d:00 - %02d:00", startHour, endHour)
        } else {
            TimeSlotLabel.text = String(format: "%02d:00 - %02d:%02d", startHour, endHour, endMinutes)
        }
    }
    
    // Update viewDidLoad to setup text field delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageLabel.layer.cornerRadius = 10
        // Fetch and set user's address
        Task {
            do {
                if let address = try await AuthManager.shared.fetchCurrentUserAddress() {
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.location = address
                        self.LocationLabel.text = address
                        print("📍 Location set from Supabase: \(address)")
                    }
                } else if let address = dataController?.getCurrentUserAddress() {
                    self.location = address
                    self.LocationLabel.text = address
                    print("📍 Location set from DataController: \(address)")
                } else {
                    self.location = "Murshadpur, Greater Noida, U.P"
                    self.LocationLabel.text = self.location
                    print("📍 Using default location: \(self.location)")
                }
            } catch {
                print("Error fetching address: \(error)")
                // Fallback to default location
                self.location = "Murshadpur, Greater Noida, U.P"
                self.LocationLabel.text = self.location
            }
        }
    
        if let equipment = cardData {
            // Handle image loading
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use ImageCache utility to load it
                ImageLabel.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading
                ImageLabel.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
            
            TitleLabel.text = equipment.name
            priceLabel.text = "₹\(equipment.pricePerAcre)/ac"
            hostName.text = "Hosted by \(equipment.providerName ?? "Unknown")"
        }
        
        // Configure date picker
        setupDatePicker()
        
        if let selectedDate = date {
            datePicker.date = selectedDate
        } else {
            // If no date was passed, use today's date
            let today = Date()
            date = today
            datePicker.date = today
        }
        
        // Set location from user's address
        if let address = AuthManager.shared.currentUser?.address, !address.isEmpty {
            self.location = address
            self.LocationLabel.text = address
            print("📍 Location set to: \(address)")
        } else {
            self.location = "Murshadpur, Greater Noida, U.P"
            self.LocationLabel.text = self.location
            print("📍 Using default location: \(self.location)")
        }
        
        // Setup text field delegate
        InputAreaLabel.delegate = self
        
        print("Current user address: \(dataController?.getCurrentUserAddress() ?? "nil")")
    }
    
    // MARK: - Date Picker Configuration
    
    private func setupDatePicker() {
        // Set minimum date to today to prevent booking in the past
        let today = Calendar.current.startOfDay(for: Date())
        datePicker.minimumDate = today
        
        // Configure date picker style and color
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        
        // Add target for value changes
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @objc private func datePickerValueChanged() {
        // Update both date properties to ensure consistency
        date = datePicker.date
        selectedDate = datePicker.date
        
        // Update time slot calculation based on new date if needed
        if let area = Double(InputAreaLabel.text ?? "0"), area > 0 {
            calculateTimeSlot()
        }
    }
    
    private func updateTimeSlot(for area: Double) {
        // Get equipment capacity and convert to Double
        let capacityPerHour = Double(cardData?.capacity ?? "1") ?? 1.0
        
        // Calculate exact hours needed
        let hoursNeeded = area / capacityPerHour
        
        // Convert hours to minutes and calculate end time
        let minutesNeeded = hoursNeeded * 60.0 // Convert hours to minutes
        let endTimeInMinutes = Double(startTime) + minutesNeeded
        
        // Ensure end time doesn't exceed 6 PM (18:00)
        let finalEndTime = min(endTimeInMinutes, Double(endTime))
        
        // Format the time slot string with hours and minutes
        let startHour = startTime / minutesPerHour
        let endHour = Int(finalEndTime) / minutesPerHour
        let endMinutes = Int(finalEndTime) % minutesPerHour
        
        if endMinutes == 0 {
            TimeSlotLabel.text = String(format: "%02d:00 - %02d:00", startHour, endHour)
        } else {
            TimeSlotLabel.text = String(format: "%02d:00 - %02d:%02d", startHour, endHour, endMinutes)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let infoVC = segue.destination as? InfoTableViewController {
            infoVC.date = self.selectedDate
        }
    }
    
    
    
    @IBAction func ViewButton(_ sender: Any) {
        guard let equipment = cardData else {
            let alert = UIAlertController(
                title: "Error",
                message: "Equipment data not available",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let equipmentDescVC = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            equipmentDescVC.equipment = equipment
            equipmentDescVC.bookingSource = .coEquip
            equipmentDescVC.selectedDate = date
            navigationController?.pushViewController(equipmentDescVC, animated: true)
        }
    }
    
    
    
    
    @IBAction func bookEquipment(_ sender: UIButton) {
        let infoVC = InfoTableViewController()
        infoVC.date = self.selectedDate
        navigationController?.pushViewController(infoVC, animated: true)
    }
    
    @IBAction func AddFarmerButtonTapped(_ sender: UIButton) {
        let selectFarmerView = SelectFarmerView(
            dataController: self.dataController ?? IKisanDataController(),
            initialSelectedFarmers: Set(selectedUsers), // Pass currently selected farmers
            onFarmerSelection: { [weak self] selectedFarmers in
                guard let self = self else { return }
                self.selectedUsers = selectedFarmers
                self.FarmerListLabel.text = selectedFarmers.map { $0.name }.joined(separator: ", ")
            }
        )
        let hostingController = UIHostingController(rootView: selectFarmerView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    @IBAction func CreateButtonTapped(_ sender: UIButton, forEvent event: UIEvent) {
        guard let area = Double(InputAreaLabel.text ?? ""),
              let equipment = cardData,
              let selectedDate = date else {
            // Show error alert
            let alert = UIAlertController(title: "Error", message: "Please fill in all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else {
            let alert = UIAlertController(title: "Error", message: "Please log in to create a request", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let currentLocation = AuthManager.shared.currentUser?.address ?? self.location
        let requestId = UUID()
        let selectedUserIds = selectedUsers.map { $0.userID }
    
        Task {
            do {
                // Create the main request first
                let request = Request(
                    id: requestId,
                    userId: currentUser.userID,
                    equipmentId: equipment.equipmentID,
                    requestedDate: selectedDate,
                    status: .pending,
                    type: .coEquip,
                    area: area,
                    timeSlot: currentTimeSlot,
                    timePeriod: TimeSlotLabel.text,
                    location: currentLocation,
                    typeOfRequest: .myRequest,
                    participants: [], // Will be populated after creating participants
                    acceptedUsers: nil
                )
    
                // Create the request first
                let response = try await dataController.createRequest(request)
                
                // Add a small delay to ensure the request is committed
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                
                var participants: [RequestParticipant] = []
                
                // Create participants after ensuring request exists
                for user in selectedUsers {
                    let participant = RequestParticipant(
                        id: UUID(),
                        requestId: requestId,
                        userId: user.userID,
                        status: .pending,
                        area: nil,
                        timeSlot: nil,
                        joinedAt: request.requestedDate
                    )
                    
                    do {
                        try await dataController.createRequestParticipant(participant)
                        participants.append(participant)
                    } catch {
                        print("❌ Error creating participant for user \(user.userID): \(error)")
                        // Continue with other participants even if one fails
                        continue
                    }
                }
                
                // Update the request with the created participants
                var updatedRequest = request
                updatedRequest.participants = participants
                try await dataController.updateRequest(updatedRequest)
                
                // Show success on main thread
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Success",
                        message: "Request and participants created successfully",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                }
                
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to create request: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

