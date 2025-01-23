//
//  SelectPeopleListTableViewCell.swift
//  iKisanApp
//
//  Created by chandan kumar on 23/01/25.
//

import UIKit

class SelectPeopleListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ImageLabel: UIImageView!
    
    @IBOutlet weak var checkboxButton: UIButton!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    
    var isSelectedState: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    

    
    @IBAction func CheckBoxButtonTapped(_ sender: UIButton) {
        isSelectedState.toggle()
            
            // Update the button's isSelected state to reflect the current selection state
            sender.isSelected = isSelectedState
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
