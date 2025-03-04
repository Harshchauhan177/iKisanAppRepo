//
//  changePasswordViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 03/03/25.
//

import UIKit

class changePasswordViewController: UIViewController {

    @IBOutlet weak var currentPassword: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var reTypeNewPassword: UITextField!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Change Password"
        currentPassword.placeholder = "Current Password"
        newPassword.placeholder = "New Password"
        reTypeNewPassword.placeholder = "Re-Type New Password"
    }
    
    @IBAction func ChangePasswordButton(_ sender: Any) {
        guard let currentPasswordText = currentPassword.text, !currentPasswordText.isEmpty,
              let newPasswordText = newPassword.text, !newPasswordText.isEmpty,
              let reTypeNewPasswordText = reTypeNewPassword.text, !reTypeNewPasswordText.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
        
        guard newPasswordText == reTypeNewPasswordText else {
            showAlert(message: "New Password and Re-Type New Password do not match.")
            return
        }
        
        guard newPasswordText.count >= 8 else {
            showAlert(message: "New Password must be at least 8 characters long.")
            return
        }
        
        let specialCharacterRegex = ".*[^A-Za-z0-9].*"
        let specialCharacterTest = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex)
        
        guard specialCharacterTest.evaluate(with: newPasswordText) else {
            showAlert(message: "New Password must contain at least one special character.")
            return
        }
        
        // If all validations pass
        showAlert(message: "Password has been changed successfully.")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.currentPassword.text = ""
            self?.newPassword.text = ""
            self?.reTypeNewPassword.text = ""
        }
        alert.addAction(okAction)
        present(alert, animated: true)
        
    }
    
}
