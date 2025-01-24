

import UIKit

class SelectPeopleListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ImageLabel: UIImageView!
    
    @IBOutlet weak var checkboxButton: UIButton!
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var isSelectedState: Bool = false
    
    var newName:String? = "Hello"
    var newCheck:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("Hiiiiiiiiii")
        print("Cell awakeFromNib: \(self)")
      
      
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Cell layoutSubviews called")
    }


    func UpdateCellData(with people: PersonList){
        print("Inside UpdateCellData :\(people.name)")
        nameLabel.text = people.name
        
    }
   
    @IBAction func CheckBoxButtonTapped(_ sender: UIButton) {
        isSelectedState.toggle()
            
            
            sender.isSelected = isSelectedState
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}
