//
//  MYTableViewCell.swift
//  iKisanApp
//
//  Created by chandan kumar on 22/01/25.
//

import UIKit

class MYTableViewCell: UITableViewCell {

    
    @IBOutlet weak var iconLabel: UIImageView!
    
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    
    @IBOutlet weak var InputLabel: UITextField!
    
    
    @IBOutlet weak var WorkingIconLabel: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with row: InfoRow) {
            if let icon = row.icon {
                iconLabel.image = icon
            }
            TitleLabel.text = row.title
            
            // Show the InputLabel for editable text fields (like Area)
            if let inputText = row.inputText {
                InputLabel.isHidden = false
                InputLabel.text = inputText
            } else {
                InputLabel.isHidden = true
            }
            
            if let workingIcon = row.workingIcon {
                WorkingIconLabel.image = workingIcon
            } else {
                WorkingIconLabel.image = nil  // Hide if no icon
            }
        }
    }

