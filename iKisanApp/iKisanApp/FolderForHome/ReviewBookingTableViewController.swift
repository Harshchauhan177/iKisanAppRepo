//
//  ReviewBookingTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit
import Razorpay
import Foundation
// Import for accessing AuthManager
import Supabase
protocol ReviewBookingDelegate: AnyObject {
    func didModifyBooking(_ booking: Booking)
}

class ReviewBookingTableViewController: UITableViewController, UITextFieldDelegate, RazorpayPaymentCompletionProtocol, BookingLocationPickerDelegate {
    var razorpay : RazorpayCheckout!
    var selectedDate: Date?
    var timeSlot = ["Morning","Afternoon","Evening"]
    var bookingLocation: Location? // Store location for this booking
    // Track if the current selection is available
    private var isEquipmentAvailable = true
    var pricePerHr: Double = 100
    var payableAmount: Double = 0
    var thisBooking: Booking?
    var equipmentLocation: String? // New property to store equipment location

    var equipment: Equipment? {
        didSet {
            if isViewLoaded {
                updateData()
            }
        }
    }
    
    @IBOutlet var tableViewR: UITableView!
    
    
    var bookingSource: BookingSource? // Changed from implicitly unwrapped optional to regular optional
    
    weak var delegate: ReviewBookingDelegate?
    var isModifying: Bool = false
    var booking: Booking?
    
    @IBOutlet var locationLabel: UILabel! {
        didSet {
            // Make the label visually appear interactive
            locationLabel.isUserInteractionEnabled = true
            
            // Add a tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(locationLabelTapped))
            locationLabel.addGestureRecognizer(tapGesture)
            
            // Style to indicate it's tappable
            locationLabel.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0) // iKisan green color
            locationLabel.font = UIFont.systemFont(ofSize: locationLabel.font.pointSize, weight: .medium)
            
            // Add a map pin icon to visually indicate this is for location
            if let locationIcon = UIImage(systemName: "location.fill") {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = locationIcon.withTintColor(UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0))
                imageAttachment.bounds = CGRect(x: 0, y: -3, width: locationIcon.size.width, height: locationIcon.size.height)
                
                // Create attributed string with icon
                let fullString = NSMutableAttributedString()
                fullString.append(NSAttributedString(attachment: imageAttachment))
                fullString.append(NSAttributedString(string: " ")) // Space after icon
                
                // Set the attributed text when there's an actual location text
                if let existingText = locationLabel.text, !existingText.isEmpty {
                    fullString.append(NSAttributedString(string: existingText))
                    locationLabel.attributedText = fullString
                }
            }
            
            // Add an underline to indicate it's interactive
            locationLabel.layer.borderColor = UIColor.lightGray.cgColor
            locationLabel.layer.borderWidth = 0.5
            locationLabel.layer.cornerRadius = 4
            locationLabel.clipsToBounds = true
            
            // Add some padding
            locationLabel.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    
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
        
        // Setup location cell to use standard iOS disclosure behavior
        setupLocationCell()
        
        // Set minimum date to today to prevent booking in the past
        let today = Calendar.current.startOfDay(for: Date())
        datePicker.minimumDate = today
        
        // If the current date is before today, set it to today
        if datePicker.date < today {
            datePicker.date = today
        }
        
        // Initialize selectedDate with the current date picker value
        selectedDate = datePicker.date
        
        // Update available time slots for the initial date
        updateAvailableTimeSlots()
        
        // Set up date picker action
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    // MARK: - Equipment Availability Check
    
    // Handle date picker value changes
    @objc private func datePickerValueChanged() {
        // Update the selected date
        selectedDate = datePicker.date
        
        // Reset time slot if date changes
        if let currentTimeSlot = timeSlotDisplayOutlet.text, !currentTimeSlot.isEmpty {
            // Check if the current time slot is still available with the new date
            if !checkEquipmentAvailability() {
                // If not available, reset the time slot
                timeSlotDisplayOutlet.text = ""
                
                // Show a message to the user
                let alert = UIAlertController(
                    title: "Time Slot Not Available",
                    message: "The previously selected time slot is not available on this date. Please select a different time slot.",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default)
                okAction.setValue(UIColor.init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
                alert.addAction(okAction)
                present(alert, animated: true)
            }
        }
        
        // Update available time slots for the menu
        updateAvailableTimeSlots()
    }
    
    // Update available time slots based on the selected date
    private func updateAvailableTimeSlots() {
        guard let equipment = equipment, let selectedDate = selectedDate else { return }
        
        // Get the data controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        
        let dataController = sceneDelegate.dataController
        
        // Get available time slots for the selected date and equipment
        let availableTimeSlots = dataController.getAvailableTimeSlots(equipmentID: equipment.equipmentID, date: selectedDate)
        
        // Convert TimeSlot enum values to strings
        let availableSlotStrings = availableTimeSlots.map { $0.rawValue }
        
        // Update the time slot menu with only available slots
        setUpTimeSlotMenu(with: availableSlotStrings)
    }
    
    // Check if equipment is available for booking on selected date and time slot
    private func checkEquipmentAvailability() -> Bool {
        guard let equipment = equipment,
              let selectedDate = selectedDate,
              let timeSlotText = timeSlotDisplayOutlet.text,
              let timeSlot = TimeSlot(rawValue: timeSlotText) else {
            return true // If we can't check, assume it's available
        }
        
        // Get the data controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return true // If we can't check, assume it's available
        }
        
        let dataController = sceneDelegate.dataController
        
        // Check if the equipment is available for the selected date and time slot
        let available = dataController.isEquipmentAvailable(equipmentID: equipment.equipmentID, date: selectedDate, timeSlot: timeSlot)
        
        // If we're modifying an existing booking, the current time slot is always available
        let isCurrentBookingTimeSlot = isModifying && booking?.timeSlot.rawValue == timeSlotText && Calendar.current.isDate(booking?.bookingDate ?? Date(), inSameDayAs: selectedDate)
        
        // Equipment is available if it's either generally available or it's the current booking's time slot
        return available || isCurrentBookingTimeSlot
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
            
            // Set location from booking if available
            if let bookingLoc = booking.bookingLocation {
                self.bookingLocation = bookingLoc // Store for future updates
                
                // Update display
                if let address = bookingLoc.address, !address.isEmpty {
                    locationLabel.text = address
                } else {
                    locationLabel.text = "Location: \(bookingLoc.latitude), \(bookingLoc.longitude)"
                }
            } else {
                // If booking doesn't have a location, try to use user's default location
                if let userLocation = AuthManager.shared.currentUser?.location {
                    self.bookingLocation = userLocation
                    
                    // Update display
                    if let address = userLocation.address, !address.isEmpty {
                        locationLabel.text = address
                    } else {
                        locationLabel.text = "Location: \(userLocation.latitude), \(userLocation.longitude)"
                    }
                }
            }
        } else if let selectedDate = selectedDate {
            // If not modifying but we have a selected date, use that
            datePicker.date = selectedDate
        }
    }

    func updateData() {
        guard let equipment = equipment else { return }
        
        // Safely unwrap all IBOutlets to prevent crashes
        if let locationLabel = locationLabel {
            // First check if we already have a custom location set for this booking (user already modified it)
            if let bookingLoc = bookingLocation {
                if let address = bookingLoc.address, !address.isEmpty {
                    locationLabel.text = address
                } else {
                    locationLabel.text = "Location: \(bookingLoc.latitude), \(bookingLoc.longitude)"
                }
            } 
            // Next, use the farmer's (user's) location from their profile - this is the default behavior
            else if let user = AuthManager.shared.currentUser {
                if let userLocation = user.location {
                    if let address = userLocation.address, !address.isEmpty {
                        locationLabel.text = address
                    } else {
                        locationLabel.text = "Location: \(userLocation.latitude), \(userLocation.longitude)"
                    }
                    // Store user's location for this booking by default
                    bookingLocation = userLocation
                } else if let address = user.address, !address.isEmpty {
                    // If user has an address directly on the user object
                    locationLabel.text = address
                    bookingLocation = Location(latitude: user.latitude, longitude: user.longitude, address: address)
                } else if user.latitude != 0.0 || user.longitude != 0.0 {
                    // If user only has coordinates
                    let locationString = "Location: \(user.latitude), \(user.longitude)"
                    locationLabel.text = locationString
                    bookingLocation = Location(latitude: user.latitude, longitude: user.longitude, address: nil)
                } else {
                    // Only as a last resort fallback to equipment location
                    locationLabel.text = equipmentLocation ?? equipment.location
                }
            } else {
                // Fallback to equipment location if no user info is available
                locationLabel.text = equipmentLocation ?? equipment.location
            }
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
    
    // Handle tap on location label to update booking location using map interface
    @objc func locationLabelTapped() {
        // Get current location data to initialize the picker
        var initialLat: Double = 0.0
        var initialLong: Double = 0.0
        var initialAddress: String? = nil
        
        // Try to use existing booking location first
        if let existingLocation = bookingLocation {
            initialLat = existingLocation.latitude
            initialLong = existingLocation.longitude
            initialAddress = existingLocation.address
        } 
        // Otherwise use user's location from profile if available
        else if let userLocation = AuthManager.shared.currentUser?.location {
            initialLat = userLocation.latitude
            initialLong = userLocation.longitude
            initialAddress = userLocation.address
        }
        // Last resort - use user's direct coordinates if available
        else if let user = AuthManager.shared.currentUser, user.latitude != 0.0 || user.longitude != 0.0 {
            initialLat = user.latitude
            initialLong = user.longitude
            initialAddress = user.address
        }
        
        // Create and configure the location picker
        let locationPicker = BookingLocationPickerViewController(
            latitude: initialLat,
            longitude: initialLong,
            address: initialAddress
        )
        
        // Set delegate to receive selected location
        locationPicker.delegate = self
        
        // Wrap in navigation controller for proper presentation with buttons
        let navController = UINavigationController(rootViewController: locationPicker)
        navController.modalPresentationStyle = .fullScreen
        
        // Present the location picker modally
        present(navController, animated: true)
    }
    
    
    // MARK: - Location Cell Setup
    
    private func setupLocationCell() {
        // Update location label style to make it look like a standard label (not interactive)
        if let locationLabel = locationLabel {
            // Add proper styling for the label
            locationLabel.textColor = .black
            locationLabel.font = UIFont.systemFont(ofSize: locationLabel.font.pointSize, weight: .regular)
            
            // Update the label's parent cell to have disclosure indicator
            if let cell = locationLabel.superview?.superview as? UITableViewCell {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }
            
            // Make sure the cell responds to selection instead of label taps
            if let recognizers = locationLabel.gestureRecognizers {
                for recognizer in recognizers {
                    locationLabel.removeGestureRecognizer(recognizer)
                }
            }
            
            // Remove styling that made the label look tappable
            locationLabel.layer.borderWidth = 0
            locationLabel.layer.cornerRadius = 0
            locationLabel.clipsToBounds = false
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row to provide visual feedback
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Identify if this is the location cell
        // We need to determine which indexPath corresponds to the location cell
        // This depends on your specific table layout
        let locationCellSection = 0 // Adjust based on your table structure
        let locationCellRow = 0    // Adjust based on your table structure
        
        if indexPath.section == locationCellSection && indexPath.row == locationCellRow {
            // This is the location cell, open the location picker
            openLocationPicker()
        }
    }
    
    private func openLocationPicker() {
        // Get current location data to initialize the picker
        var initialLat: Double = 0.0
        var initialLong: Double = 0.0
        var initialAddress: String? = nil
        
        // Try to use existing booking location first
        if let existingLocation = bookingLocation {
            initialLat = existingLocation.latitude
            initialLong = existingLocation.longitude
            initialAddress = existingLocation.address
        } 
        // Otherwise use user's location from profile if available
        else if let userLocation = AuthManager.shared.currentUser?.location {
            initialLat = userLocation.latitude
            initialLong = userLocation.longitude
            initialAddress = userLocation.address
        }
        // Last resort - use user's direct coordinates if available
        else if let user = AuthManager.shared.currentUser, user.latitude != 0.0 || user.longitude != 0.0 {
            initialLat = user.latitude
            initialLong = user.longitude
            initialAddress = user.address
        }
        
        // Create and configure the location picker
        let locationPicker = BookingLocationPickerViewController(
            latitude: initialLat,
            longitude: initialLong,
            address: initialAddress
        )
        
        // Set delegate to receive selected location
        locationPicker.delegate = self
        
        // Present the location picker using navigation stack for iOS standard behavior
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    // MARK: - BookingLocationPickerDelegate
    
    func didUpdateLocation(latitude: Double, longitude: Double, address: String?) {
        // Create a Location object from the selected coordinates and address
        let selectedLocation = Location(latitude: latitude, longitude: longitude, address: address)
        
        // Store the location for the booking
        self.bookingLocation = selectedLocation
        
        // Update the location display in the UI
        if let address = address, !address.isEmpty {
            locationLabel.text = address
        } else {
            locationLabel.text = "Location: \(latitude), \(longitude)"
        }
    }
    
    private func setUpMenus() {
        // Set up the initial time slot menu with all time slots
        setUpTimeSlotMenu(with: timeSlot)
    }
    
    // Set up the time slot menu with the provided time slots
    private func setUpTimeSlotMenu(with availableTimeSlots: [String]) {
        var actions: [UIAction] = []
        
        // If there are no available time slots, show a message
        if availableTimeSlots.isEmpty {
            let action = UIAction(title: "No available time slots", attributes: .disabled, handler: { _ in })
            actions.append(action)
        } else {
            // Create actions for each available time slot
            for time in availableTimeSlots {
                let action = UIAction(title: time, handler: { [weak self] _ in
                    self?.timeSlotDisplayOutlet.text = time // Update label
                })
                actions.append(action)
            }
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
        
        // Update booking location if it's been changed
        if let customLocation = bookingLocation {
            modifiedBooking.bookingLocation = customLocation
        }
        
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
        
        // Check if the equipment is available for the selected date and time slot
        if !checkEquipmentAvailability() {
            // Show an alert to the user that the equipment is not available
            let alert = UIAlertController(
                title: "Equipment Not Available",
                message: "This equipment is already booked for the selected date and time slot. Please choose a different date or time slot.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            okAction.setValue(UIColor.init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
            alert.addAction(okAction)
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
            // Default to onDemand for Home tab bookings when source is nil
            bookingType = .onDemand
        }
        
        // Get location for booking - use the bookingLocation property we've already set
        // It should already contain either a custom location or the user's default location
        // If it's nil, the booking will be created without a location
        
        let newBooking = Booking(
            bookingID: UUID(),
            userID: currentUser.shared.user?.userID ?? UUID(),
            equipmentID: equipment.equipmentID,
            bookingType: bookingType,
            bookingDate: datePicker.date,
            fieldArea: fieldArea,
            status: .pending, // Always set status to pending by default
            timeSlot: timeSlotEnum,
            source: bookingSource ?? .home, // Provide a default .home value if bookingSource is nil
            bookingLocation: self.bookingLocation // Include the location in the booking
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
//        dataController.addBooking(newBooking)
    }
    
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alert = UIAlertController(title: "Failure", message: str, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func addThisBooking() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        guard let booking = self.thisBooking else { return }
        _ = sceneDelegate.dataController.addBooking(booking)
    }
        
    func onPaymentSuccess(_ payment_id: String) {
        struct _TempUpdate: Codable {
            var status: BookingStatus = .confirmed
        }
        
        // Keep a reference to the current booking
        guard let currentBooking = thisBooking else { return }
        
        Task {
            addThisBooking()
            do {
                try await SupabaseManager.shared.client
                    .from("bookings")
                    .update(_TempUpdate())
                    .eq("bookingID", value: currentBooking.bookingID)
                    .execute()
            } catch {
                print("Error updating booking status: \(error)")
                // Continue with the flow even if the update fails
                // This ensures the user experience isn't interrupted by backend issues
            }
                
            DispatchQueue.main.async {
                // Get the SceneDelegate to access the root controller
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = windowScene.delegate as? SceneDelegate,
                      let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController else {
                    print("Error: Could not access tab bar controller")
                    return
                }
                
                // First determine which tab to redirect to based on booking source
                var targetTabIndex = 0 // Default to Home tab (index 0)
                
                // Check the source of the booking to determine where to redirect
                switch currentBooking.source {
                case .home:
                    // If booking was initiated from Home tab, always return to Home tab
                    targetTabIndex = 0
                    // Post notification for regular booking
                    NotificationCenter.default.post(name: .bookingAdded, object: nil)
                    print("Redirecting to Home tab after booking from Home")
                    
                case .prebooking:
                    // If initiated from Prebooking tab, find and use that tab's index
                    if let viewControllers = tabBarController.viewControllers {
                        for (index, viewController) in viewControllers.enumerated() {
                            if let navController = viewController as? UINavigationController,
                               navController.viewControllers.first is PrebookingViewController {
                                targetTabIndex = index
                                break
                            }
                        }
                    }
                    // Post notification for prebooking
                    NotificationCenter.default.post(
                        name: Notification.Name.preBookingAdded,
                        object: nil,
                        userInfo: ["booking": currentBooking]
                    )
                    print("Redirecting to Prebooking tab after booking from Prebooking")
                    
                case .coEquip:
                    // For coEquip, find the appropriate tab (or default to Home)
                    // Post appropriate notification
                    NotificationCenter.default.post(name: .bookingAdded, object: nil)
                    print("Redirecting to Home tab after coEquip booking")
                    
                default:
                    // For any other source, default to Home tab
                    NotificationCenter.default.post(name: .bookingAdded, object: nil)
                    print("Redirecting to Home tab (default case)")
                }
                
                // Switch to the target tab
                tabBarController.selectedIndex = targetTabIndex
                
                // Dismiss all modal presentations to return to the tab bar
                self.view.window?.rootViewController?.dismiss(animated: true) {
                    // Pop to root of navigation controller if needed
                    if let navController = tabBarController.selectedViewController as? UINavigationController {
                        navController.popToRootViewController(animated: false)
                    }
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
