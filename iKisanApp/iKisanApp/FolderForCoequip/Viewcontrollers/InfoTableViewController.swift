//
//  InfoTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 22/01/25.
//

import UIKit

class InfoTableViewController: UITableViewController {

    
    @IBOutlet weak var ImageLabel: UIImageView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var hostName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

 

    @IBAction func viewButtomTapped(_ sender: Any) {
    }
    
    
//    @IBAction func AddfarmerbuttonTapped(_ sender: Any) {
//        //        let selectedVC = storyboard?.instantiateViewController(withIdentifier: "goTopersonList") as! SelectPeopleViewController
//        //            selectedVC.modalPresentationStyle = .fullScreen
//        //            present(selectedVC, animated: true, completion: nil)
//        //    }
//        
//    }
}
