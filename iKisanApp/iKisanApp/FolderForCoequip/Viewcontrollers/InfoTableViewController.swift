

import UIKit

class InfoTableViewController: UITableViewController {
    
    
    @IBOutlet weak var ImageLabel: UIImageView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var hostName: UILabel!
    
    @IBOutlet weak var InputAreaLabel: UITextField!
    
    @IBOutlet weak var TimeSlotLabel: UILabel!
    
    
    @IBOutlet weak var FarmerListLabel: UILabel!
    
    
        var location: String = "Some Location"
        var timeSlot: String = "08:00 - 08:30"
        var date: Date = Date()
    var cardData: CardData?
    let startTime = 8 * 60
    var selectedUsers: [CoequipUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = cardData {
            TitleLabel.text = data.title
            priceLabel.text = "₹ \(data.price)"
            hostName.text = data.host
            ImageLabel.image = data.imageName
        }
        updateFarmerList()
    }
    
    
    @IBAction func viewButtomTapped(_ sender: Any) {
    }
    
    
    @IBAction func AddFarmerButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToList", sender: sender)
    }
    func calculateTimeSlots(for slots: Int) -> (String, String) {
        let totalMinutes = slots * 30
        let endTimeInMinutes = startTime + totalMinutes
        
        let lowerHour = startTime / 60
        let lowerMinute = startTime % 60
        let upperHour = endTimeInMinutes / 60
        let upperMinute = endTimeInMinutes % 60
        let lowerTime = String(format: "%02d:%02d", lowerHour, lowerMinute)
        let upperTime = String(format: "%02d:%02d", upperHour, upperMinute)
        
        return (lowerTime, upperTime)
    }
    
    @IBAction func unwindToInfoTableViewController(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? SelectPeopleViewController {
                selectedUsers = sourceVC.selectedUsers
                print("Selected Users in InfoViewController: \(selectedUsers)")  // Debugging
            updateFarmerList()
            }
    }
    // Method to display selected farmers in the label
    func updateFarmerList() {
        print("Selected Users: \(selectedUsers)") // Check if the data is being passed correctly
            if selectedUsers.isEmpty {
                FarmerListLabel.text = "No farmers selected"
            } else {
                let farmerNames = selectedUsers.compactMap { $0.name }.joined(separator: ", ")
                FarmerListLabel.text = "Selected Farmers: \(farmerNames)"
            }
    }
    
    
    @IBAction func CreateButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindToCoequip", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "unwindToCoequip" {
                if let destinationVC = segue.destination as? CoequipViewController {
                    // Here you are passing data back to CoequipViewController
                    destinationVC.receivedRequestInfo = RequestInfo(
                        selectedUsers: selectedUsers,
                        location: location,
                        timeSlot: timeSlot,
                        date: date
                    )
                }
            }
        }
}
