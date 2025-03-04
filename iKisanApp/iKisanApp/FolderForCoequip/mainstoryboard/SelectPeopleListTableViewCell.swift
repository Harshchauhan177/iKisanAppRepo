

import UIKit

class SelectPeopleListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ImageLabel: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var isSelectedState: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    func UpdateCellData(with people: User){
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
