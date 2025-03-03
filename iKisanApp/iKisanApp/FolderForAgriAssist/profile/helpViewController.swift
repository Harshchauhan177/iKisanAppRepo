//
//  helpViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 28/02/25.
//

import UIKit

class helpViewController: UIViewController{

    @IBOutlet weak var needhelpview: UIView!
    @IBOutlet weak var mailUsView: UIView!
   
    @IBOutlet weak var teamView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Help Center"
        needhelpview.layer.cornerRadius = 8
        mailUsView.layer.cornerRadius = 10
        teamView.layer.cornerRadius = 10
    }
    
    @IBAction func emailTapped(_ sender: UIButton) {
        if let url = URL(string: "mailto:support@example.com"){
            UIApplication.shared.open(url)
        }
    }
    
    
   
}
//UIApplication.shared.open(url)
