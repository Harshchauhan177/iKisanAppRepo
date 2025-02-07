//
//  BookingDetailsViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 23/01/25.
//

import UIKit

class BookingDetailsViewController: UIViewController {

    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var priceLabel: UILabel!
   
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var hostedByLabel: UILabel!
    @IBOutlet var providerNameLabel: UILabel!
    @IBOutlet var mobileNoLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var backgroundCollectionView: UIView!
    
    var equipment: Equipment?
    var booking: Booking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 7
        backgroundCollectionView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    
    
    private func updateUI() {
        guard let equipment = equipment else { return }
        
        // Update equipment details
        imageView.image = UIImage(named: equipment.equipmentImage)
        equipmentNameLabel.text = equipment.name
        priceLabel.text = "₹\(equipment.pricePerHour)/hr"
        ratingLabel.text = "⭐️ \(equipment.rating)"
        
        // Update booking details if available
        if let booking = booking {
            //dateLabel.text = booking.formattedDate
            
            // Update status-specific UI
            switch booking.status {
            case .pending:
                title = "Pending Booking"
            case .confirmed:
                title = "Confirmed Booking"
            case .completed:
                title = "Completed Booking"
            }
        }
    }

    @IBAction func viewButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func cancelBookingTapped(_ sender: Any) {
    }
    
}
