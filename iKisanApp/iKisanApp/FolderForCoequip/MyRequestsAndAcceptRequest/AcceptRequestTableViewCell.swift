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
        imageLabel.layer.cornerRadius = 10
    }
    func configure(with request: Request, equipment: Equipment) {
       
        if equipment.equipmentImage.hasPrefix("http") {
            // It's a URL, use our ImageCache utility to load it
            imageLabel.loadImage(from: equipment.equipmentImage)
        } else {
            // Fallback to local asset loading for backward compatibility
            imageLabel.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
        }
      
        titleLabel.text = equipment.name
        priceLabel.text = "₹ \(equipment.pricePerAcre)"
        hostLabel.text = equipment.providerName
        locationLabel.text = equipment.location
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        dateLabel.text = dateFormatter.string(from: request.requestedDate)
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        // Only notify delegate, remove direct navigation
        delegate?.acceptButtonTapped(in: self)
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        // Only notify delegate, remove direct deletion
        delegate?.rejectButtonTapped(in: self)
        
    }
    
    // Helper method to find the view controller
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
