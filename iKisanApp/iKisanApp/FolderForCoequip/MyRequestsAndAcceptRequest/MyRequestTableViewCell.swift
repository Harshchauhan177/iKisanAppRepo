

import UIKit

protocol MyRequestTableViewCellDelegate: AnyObject {
    func didTapConfirmButton(cell: MyRequestTableViewCell)
    func didTapPendingButton(cell: MyRequestTableViewCell)
}

class MyRequestTableViewCell: UITableViewCell {

    
    @IBOutlet weak var EquipmentImageLabel: UIImageView!
    
    @IBOutlet weak var EquipmentTitleLabel: UILabel!
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var PendingButtonTapped: UIButton!
    
    @IBOutlet weak var ConfirmButtonLabel: UIButton!
    
    weak var delegate: MyRequestTableViewCellDelegate?
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }


    
    @IBAction func ConfirmButtonTapped(_ sender: Any) {
        delegate?.didTapConfirmButton(cell: self)
    }
    
    @IBAction func PendingButtonTapped(_ sender: Any) {
        delegate?.didTapPendingButton(cell: self)
       
    }
    
}
