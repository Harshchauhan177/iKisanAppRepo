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
    
    var equipment: Equipment? {
        didSet {
            if isViewLoaded {
                updateData()
            }
        }
    }
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var fieldAreaTextField: UITextField!
    
    @IBOutlet var timeButtonOutlet: UIButton!
    
    @IBOutlet var timeSlotDisplayOutlet: UILabel!
    @IBOutlet var priceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let equipment = equipment {
           
        } else {
            // Show alert and pop back
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "No equipment selected. Please select equipment first.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
        
        fieldAreaTextField.delegate = self
        
        updateData()
        
        setUpMenus()

    }

    func updateData() {
        guard let equipment = equipment else {
            return
        }
        
        locationLabel.text = equipment.location
        datePicker.date = Date()
        pricePerHr = equipment.pricePerHour
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
        
        // Verify equipment
        guard let equipment = self.equipment else {
            return
        }
        
        // Verify field area
        guard let fieldAreaText = fieldAreaTextField.text,
              !fieldAreaText.isEmpty,
              let fieldArea = Double(fieldAreaText) else {
            let alert = UIAlertController(
                title: "Error",
                message: "Please enter a valid field area",
                preferredStyle: .alert
            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
            let okAction = UIAlertAction(title: "OK", style: .default)

            okAction.setValue(UIColor.init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
            alert.addAction(okAction)

            present(alert, animated: true)
            return
        }
        
        // Verify time slot
        guard let timeSlot = timeSlotDisplayOutlet.text,
              !timeSlot.isEmpty,
              let timeSlotEnum = TimeSlot(rawValue: timeSlot) else {
            let alert = UIAlertController(
                title: "Error",
                message: "Please select a time slot",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Create booking
        let newBooking = Booking(
            bookingID: UUID(),
            userID: currentUser.shared.user?.userID ?? UUID(),
            equipmentID: equipment.equipmentID,
            bookingType: .onDemand,
            bookingDate: datePicker.date,
            fieldArea: fieldArea,
            status: .pending,
            timeSlot: timeSlotEnum
        )
        
        // For Presenting PaymentViewController
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            paymentVC.booking = newBooking
            paymentVC.modalPresentationStyle = .automatic
            
            // Embed in a Navigation Controller
            let navController = UINavigationController(rootViewController: paymentVC)
            present(navController, animated: true, completion: nil)
        }
    }
    
//        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
//        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
//            paymentVC.booking = newBooking
//            paymentVC.modalPresentationStyle = .fullScreen
//            navigationController?.pushViewController(paymentVC, animated: true)
//        }
//    }
}
