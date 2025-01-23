//
//  InfoTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 22/01/25.
//

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
        guard let inputText = InputAreaLabel.text, let numberOfSlots = Int(inputText), numberOfSlots > 0 else {
            // Handle invalid input
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid number of time slots.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 2. Call the function to calculate the time slots
        let (lowerTime, upperTime) = calculateTimeSlots(for: numberOfSlots)
        
        // 3. Update the TimeSlotLabel
        TimeSlotLabel.text = "Available Time: \(lowerTime) - \(upperTime)"
        
        // 4. Perform segue to next view controller (passing selected slots)
        performSegue(withIdentifier: "goToList", sender: numberOfSlots)
    }
    
    // Function to calculate the time slots
    func calculateTimeSlots(for slots: Int) -> (String, String) {
        let totalMinutes = slots * 30 // Each slot is 30 minutes
        let endTimeInMinutes = startTime + totalMinutes
        
        let lowerHour = startTime / 60
        let lowerMinute = startTime % 60
        let upperHour = endTimeInMinutes / 60
        let upperMinute = endTimeInMinutes % 60
        
        // Format the time as "HH:mm"
        let lowerTime = String(format: "%02d:%02d", lowerHour, lowerMinute)
        let upperTime = String(format: "%02d:%02d", upperHour, upperMinute)
        
        return (lowerTime, upperTime)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Calculate and update time slot if input is valid
            if let inputText = InputAreaLabel.text, let numberOfSlots = Int(inputText), numberOfSlots > 0 {
                let (lowerTime, upperTime) = calculateTimeSlots(for: numberOfSlots)
                TimeSlotLabel.text = "Available Time: \(lowerTime) - \(upperTime)"
            }
            
            // Dismiss the keyboard when Return is pressed
            textField.resignFirstResponder()
            return true
        }

        // Called when the user finishes editing (either "Return" is pressed or they tap outside)
        func textFieldDidEndEditing(_ textField: UITextField) {
            // Only calculate if the input is valid
            if let inputText = InputAreaLabel.text, let numberOfSlots = Int(inputText), numberOfSlots > 0 {
                let (lowerTime, upperTime) = calculateTimeSlots(for: numberOfSlots)
                TimeSlotLabel.text = "Available Time: \(lowerTime) - \(upperTime)"
            }
        }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToList" {
                if let destinationVC = segue.destination as? SelectPeopleViewController {
                    if let slots = sender as? Int {
                        // Pass the number of slots or other data you want
                        //destinationVC.selectedSlots = slots
                    }
                }
            }
        }
    }
    
