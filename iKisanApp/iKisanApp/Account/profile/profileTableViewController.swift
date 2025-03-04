//
//  profileTableViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 03/03/25.
//

import UIKit

class profileTableViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobNumLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    // Add text fields for editing
    private var activeTextField: UITextField?
    private var editingLabel: UILabel?
    
    // Add these properties at the top of the class
    private let userDefaults = UserDefaults.standard
    private let nameKey = "userName"
    private let emailKey = "userEmail"
    private let mobileKey = "userMobile"
    private let profileImageKey = "userProfileImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedData()
    }
    
    private func setupUI() {
        // Make image view tappable
        imageView.isUserInteractionEnabled = true
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(imageTapGesture)
        
        // Make image view circular
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Determine which field to edit based on the row
        switch indexPath.row {
        case 0: // Name row
            showEditAlert(for: nameLabel)
        case 1: // Mobile number row
            showEditAlert(for: mobNumLabel)
        case 2: // Email row
            showEditAlert(for: emailLabel)
        default:
            break
        }
    }
    
    @objc private func imageViewTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func showEditAlert(for label: UILabel) {
        let alert = UIAlertController(title: "Edit \(getTitleForLabel(label))",
                                    message: nil,
                                    preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = label.text
            textField.delegate = self
            self.editingLabel = label
            
            // Configure keyboard type based on the field
            if label == self.mobNumLabel {
                textField.keyboardType = .numberPad
            } else if label == self.emailLabel {
                textField.keyboardType = .emailAddress
            }
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text else { return }
            self?.updateLabel(label, with: text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func getTitleForLabel(_ label: UILabel) -> String {
        switch label {
        case nameLabel: return "Name"
        case mobNumLabel: return "Mobile Number"
        case emailLabel: return "Email"
        default: return "Field"
        }
    }
    
    private func updateLabel(_ label: UILabel, with text: String) {
        // Validate input before updating
        if label == emailLabel && !isValidEmail(text) {
            showError("Please enter a valid email address")
            return
        }
        
        if label == mobNumLabel && !isValidPhoneNumber(text) {
            showError("Please enter a valid 10-digit phone number")
            return
        }
        
        // Update label and save to UserDefaults
        label.text = text
        switch label {
        case nameLabel:
            userDefaults.set(text, forKey: nameKey)
        case emailLabel:
            userDefaults.set(text, forKey: emailKey)
        case mobNumLabel:
            userDefaults.set(text, forKey: mobileKey)
        default:
            break
        }
        userDefaults.synchronize()
        
        // Post notification for account view controller
        NotificationCenter.default.post(name: NSNotification.Name("UserProfileUpdated"), object: nil)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Validation helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ number: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: number)
    }
    
    // Add this new method
    private func loadSavedData() {
        // Load text data
        nameLabel.text = userDefaults.string(forKey: nameKey) ?? "Harsh Kumar"
        emailLabel.text = userDefaults.string(forKey: emailKey) ?? "harsh7617rajput@gmail.com"
        mobNumLabel.text = userDefaults.string(forKey: mobileKey) ?? "8865830411"
        
        // Load profile image
        if let imageData = userDefaults.data(forKey: profileImageKey),
           let savedImage = UIImage(data: imageData) {
            imageView.image = savedImage
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension profileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            imageView.image = editedImage
            // Save image to UserDefaults
            if let imageData = editedImage.jpegData(compressionQuality: 0.8) {
                userDefaults.set(imageData, forKey: profileImageKey)
                userDefaults.synchronize()
                // Notify account view controller
                NotificationCenter.default.post(name: NSNotification.Name("UserProfileUpdated"), object: nil)
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            imageView.image = originalImage
            // Save image to UserDefaults
            if let imageData = originalImage.jpegData(compressionQuality: 0.8) {
                userDefaults.set(imageData, forKey: profileImageKey)
                userDefaults.synchronize()
                // Notify account view controller
                NotificationCenter.default.post(name: NSNotification.Name("UserProfileUpdated"), object: nil)
            }
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension profileTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                  shouldChangeCharactersIn range: NSRange,
                  replacementString string: String) -> Bool {
        // For mobile number, limit to 10 digits
        if editingLabel == mobNumLabel {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 10
        }
        return true
    }

}
