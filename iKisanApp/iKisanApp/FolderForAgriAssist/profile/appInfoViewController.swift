//
//  appInfoViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 03/03/25.
//

import UIKit

class appInfoViewController: UIViewController {

    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var aboutCompanyView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        infoView.layer.cornerRadius = 10
        aboutCompanyView.layer.cornerRadius = 10
    }

}
