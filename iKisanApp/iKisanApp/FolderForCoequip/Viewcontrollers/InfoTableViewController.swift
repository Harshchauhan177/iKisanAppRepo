import UIKit
import Foundation
import SwiftUI
import Supabase

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
        
        
        
        // Configure UI with equipment data
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
        
        // Set date if available
        if let selectedDate = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            dateLabel.text = dateFormatter.string(from: selectedDate)
        }
        
        // Set location from user's address
        if let dataController = self.dataController,
           let userAddress = dataController.getCurrentUserAddress() {
            self.location = userAddress
            self.LocationLabel.text = userAddress
            print("📍 Location set to: \(userAddress)")
        } else {
            // Set default location if user address is not available
            self.location = "Murshadpur, Greater Noida, U.P"
            self.LocationLabel.text = self.location
            print("📍 Using default location: \(self.location)")
        }
        
        // Setup text field delegate
        InputAreaLabel.delegate = self
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let infoVC = segue.destination as? InfoTableViewController {
            infoVC.date = self.selectedDate
        }
    }
    
    @IBAction func bookEquipment(_ sender: UIButton) {
        let infoVC = InfoTableViewController()
        infoVC.date = self.selectedDate
        navigationController?.pushViewController(infoVC, animated: true)
    }
    
    @IBAction func AddFarmerButtonTapped(_ sender: UIButton) {
        // Create the SelectFarmerView with the dataController and completion handler
        let selectFarmerView = SelectFarmerView(
            dataController: self.dataController ?? IKisanDataController(),
            onSelectionComplete: { [weak self] selectedFarmers in
                self?.selectedUsers = selectedFarmers
                self?.FarmerListLabel.text = "\(selectedFarmers.count) Farmers Selected"
            }
        )
        
        // Present the SwiftUI view in a UIHostingController
        let hostingController = UIHostingController(rootView: selectFarmerView)
        hostingController.modalPresentationStyle = .fullScreen
        self.present(hostingController, animated: true)
    }
}

