

import UIKit


class InfoTableViewController: UITableViewController{
    
    
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
    var selectedUsers: [CoEquipUser] = []
    
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
                print("Selected Users in InfoViewController: \(selectedUsers)")
            updateFarmerList()
            }
    }
    func updateFarmerList() {
        DispatchQueue.main.async {
                if self.selectedUsers.isEmpty {
                    self.FarmerListLabel.text = "farmers selected"
                } else {
                    let farmerNames = self.selectedUsers.compactMap { $0.name }.joined(separator: ", ")
                    self.FarmerListLabel.text = "Selected Farmers: \(farmerNames)"
                }
            }
    }
    
    
    @IBAction func CreateButtonTapped(_ sender: Any) {
        guard let title = TitleLabel.text, !title.isEmpty,
                     let farmerList = FarmerListLabel.text, farmerList != "No farmers selected",
                     !location.isEmpty, !timeSlot.isEmpty else {
                    let alert = UIAlertController(title: "Incomplete Information", message: "Please make sure all fields are filled before creating the request.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let confirmationAlert = UIAlertController(title: "Request Created", message: "Your request has been successfully created. Tap Done to continue.", preferredStyle: .alert)
                confirmationAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                    let successAlert = UIAlertController(title: "Request Submitted", message: "Your request has been successfully submitted!", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.performSegue(withIdentifier: "goToCoequip", sender: self)
                    }))
                    self.present(successAlert, animated: true, completion: nil)
                }))
                self.present(confirmationAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "goToCoequip" {
               if let destinationVC = segue.destination as? CoequipViewController {
                   destinationVC.receivedRequestInfo = RequestInfo(
                       selectedUsers: selectedUsers,
                       location: location,
                       timeSlot: timeSlot,
                       date: date,
                       equipmentImage: ImageLabel.image,
                       equipmentName: TitleLabel.text,
                       equipmentAddress: hostName.text   
                   )
               }
           }
       }
}
