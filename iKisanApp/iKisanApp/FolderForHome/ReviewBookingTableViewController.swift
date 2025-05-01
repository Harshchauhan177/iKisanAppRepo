//
//  ReviewBookingTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit
import Razorpay

protocol ReviewBookingDelegate: AnyObject {
    func didModifyBooking(_ booking: Booking)
}

class ReviewBookingTableViewController: UITableViewController, UITextFieldDelegate, RazorpayPaymentCompletionProtocol {
    var razorpay : RazorpayCheckout!
    var selectedDate: Date?
    var timeSlot = ["Morning","Afternoon","Evening"]
    var locationA: String?
    var pricePerHr: Double = 100
    var payableAmount: Double = 0
    
    var equipment: Equipment? {
        didSet {
            if isViewLoaded {
                updateData()
            }
        }
    }
    
    @IBOutlet var tableViewR: UITableView!
    
    
    var bookingSource: BookingSource = .home // Default to home
    
    weak var delegate: ReviewBookingDelegate?
    var isModifying: Bool = false
    var booking: Booking?
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var fieldAreaTextField: UITextField!
    
    @IBOutlet var timeButtonOutlet: UIButton!
    
    @IBOutlet var timeSlotDisplayOutlet: UILabel!
    @IBOutlet var priceLabel: UILabel!
   
    @IBOutlet weak var proceedToPay: UIButton?
    
    @IBOutlet weak var modifyButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI based on modification mode
        configureUIForModification()
        
        if let equipment = equipment {
            updateData()
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
        setUpMenus()
    }
    
    private func configureUIForModification() {
        // Force unwrap protection for outlets
        guard let modifyButton = modifyButton,
              let proceedToPay = proceedToPay else {
            print("Error: Buttons not connected in storyboard")
            return
        }
        
        // Set visibility based on mode
        modifyButton.isHidden = !isModifying
        proceedToPay.isHidden = isModifying
        
        // Pre-fill form if modifying
        if isModifying, let booking = booking {
            // Set the date picker's date from the booking
            datePicker.date = booking.bookingDate
            fieldAreaTextField.text = String(booking.fieldArea)
            timeSlotDisplayOutlet.text = booking.timeSlot.rawValue
        } else if let selectedDate = selectedDate {
            // If not modifying but we have a selected date, use that
            datePicker.date = selectedDate
        }
    }

    func updateData() {
        guard let equipment = equipment else { return }
        
        locationLabel.text = equipment.location
        datePicker.date = selectedDate ?? Date()
        pricePerHr = equipment.pricePerHour
        
        // Update any other UI elements with equipment data
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()

          
            if let fieldAreaText = textField.text, let fieldArea = Double(fieldAreaText) {
                let totalPrice = fieldArea * pricePerHr
                priceLabel.text = "Total Price: \(totalPrice)"
                self.payableAmount = totalPrice
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

    @IBAction func modifyButtonTapped(_ sender: Any) {
        guard let equipment = equipment,
              let fieldAreaText = fieldAreaTextField.text,
              let fieldArea = Double(fieldAreaText),
              let timeSlot = timeSlotDisplayOutlet.text,
              let timeSlotEnum = TimeSlot(rawValue: timeSlot),
              var modifiedBooking = booking else {
            // Show error alert
            return
        }
        
        // Update booking with modified values
        modifiedBooking.bookingDate = datePicker.date
        modifiedBooking.fieldArea = fieldArea
        modifiedBooking.timeSlot = timeSlotEnum
        
        // Notify delegate of modification
        delegate?.didModifyBooking(modifiedBooking)
        
        // Pop back to previous screen
        navigationController?.popViewController(animated: true)
        
        
    }
    
    @IBAction func proceedToPayButtonTapped(_ sender: Any) {
        // Only proceed if not in modification mode
        guard !isModifying else { return }
        
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
            bookingType: .prebooking,
            bookingDate: datePicker.date,
            fieldArea: fieldArea,
            status: .pending,
            timeSlot: timeSlotEnum,
            source: bookingSource
        )
        
        // Present PaymentViewController
//        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
//        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
//            paymentVC.booking = newBooking
//            paymentVC.modalPresentationStyle = .automatic
//            
//            let navController = UINavigationController(rootViewController: paymentVC)
//            present(navController, animated: true, completion: nil)
//        }
        
        let option : [String:Any] = [
            "amount": String(self.payableAmount * 100),
            "currency": "INR",
            "description": "How to user razor pay payment gatway",
            "image": "https://images.app.goo.gl/ii2mtoFGJhbmkkea7",
            "name":"harsh Kumar",
            "prefill": [
//                "email": "harsh7617rajput@gmail.com"  Your RazorPay EmailId
                // TODO: Fetch Email and set the field
            ],
            "theme": [
                "color": "#528FF0"
            ],
            "notes": [
                "equipment_id": equipment.equipmentID.uuidString
            ]
        ]
        razorpay.open(option)
        
        
    }
    
    
//        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
//        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
//            paymentVC.booking = newBooking
//            paymentVC.modalPresentationStyle = .fullScreen
//            navigationController?.pushViewController(paymentVC, animated: true)
//        }
//    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alert = UIAlertController(title: "Failure", message: str, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
        
    func onPaymentSuccess(_ payment_id: String) {
         let alert = UIAlertController(title: "Sucess", message: "Payment Id \(payment_id)", preferredStyle: .alert)
         let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
         alert.addAction(okay)
        
        Task {
            // TODO: INSERT INTO DB WHERE EMAIL = (email) VALUES (payment_id)
        }
         self.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        razorpay = RazorpayCheckout.initWithKey("rzp_test_A9W91a51kUjKmX", andDelegate: self)
        super.viewDidAppear(animated)

        // Apply shadow to the whole table view
        tableViewR.layer.shadowColor = UIColor.black.cgColor
        tableViewR.layer.shadowOpacity = 0.2
        tableViewR.layer.shadowOffset = CGSize(width: 0, height: 3)
        tableViewR.layer.shadowRadius = 8
        tableViewR.layer.masksToBounds = false
        tableViewR.layer.cornerRadius = 13  // Matches your UI style
    }
}
