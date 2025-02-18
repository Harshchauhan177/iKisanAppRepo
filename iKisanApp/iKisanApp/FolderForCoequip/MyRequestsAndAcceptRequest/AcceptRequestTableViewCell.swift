import UIKit

protocol AcceptRequestTableViewCellDelegate: AnyObject {
    func acceptButtonTapped(in cell: AcceptRequestTableViewCell)
    func rejectButtonTapped(in cell: AcceptRequestTableViewCell)
}

class AcceptRequestTableViewCell: UITableViewCell {
    var request: Request?
    var dataController: DataController?

    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    weak var delegate: AcceptRequestTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageLabel.layer.cornerRadius = 7
    }
    
    // Configure method
    func configure(with request: Request, equipment: Equipment) {
        self.request = request
        titleLabel.text = equipment.name
        priceLabel.text = "₹ \(equipment.pricePerHour)"
        hostLabel.text = equipment.providerID.uuidString // Assuming providerID is a UUID
        locationLabel.text = equipment.location
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        dateLabel.text = dateFormatter.string(from: request.requestedDate)
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        delegate?.acceptButtonTapped(in: self)
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        delegate?.rejectButtonTapped(in: self)
    }
}
