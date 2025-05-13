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

class ReviewBookingTableViewController: UITableViewController, UITextFieldDelegate,RazorpayPaymentCompletionProtocol {
    var razorpay : RazorpayCheckout!
    var selectedDate: Date?
    var timeSlot = ["Morning","Afternoon","Evening"]
    var locationA: String?
    var pricePerHr: Double = 100
    var payableAmount: Double = 0
    var thisBooking: Booking?

    var equipment: Equipment? {
        didSet {
            if isViewLoaded {
                updateData()
            }
        }
    }
    
    @IBOutlet var tableViewR: UITableView!
    
    
    var bookingSource: BookingSource! // Default to home
    
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
        
        // Setup Dynamic Text support
        setupDynamicTextSupport()
        
        // Configure UI based on modification mode
        configureUIForModification()
        
        if equipment != nil {
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
    
    private func setupDynamicTextSupport() {
        // Register for content size category changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        
        // Apply dynamic text settings to all labels
        applyDynamicTextStyles()
    }
    
    private func applyDynamicTextStyles() {
        // Map of labels to their base font sizes and styles
        let labelConfigs: [(UILabel?, CGFloat, UIFont.Weight, UIFont.TextStyle)] = [
            // Labels with their size, weight, and text style
            (locationLabel, 16, .regular, .body),
            (timeSlotDisplayOutlet, 16, .regular, .body),
            (priceLabel, 16, .semibold, .headline)
        ]
        
        // Apply settings to each label
        for (label, size, weight, style) in labelConfigs {
            if let lbl = label {
                // Enable dynamic type adjustment
                lbl.adjustsFontForContentSizeCategory = true
                
                // Create a base font of appropriate size and weight
                let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
                
                // Use UIFontMetrics to get a properly scaled version
                lbl.font = UIFontMetrics(forTextStyle: style).scaledFont(for: baseFont)
            }
        }
        
        // Configure text field with dynamic type
        if let textField = fieldAreaTextField {
            textField.adjustsFontForContentSizeCategory = true
            let baseFont = UIFont.systemFont(ofSize: 16, weight: .regular)
            textField.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        }
    }
    
    @objc private func contentSizeCategoryDidChange() {
        // When text size changes, reapply the styles and reload
        applyDynamicTextStyles()
        tableView.reloadData() // Reload the table to adjust cell heights
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
        
        // Safely unwrap all IBOutlets to prevent crashes
        if let locationLabel = locationLabel {
            locationLabel.text = equipment.location
        }
        
        if let datePicker = datePicker {
            datePicker.date = selectedDate ?? Date()
        }
        
        pricePerHr = equipment.pricePerHour
        
        // Update price label if available
        if let priceLabel = priceLabel {
            priceLabel.text = "Price per hour: ₹\(pricePerHr)"
        }
        
        // Safely update time slot display if available
        if let timeSlotDisplay = timeSlotDisplayOutlet {
            // Set default time slot if not already set
            if timeSlotDisplay.text?.isEmpty ?? true {
                timeSlotDisplay.text = timeSlot.first ?? "Morning"
            }
        }
        
        // Safely configure buttons
        if let proceedButton = proceedToPay {
            proceedButton.titleLabel?.adjustsFontForContentSizeCategory = true
            let buttonFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
            proceedButton.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: buttonFont)
        }
        
        if let modifyButton = modifyButton {
            modifyButton.titleLabel?.adjustsFontForContentSizeCategory = true
            let buttonFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
            modifyButton.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: buttonFont)
        }
    }
    
    // Configure the view controller with equipment data when coming from CreateRequestViewController
    func configure(with equipment: Equipment, dataController: DataController, date: Date) {
        self.equipment = equipment
        self.selectedDate = date
        self.bookingSource = .home // Set source to home when coming from HomeViewController search
        
        // Don't call updateData() here - it will be called when the view is loaded
        // via the didSet observer on equipment, or in viewDidLoad if view is already loaded
        if isViewLoaded {
            updateData()
        }
        
        // Initialize Razorpay if needed
        if razorpay == nil {
            razorpay = RazorpayCheckout.initWithKey("rzp_test_A9W91a51kUjKmX", andDelegate: self)
        }
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
        // Set booking type based on the source
        let bookingType: BookingType
        switch bookingSource {
        case .home:
            bookingType = .onDemand
        case .prebooking:
            bookingType = .prebooking
        case .coEquip:
            bookingType = .coEquip
        default:
            bookingType = .prebooking
        }
        
        let newBooking = Booking(
            bookingID: UUID(),
            userID: currentUser.shared.user?.userID ?? UUID(),
            equipmentID: equipment.equipmentID,
            bookingType: bookingType,
            bookingDate: datePicker.date,
            fieldArea: fieldArea,
            status: .pending, // Always set status to pending by default
            timeSlot: timeSlotEnum,
            source: bookingSource
        )
        thisBooking = newBooking
        
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
                "bookingId": newBooking.bookingID.uuidString
            ]
        ]
        razorpay.open(option)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        let dataController = sceneDelegate.dataController
        dataController.addBooking(newBooking)
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alert = UIAlertController(title: "Failure", message: str, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
        
    func onPaymentSuccess(_ payment_id: String) {
        struct _TempUpdate: Codable {
            var status: BookingStatus = .confirmed
        }
        Task {
            try! await SupabaseManager.shared.client
                .from("bookings")
                .update(_TempUpdate())
                .eq("bookingID", value: thisBooking?.bookingID)
                .execute()
            DispatchQueue.main.async {
                // Navigate to HomeViewController
                let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
                if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController,
                   let navigationController = self.navigationController {
                    
                    // Get the data controller from SceneDelegate
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let sceneDelegate = windowScene.delegate as? SceneDelegate {
                        homeVC.dataController = sceneDelegate.dataController
                    }
                    
                    // Clear the navigation stack and set HomeViewController as the root
                    navigationController.viewControllers = [homeVC]
                    
                    // Post notification so HomeViewController knows a booking was added
                    NotificationCenter.default.post(name: .bookingAdded, object: nil)
                }
            }
        }
    }
    
//        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
//        if let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
//            paymentVC.booking = newBooking
//            paymentVC.modalPresentationStyle = .fullScreen
//            navigationController?.pushViewController(paymentVC, animated: true)
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        razorpay = RazorpayCheckout.initWithKey("rzp_test_A9W91a51kUjKmX", andDelegate: self)
        super.viewDidAppear(animated)

        // Apply shadow to the whole table view
        if let tableViewR = tableViewR {
            tableViewR.layer.shadowColor = UIColor.black.cgColor
            tableViewR.layer.shadowOpacity = 0.2
            tableViewR.layer.shadowOffset = CGSize(width: 0, height: 3)
            tableViewR.layer.shadowRadius = 8
            tableViewR.layer.masksToBounds = false
            tableViewR.layer.cornerRadius = 13  // Matches your UI style
        }
    }
    
    deinit {
        // Remove notification observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
}
