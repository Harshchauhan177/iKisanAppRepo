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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 7
        backgroundCollectionView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    

    @IBAction func viewButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func cancelBookingTapped(_ sender: Any) {
    }
    
}
