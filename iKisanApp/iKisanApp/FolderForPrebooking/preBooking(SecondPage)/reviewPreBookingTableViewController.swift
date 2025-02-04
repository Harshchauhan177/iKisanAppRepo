//
//  reviewPreBookingTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 04/02/25.
//

import UIKit

class reviewPreBookingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func sendRequestButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Request Sent", message: "Your request for Rice Harvester has been sent.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "View", style: .default, handler: { _ in
                print("View tapped")
                if let prebookingVC = self.storyboard?.instantiateViewController(withIdentifier: "PrebookingViewController") as? PrebookingViewController {
                            self.navigationController?.pushViewController(prebookingVC, animated: true)
                        }
            }))
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                print("Done tapped")
            }))
            
            present(alert, animated: true, completion: nil)
        
    }
    

    

}
