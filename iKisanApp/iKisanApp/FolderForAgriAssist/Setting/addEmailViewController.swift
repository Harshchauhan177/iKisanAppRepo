//
//  addEmailViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 03/03/25.
//

import UIKit

class addEmailViewController: UIViewController {

    @IBOutlet weak var enterEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Email address"
        enterEmail.placeholder = "Enter Email address"
    }
   
    @IBAction func addEmailButton(_ sender: Any) {
        guard let email = enterEmail.text, isValidEmail(email) else {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid email address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Success", message: "Email added successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.enterEmail.text = ""
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
        
    }
    
}
