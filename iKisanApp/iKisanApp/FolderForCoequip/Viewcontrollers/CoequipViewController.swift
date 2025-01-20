//
//  CoequipViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class CoequipViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem) {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchInCoequip") as! SearchViewController
            searchVC.modalPresentationStyle = .fullScreen
            present(searchVC, animated: true, completion: nil)
    }



}
