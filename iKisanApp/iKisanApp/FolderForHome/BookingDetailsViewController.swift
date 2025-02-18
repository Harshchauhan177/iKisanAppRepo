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
        imageView.layer.cornerRadius = 7
        backgroundCollectionView.layer.cornerRadius = 10
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    private func setupUI() {
        guard let booking = booking, let equipment = equipment else {
         
            return
        }
        
      
        
        // Set equipment details
        imageView.image = UIImage(named: equipment.equipmentImage)
        imageView.layer.cornerRadius = 10
        equipmentNameLabel.text = equipment.name
        //locationLabel.text = equipment.location
        
        // Format and set date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        let dateString = dateFormatter.string(from: booking.bookingDate)
        dateLabel.text = dateString
        
        // Set other booking details
        timeSlotLabel.text = booking.timeSlot.rawValue
        fieldAreaLabel.text = "\(booking.fieldArea) acres"
        statusLabel.text = booking.status.rawValue
        
        // Calculate and set price
        let totalPrice = equipment.pricePerHour * booking.fieldArea
        priceLabel.text = "₹\(totalPrice)"
        
         //Set status label color based on booking status
        switch booking.status {
        case .confirmed:
            statusLabel.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        case .pending:
            statusLabel.textColor = .systemOrange
        case .completed:
            statusLabel.textColor = .systemGray
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
