//
//  CoequipTableViewCell.swift
//  iKisanApp
//
//  Created by chandan kumar on 22/01/25.
//

import UIKit

class CoequipTableViewCell: UITableViewCell {

    
    @IBOutlet weak var EquipmentImageLabel: UIImageView!
    
    @IBOutlet weak var EquipmentNameLabel: UILabel!
    
    @IBOutlet weak var AddressLabel: UILabel!
    
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var PendingButtonTapped: UIButton!
    
    
    @IBOutlet weak var ConfirmButtomTapped: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ConfirmButtomTapped.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func PendingButtonTapped(_ sender: Any) {
        print("pending button tapped")
    }
    
    
    @IBAction func ConfirmButtonTapped(_ sender: Any) {
        print("confirm button tapped")
        ConfirmButtomTapped.isHidden = false
    }
    

}
