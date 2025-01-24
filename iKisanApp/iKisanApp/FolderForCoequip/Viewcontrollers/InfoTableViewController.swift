

import UIKit

class InfoTableViewController: UITableViewController {
    
    
    @IBOutlet weak var ImageLabel: UIImageView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var hostName: UILabel!
    
    @IBOutlet weak var InputAreaLabel: UITextField!
    
    @IBOutlet weak var TimeSlotLabel: UILabel!
    
    
    @IBOutlet weak var FarmerListLabel: UILabel!
    
    var cardData: CardData?
    let startTime = 8 * 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = cardData {
            TitleLabel.text = data.title
            priceLabel.text = "₹ \(data.price)"
            hostName.text = data.host
            ImageLabel.image = data.imageName
        }
             
    }
    
    
    
    @IBAction func viewButtomTapped(_ sender: Any) {
    }
    
    
    @IBAction func AddFarmerButtonTapped(_ sender: Any) {
//        guard let inputText = InputAreaLabel.text, let numberOfSlots = Int(inputText), numberOfSlots > 0 else {
//            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid number of time slots.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//         let (lowerTime, upperTime) = calculateTimeSlots(for: numberOfSlots)
//        TimeSlotLabel.text = "Available Time: \(lowerTime) - \(upperTime)"
//            return
//        }

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
            let selectedPeopleNames = sourceVC.selectedPeople.map { $0.name }.joined(separator: ", ")
            FarmerListLabel.text = "Selected Farmers: \(selectedPeopleNames)"
        }
    }

//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            if let inputText = InputAreaLabel.text, let numberOfSlots = Int(inputText), numberOfSlots > 0 {
//                let (lowerTime, upperTime) = calculateTimeSlots(for: numberOfSlots)
//                TimeSlotLabel.text = "Available Time: \(lowerTime) - \(upperTime)"
//            }
//            textField.resignFirstResponder()
//            return true
//        }
//        func textFieldDidEndEditing(_ textField: UITextField) {
//            if let inputText = InputAreaLabel.text, let numberOfSlots = Int(inputText), numberOfSlots > 0 {
//                let (lowerTime, upperTime) = calculateTimeSlots(for: numberOfSlots)
//                TimeSlotLabel.text = "Available Time: \(lowerTime) - \(upperTime)"
//            }
//        }
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "goToList" {
//                if let destinationVC = segue.destination as? SelectPeopleViewController {
//                    if let slots = sender as? Int {
//                       
//                       destinationVC.numberOfSlots = slots
//                    }
//                }
//            }
//        }
    }
    
