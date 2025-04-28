//
//  BookingDetailsViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 23/01/25.
//

import UIKit

class BookingDetailsViewController: UIViewController {
    
    var equipment: Equipment?
    var booking: Booking?

    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var priceLabel: UILabel!
   
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var hostedByLabel: UILabel!
    @IBOutlet var providerNameLabel: UILabel!
    @IBOutlet var mobileNoLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var backgroundCollectionView: UIView!
    

    @IBOutlet weak var fieldAreaLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var timeSlotLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print debug information
        print("BookingDetailsViewController - viewDidLoad called")
        
        // Equipment and booking data verification
        if let equipment = equipment, let booking = booking {
            print("BookingDetailsViewController - Equipment: \(equipment.name), Booking ID: \(booking.bookingID)")
        } else {
            print("ERROR: Missing equipment or booking data")
        }
        
        // Check UI outlets
        let outlets = [
            "imageView": imageView != nil,
            "backgroundCollectionView": backgroundCollectionView != nil,
            "equipmentNameLabel": equipmentNameLabel != nil,
            "dateLabel": dateLabel != nil,
            "locationLabel": locationLabel != nil,
            "fieldAreaLabel": fieldAreaLabel != nil,
            "statusLabel": statusLabel != nil,
            "timeSlotLabel": timeSlotLabel != nil,
            "priceLabel": priceLabel != nil,
            "hostedByLabel": hostedByLabel != nil,
            "providerNameLabel": providerNameLabel != nil,
            "mobileNoLabel": mobileNoLabel != nil,
            "ratingLabel": ratingLabel != nil
        ]
        
        // Log which outlets are nil
        for (name, connected) in outlets {
            if !connected {
                print("ERROR: \(name) outlet is nil in BookingDetailsViewController")
            }
        }
        
        // Apply styling to views that exist
        if let imageView = imageView {
            imageView.layer.cornerRadius = 7
        }
        
        if let backgroundView = backgroundCollectionView {
            backgroundView.layer.cornerRadius = 10
            backgroundView.applyCardShadow()
        }
        
        // Setup UI
        setupUI()
    }
    
    
    private func setupUI() {
        // Check if either booking or equipment is nil
        if booking == nil || equipment == nil {
            print("Error: Missing booking or equipment data")
            return
        }
        
        // Use local variables to avoid repeated optional unwrapping
        guard let localBooking = booking,
              let localEquipment = equipment else {
            return
        }
        
        // Verify all UI elements are properly connected before using them
        if imageView == nil || equipmentNameLabel == nil || dateLabel == nil ||
           locationLabel == nil || fieldAreaLabel == nil || statusLabel == nil ||
           timeSlotLabel == nil || priceLabel == nil || hostedByLabel == nil ||
           providerNameLabel == nil || mobileNoLabel == nil || ratingLabel == nil {
            print("ERROR: One or more UI outlets are nil in BookingDetailsViewController")
            return
        }
        
        // Set equipment details with null safety
        if let imageView = imageView {
            // Check if equipment image exists
            if let image = UIImage(named: localEquipment.equipmentImage) {
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "placeholder_equipment") // Fallback image
                print("Warning: Equipment image \(localEquipment.equipmentImage) not found")
            }
            imageView.layer.cornerRadius = 10
        }
        
        // Set text labels with null safety
        equipmentNameLabel?.text = localEquipment.name
        
        // For location, which may be empty string but not nil
        locationLabel?.text = localEquipment.location.isEmpty ? "Location not available" : localEquipment.location
        
        // For rating, ensure it's displayed properly
        ratingLabel?.text = String(format: "%.1f", localEquipment.rating)
        
        // Format and set date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        let dateString = dateFormatter.string(from: localBooking.bookingDate)
        dateLabel?.text = dateString
        
        // Set other booking details
        timeSlotLabel?.text = localBooking.timeSlot.rawValue
        fieldAreaLabel?.text = "\(localBooking.fieldArea) acres"
        statusLabel?.text = localBooking.status.rawValue
        
        // Calculate and set price
        let totalPrice = localEquipment.pricePerHour * localBooking.fieldArea
        priceLabel?.text = "₹\(totalPrice)"
        
        // Set status label color based on booking status
        if let statusLabel = statusLabel {
            switch localBooking.status {
            case .confirmed:
                statusLabel.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
            case .pending:
                statusLabel.textColor = .systemOrange
            case .completed:
                statusLabel.textColor = .systemGray
            }
        }
        
        // Set provider information placeholders while loading
        hostedByLabel?.text = "Provider"
        providerNameLabel?.text = "Loading..."
        mobileNoLabel?.text = "Loading..."
        
        // Fetch provider information from Supabase
        fetchProviderInfo(for: localBooking.userID)
    }

    // Separate method for fetching provider info
    private func fetchProviderInfo(for userId: UUID) {
        Task {
            do {
                // Try to get the provider data from Supabase using the userID
                let result = try await SupabaseManager.shared.client
                    .from("users")
                    .select("name, phone")
                    .eq("userID", value: userId.uuidString)
                    .single()
                    .execute()
                
                // Extract provider data from the response
                do {
                    if let dict = try JSONSerialization.jsonObject(with: result.data) as? [String: Any] {
                        let providerName = dict["name"] as? String ?? "Unknown"
                        let providerPhone = dict["phone"] as? String ?? "Not available"
                        
                        // Update UI on main thread with nil checks
                        await MainActor.run { [weak self] in
                            // Check if view is still loaded and self exists
                            guard let self = self, self.view.window != nil else {
                                return
                            }
                            
                            self.providerNameLabel?.text = providerName
                            self.mobileNoLabel?.text = providerPhone
                        }
                    }
                } catch {
                    print("Error parsing provider data: \(error)")
                }
            } catch {
                print("Error fetching provider data: \(error)")
            }
        }
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func cancelBookingTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Cancel Booking",
            message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
        
        print("User Wants to Cancel Booking")
        })
        
        present(alert, animated: true)
    }
    
}
