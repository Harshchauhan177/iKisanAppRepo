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
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var isSelectedState: Bool = false
    
    var newName:String? = "Hello"
    var newCheck:String?
//    var newcheckboxButton:String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("Hiiiiiiiiii")
        print("Cell awakeFromNib: \(self)")
      
      
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Cell layoutSubviews called")
    }

//    func UpdateCellData(with peo: IndexPath){
    func UpdateCellData(with people: PersonList){
//        NameLabel.text = people.name
        print("Inside UpdateCellData :\(people.name)")
        
        nameLabel.text = people.name

//        ImageLabel.image = UIImage(named: people.image)
        
    }
        //NameLabel.text = pupil.allPeopleData[indexPath.row].name
       // ImageLabel.image = UIImage(named: pupil.allPeopleData[indexPath.row].image)
        
        
//        guard NameLabel != nil else {
//               print("NameLabel is nil!")
//               return
//           }
//           
//           guard indexPath.row < pupil.allPeopleData.count else {
//               print("Index out of range")
//               return
//           }
//           
//           NameLabel.text = pupil.allPeopleData[indexPath.row].name ?? "Unknown"
    

    
    @IBAction func CheckBoxButtonTapped(_ sender: UIButton) {
        isSelectedState.toggle()
            
            
            sender.isSelected = isSelectedState
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}
