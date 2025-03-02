//
//  helpViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 28/02/25.
//

import UIKit

class helpViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Help Center"

        // Do any additional setup after loading the view.
    }
    
    @IBAction func emailTapped(_ sender: UIButton) {
        if let url = URL(string: "mailto:support@example.com"){
            UIApplication.shared.open(url)
        }
    }
    
    
   
}
//UIApplication.shared.open(url)
