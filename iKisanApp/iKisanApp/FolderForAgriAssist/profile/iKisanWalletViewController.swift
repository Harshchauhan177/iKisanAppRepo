//
//  iKisanWalletViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 03/03/25.
//

import UIKit

class iKisanWalletViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
    }
    
    private func setupTextField() {
        amountTextField.keyboardType = .numberPad
        amountTextField.placeholder = "Enter amount"
    }
    
    
    @IBAction func addMoneyButton(_ sender: Any) {
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            showError("Please enter an amount")
            return
        }
        
        // Check if the input is a valid integer
        guard let amount = Int(amountText) else {
            showError("Please enter a valid amount")
            return
        }
        
        // Show success alert
        let alert = UIAlertController(
            title: "Success",
            message: "Money added successfully in the iKisan wallet",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Clear the text field after successful addition
            self?.amountTextField.text = ""
        }
        // Set custom color for OK button to match app theme
        okAction.setValue(UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        // Set custom color for OK button to match app theme
        okAction.setValue(UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        
        alert.addAction(okAction)
        present(alert, animated: true)
        
    }
    
}
