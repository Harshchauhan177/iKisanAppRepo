//
//  CoequipTableViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 22/01/25.
//

import UIKit

class CoequipTableViewCell: UITableViewCell {

    
    @IBOutlet weak var EquipmentImageLabel: UIImageView!
    
    @IBOutlet weak var EquipmentNameLabel: UILabel!
    
    @IBOutlet weak var AddressLabel: UILabel!
    
    @IBOutlet weak var DateLabel: UILabel!
    
    
    @IBOutlet weak var pendingButton: UIButton?
    
    
    @IBOutlet weak var confirmButton: UIButton?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        confirmButton?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

    @IBAction func PendingButtonTapped(_ sender: Any) {
        print("pending button tapped")
    }
    
    @IBAction func confirmButtomTapped(_ sender: Any) {
        print("Confirm buttom tapped")
    }
    
}
