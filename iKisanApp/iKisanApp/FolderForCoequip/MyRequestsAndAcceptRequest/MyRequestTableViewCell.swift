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
        EquipmentImageLabel.layer.cornerRadius = 10
    }

    func configure(with equipment: Equipment, request: Request) {
        // Debug print for image loading
        print("Loading image: \(equipment.equipmentImage)")
        if let image = UIImage(named: equipment.equipmentImage) {
            EquipmentImageLabel.image = image
            print("Successfully loaded image")
        } else {
            print("Failed to load image: \(equipment.equipmentImage)")
            // Set a default image if the equipment image fails to load
            EquipmentImageLabel.image = UIImage(named: "default_equipment")
        }
        
        // Set other details
        EquipmentTitleLabel.text = equipment.name
        LocationLabel.text = equipment.location//equipment.providerID.uuidString // Assuming providerID is a UUID
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        DateLabel.text = dateFormatter.string(from: request.requestedDate)
        PendingButtonTapped.isHidden = (request.status != .pending)
    }
    
    @IBAction func ConfirmButtonTapped(_ sender: Any) {
        delegate?.didTapConfirmButton(cell: self)
    }
    
    @IBAction func PendingButtonTapped(_ sender: Any) {
        delegate?.didTapPendingButton(cell: self)
    }
}
