//
//  ReviewBookingTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit

class ReviewBookingTableViewController: UITableViewController,UITextFieldDelegate {
    
    var timeSlot = ["Morning","Afternoon","Evening"]
    var locationA: String?
    var pricePerHr: Double = 100
    
    var equipment: Equipment?
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var fieldAreaTextField: UITextField!
    
    @IBOutlet var timeButtonOutlet: UIButton!
    
    @IBOutlet var timeSlotDisplayOutlet: UILabel!
    @IBOutlet var priceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        fieldAreaTextField.delegate = self
        
        updateData()
        
        setUpMenus()

    }

    func updateData() {
        
        //locationLabel.text = locationA
        locationLabel.text = equipment?.location ?? locationA
        datePicker.date = Date()
        
        if let equipment = equipment {
            pricePerHr = equipment.pricePerHour
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()

          
            if let fieldAreaText = textField.text, let fieldArea = Double(fieldAreaText) {
                let totalPrice = fieldArea * pricePerHr
                priceLabel.text = "Total Price: \(totalPrice)"
            } else {
                priceLabel.text = "Invalid input"
            }

            return true
        }
    
    
    private func setUpMenus() {
        var actions: [UIAction] = []
        for time in timeSlot {
            let action = UIAction(title: time, handler: { [weak self] _ in
                self?.timeSlotDisplayOutlet.text = time // Update label
            })
            actions.append(action)
        }
        let timeMenu = UIMenu(title: "Select Time", children: actions)
        timeButtonOutlet.menu = timeMenu
        timeButtonOutlet.showsMenuAsPrimaryAction = true
        
        
    }

         
            
      
    
    @IBAction func proceedToPayButtonTapped(_ sender: Any) {
        
        //
        guard let equipment = equipment,
              let fieldAreaText = fieldAreaTextField.text,
              let fieldArea = Double(fieldAreaText),
              let timeSlot = timeSlotDisplayOutlet.text,
              let timeSlotEnum = TimeSlot(rawValue: timeSlot) else {
            // Show error alert
            return
        }
        
        // Create booking
        let booking = Booking(
            bookingID: UUID(),
            userID: currentUser.shared.user?.userID ?? UUID(),
            equipmentID: equipment.equipmentID,
            bookingType: .onDemand,
            bookingDate: datePicker.date,
            fieldArea: fieldArea,
            status: .pending,
            timeSlot: timeSlotEnum
        )
        
        // TODO: Save booking when implemented in DataController
        
        // Navigate to payment
        performSegue(withIdentifier: "ShowPaymentSegue", sender: booking)
        
    }
    
    
}
