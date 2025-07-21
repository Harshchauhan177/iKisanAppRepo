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
    
    @IBOutlet weak var ProviderNameLabel: UILabel!
    
    @IBOutlet weak var ProviderImageLabel: UIImageView!
    weak var delegate: MyRequestTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        EquipmentImageLabel.layer.cornerRadius = 10
    }

    func configure(with equipment: Equipment, request: Request) {
        // Check if the equipmentImage is a URL or a local asset name
        if equipment.equipmentImage.hasPrefix("http") {
            // It's a URL, use our ImageCache utility to load it
            EquipmentImageLabel.loadImage(from: equipment.equipmentImage)
        } else {
            // Fallback to local asset loading for backward compatibility
            EquipmentImageLabel.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
        }
        
        EquipmentTitleLabel.text = equipment.name
        LocationLabel.text = equipment.location
        ProviderNameLabel.text=equipment.providerName
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
