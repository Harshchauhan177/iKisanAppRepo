//
//  OnBodingTableViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/02/25.
//

import UIKit

class OnBoardingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var cropNameLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    var onTextChanged: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInitialState()
    }
    
    private func setupInitialState() {
        inputTextField.isHidden = true
        inputTextField.alpha = 0
        inputTextField.borderStyle = .roundedRect
        inputTextField.placeholder = "Enter your field area (in acres)"
        inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        onTextChanged?(textField.text)
    }
    
    func configure(with crop: Crop, isSelected: Bool, enteredText: String?) {
        // Use the existing ImageCache utility to load and cache the image
        if !crop.imageURL.isEmpty {
            imageLabel.loadImage(from: crop.imageURL, placeholder: UIImage(systemName: "leaf"))
        } else {
            imageLabel.image = UIImage(systemName: "leaf")
        }
        
        cropNameLabel.text = crop.name
        
        // Show text field if cell is selected or has text
        if isSelected || (enteredText != nil && !enteredText!.isEmpty) {
            showTextField(withText: enteredText)
        } else {
            hideTextField()
        }
        
        // Show checkmark only for selected state
        accessoryType = isSelected ? .checkmark : .none
    }
    
    private func showTextField(withText text: String?) {
        inputTextField.text = text
        
        // If text field is currently hidden, animate it in
        if inputTextField.isHidden {
            inputTextField.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.inputTextField.alpha = 1.0
            }
        } else {
            // If already visible, just ensure it's shown
            inputTextField.alpha = 1.0
        }
    }
    
    private func hideTextField() {
        // Only animate if currently visible
        if !inputTextField.isHidden && inputTextField.alpha > 0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.inputTextField.alpha = 0.0
            }) { _ in
                self.inputTextField.isHidden = true
                if self.inputTextField.text?.isEmpty ?? true {
                    self.inputTextField.text = ""
                    self.inputTextField.resignFirstResponder()
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        inputTextField.isHidden = true
        inputTextField.alpha = 0
        if inputTextField.text?.isEmpty ?? true {
            inputTextField.text = ""
        }
        accessoryType = .none
    }
    

}
