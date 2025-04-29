//
//  ReviewBookingTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit
import StoreKit
protocol ReviewBookingDelegate: AnyObject {
    func didModifyBooking(_ booking: Booking)
}

class ReviewBookingTableViewController: UITableViewController, UITextFieldDelegate {
    
    var selectedDate: Date?
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
    
    
    
    var products: [Product] = []
    
   
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
      
        
        
        
        Task {
            await fetchProducts()
        }
        
        // Listen for transaction updates
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    // Handle the transaction
                    print("Received verified transaction: \(transaction.productID)")
                    
                    // Finish the transaction after handling it
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
        
        
    }
    
    
    
    // Fetch products
        func fetchProducts() async {
            do {
                let storeProducts = try await Product.products(for: ["com.exampleapp.100coins"])
                self.products = storeProducts
            } catch {
                print("Failed to fetch products: \(error)")
            }
        }
        
        // Perform Purchase
        func purchaseItem(_ product: Product, quantity: Int) async {
            print("inside quantity :\(quantity)")
            for i in 1...quantity {
                print("inside for quantity :\(quantity)")
                    do {
                        print("Attempting purchase \(i) for product ID: \(product.id)")
//                        let result = try await product.purchase()
                        let result = try await product.purchase(quantity: quantity)
                        print("result  :\(result)")
                        switch result {
                        case .success(let verification):
                            switch verification {
                            case .verified(let transaction):
                                print("Purchase \(i) successful: \(transaction)")
                                await transaction.finish()
                            case .unverified(_, let error):
                                print("Transaction \(i) unverified: \(error.localizedDescription)")
                            }
                        case .userCancelled:
                            print("User cancelled during purchase \(i).")
                            return // Stop further purchases if user cancels
                        case .pending:
                            print("Purchase \(i) is pending approval.")
                        @unknown default:
                            break
                        }
                    } catch {
                        print("Purchase \(i) failed: \(error)")
                    }
                }
        }
    
    
    
    
    
    // Helper function to check verification
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw error
        }
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
        
        guard let product = products.first else {
                print("Product not available.")
                return
            }

        guard let fieldAreaText = fieldAreaTextField.text,
                  let quantity = Int(fieldAreaText), quantity > 0 else {
                let alert = UIAlertController(title: "Invalid Input",
                                              message: "Please enter a valid number of hours (quantity).",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
//            quantity
            return
            }
        print("quantity :\(quantity)")
                Task {
                    print("Inside task quantity :\(quantity)")
                    await purchaseItem(product, quantity: quantity)
                    }
                
                
                print("something")
                
            }
            
        //        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        //        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
        //            paymentVC.booking = newBooking
        //            paymentVC.modalPresentationStyle = .fullScreen
        //            navigationController?.pushViewController(paymentVC, animated: true)
        //        }
        //    }
            
            override func viewDidAppear(_ animated: Bool) {
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







