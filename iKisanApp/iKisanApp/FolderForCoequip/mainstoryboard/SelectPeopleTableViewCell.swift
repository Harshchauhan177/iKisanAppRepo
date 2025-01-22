//
//  SelectPeopleTableViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 22/01/25.
//

import UIKit

class SelectPeopleTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var PeopleNameLabel: UILabel!
    
    
    @IBOutlet weak var PeopleImage: UIImageView!
    override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

        private func setupUI() {
            PeopleImage.layer.cornerRadius = PeopleImage.frame.size.height / 2
            PeopleImage.clipsToBounds = true
        }
        
        func configure(with person: Person) {
            PeopleNameLabel.text = person.name
            PeopleImage.image = person.image ?? UIImage(named: "defaultProfile")
        }
    

}
