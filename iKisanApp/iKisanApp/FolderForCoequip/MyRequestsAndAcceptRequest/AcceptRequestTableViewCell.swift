

import UIKit

protocol AcceptRequestTableViewCellDelegate: AnyObject {
    func acceptButtonTapped(in cell: AcceptRequestTableViewCell)
    func rejectButtonTapped(in cell: AcceptRequestTableViewCell)
}


class AcceptRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var EquipmentIimageLabel: UIImageView!
    
    @IBOutlet weak var EquipmentTitleLabel: UILabel!
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var PriceLabel: UILabel!
    
    @IBOutlet weak var CreatorLabel: UIImageView!
    
    @IBOutlet weak var AcceptButtonLabel: UIButton!
    
    @IBOutlet weak var RejectButtonTapped: UIButton!
    
    weak var delegate: AcceptRequestTableViewCellDelegate?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    @IBAction func AccepctButtonTapped(_ sender: Any) {
        delegate?.acceptButtonTapped(in: self)
    }
    
    @IBAction func RejectButtonTapped(_ sender: Any) {
        delegate?.rejectButtonTapped(in: self)
    }
    
    
}
