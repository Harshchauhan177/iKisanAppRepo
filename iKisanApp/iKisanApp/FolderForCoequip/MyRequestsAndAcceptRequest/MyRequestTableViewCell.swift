import UIKit

protocol MyRequestTableViewCellDelegate: AnyObject {
    func didTapConfirmButton(cell: MyRequestTableViewCell)
    func didTapPendingButton(cell: MyRequestTableViewCell)
    func didTapCell(cell: MyRequestTableViewCell) // Add new delegate method for cell tap
}

class MyRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var EquipmentImageLabel: UIImageView!
    @IBOutlet weak var EquipmentTitleLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var PendingButtonTapped: UIButton!
    @IBOutlet weak var ConfirmButtonLabel: UIButton!
    
    @IBOutlet weak var noOfPeopleJoinedOuter: UILabel!
    
    
    weak var delegate: MyRequestTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        EquipmentImageLabel.layer.cornerRadius = 10
        
        // Add tap gesture recognizer to the entire cell content
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        tapGesture.cancelsTouchesInView = false // Allow buttons to still receive touches
        self.contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func cellTapped() {
        delegate?.didTapCell(cell: self)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        DateLabel.text = dateFormatter.string(from: request.requestedDate)
        
        // Control button visibility based on request status
        // Initially show pending button, hide confirm button
        // When provider accepts (status changes from pending/awaitingProvider), show confirm button and hide pending button
        if request.status == .pending || request.status == .awaitingProvider {
            PendingButtonTapped.isHidden = false
            ConfirmButtonLabel.isHidden = true
        } else {
            PendingButtonTapped.isHidden = true
            ConfirmButtonLabel.isHidden = false
        }
        
        // Count and display the number of people who joined/accepted the request
        let joinedCount = request.participants?.filter { $0.status == .done }.count ?? 0
        noOfPeopleJoinedOuter.text = "\(joinedCount)"
    }
    
    @IBAction func ConfirmButtonTapped(_ sender: Any) {
        delegate?.didTapConfirmButton(cell: self)
    }
    
    @IBAction func PendingButtonTapped(_ sender: Any) {
        delegate?.didTapPendingButton(cell: self)
    }
}
