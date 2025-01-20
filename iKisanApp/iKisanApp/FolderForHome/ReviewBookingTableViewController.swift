//
//  ReviewBookingTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit

class ReviewBookingTableViewController: UITableViewController,UITextFieldDelegate {
    
    var locationA: String?
    var pricePerHr: Double? = 100
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var fieldAreaTextField: UITextField!
    
    @IBOutlet var timeButtonOutlet: UIButton!
    
    @IBOutlet var priceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationLabel.text = locationA
        fieldAreaTextField.delegate = self
        updateData()
        
//        locationLabel.text = location
//        var fieldArea = 900.0
//        //fieldArea = Double(fieldAreaTextField.text!)!
//        
//        
//        priceLabel.text = "\(pricePerHr)"
//        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func updateData() {
        
        locationLabel.text = locationA
        datePicker.date = Date()
        
        guard let fieldAreaText = fieldAreaTextField.text ,
               let fieldArea = Double(fieldAreaText),
              let price = pricePerHr
        else { return }
        
        let totalPrice = price * fieldArea
        
        priceLabel.text = "\(totalPrice)"
    }
    
  
    @IBAction func proceedToPayButtonTapped(_ sender: Any) {
    }
    
    
}
