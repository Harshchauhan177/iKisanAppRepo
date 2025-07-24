import UIKit

protocol AcceptRequestTableViewCellDelegate: AnyObject {
    func acceptButtonTapped(in cell: AcceptRequestTableViewCell)
    func rejectButtonTapped(in cell: AcceptRequestTableViewCell)
    func leaveButtonTapped(in cell: AcceptRequestTableViewCell)
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
    
    // Add UI elements for joined state
    private var joinedStatusLabel: UILabel?
    private var leaveButton: UIButton?
    
    weak var delegate: AcceptRequestTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageLabel.layer.cornerRadius = 10
        setupJoinedStatusLabel()
    }
    
    private func setupJoinedStatusLabel() {
        // Create the joined status label - positioned like other status pills
        joinedStatusLabel = UILabel()
        joinedStatusLabel?.text = "Joined"
        joinedStatusLabel?.textAlignment = .center
        joinedStatusLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        joinedStatusLabel?.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        joinedStatusLabel?.backgroundColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 0.15)
        joinedStatusLabel?.layer.cornerRadius = 12
        joinedStatusLabel?.clipsToBounds = true
        joinedStatusLabel?.translatesAutoresizingMaskIntoConstraints = false
        joinedStatusLabel?.isHidden = true
        
        // Create the leave button - styled as secondary button following HIG
        leaveButton = UIButton(type: .system)
        leaveButton?.setTitle("Leave", for: .normal)
        leaveButton?.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        leaveButton?.setTitleColor(.systemRed, for: .normal)
        leaveButton?.backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
        leaveButton?.layer.borderColor = UIColor.systemRed.cgColor
        leaveButton?.layer.borderWidth = 1.0
        leaveButton?.layer.cornerRadius = 14
        leaveButton?.clipsToBounds = true
        leaveButton?.translatesAutoresizingMaskIntoConstraints = false
        leaveButton?.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        leaveButton?.isHidden = true
        
        // Add elements to the main content view
        contentView.addSubview(joinedStatusLabel!)
        contentView.addSubview(leaveButton!)
        
        // Position joined status label in the top right area (replacing Accept button position)
        NSLayoutConstraint.activate([
            joinedStatusLabel!.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            joinedStatusLabel!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            joinedStatusLabel!.widthAnchor.constraint(equalToConstant: 70),
            joinedStatusLabel!.heightAnchor.constraint(equalToConstant: 28)
        ])
        
//        // Position leave button on the right side, below the joined status (replacing Reject button position)
//        NSLayoutConstraint.activate([
//            leaveButton!.topAnchor.constraint(equalTo: joinedStatusLabel!.bottomAnchor, constant: 12),
//            leaveButton!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            leaveButton!.widthAnchor.constraint(equalToConstant: 100),
//            leaveButton!.heightAnchor.constraint(equalToConstant: 28)
//        ])
        NSLayoutConstraint.activate([
            // Adjust vertical spacing
            leaveButton!.topAnchor.constraint(
                equalTo: joinedStatusLabel!.bottomAnchor,
                constant: 30
            ),

            // Horizontal alignment
            leaveButton!.leadingAnchor.constraint(
                equalTo: acceptButton.leadingAnchor
            ),
             //or use trailing layout
             leaveButton!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            leaveButton!.widthAnchor.constraint(equalToConstant: 100),
            leaveButton!.heightAnchor.constraint(equalToConstant: 28),
            leaveButton!.centerXAnchor.constraint(
                equalTo: joinedStatusLabel!.centerXAnchor
            )

        ])
        

    }
    
    func configure(participant: RequestParticipant, request: Request, equipment: Equipment) {
        

        if let imageView = imageLabel{
            if !equipment.equipmentImage.isEmpty {
                imageLabel.loadImage(from: equipment.equipmentImage)
            } else {
                imageView.image = UIImage(named: "default_equipment_image")
            }
        }
        titleLabel.text = equipment.name
        priceLabel.text = "₹ \(equipment.pricePerAcre)"
        hostLabel.text = equipment.providerName
        locationLabel.text = equipment.location

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        dateLabel.text = dateFormatter.string(from: request.requestedDate)

        // Update button states and joined status label visibility based on participant status
        if participant.status == .done {
            // Show joined state elements
            acceptButton.isHidden = true
            rejectButton.isHidden = true
            joinedStatusLabel?.isHidden = false
            leaveButton?.isHidden = false
        } else {
            // Show pending state elements
            acceptButton.isHidden = false
            rejectButton.isHidden = false
            acceptButton.isEnabled = participant.status == .pending
            rejectButton.isEnabled = participant.status == .pending
            joinedStatusLabel?.isHidden = true
            leaveButton?.isHidden = true
        }
    }


    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        print("we have accepted")
        delegate?.acceptButtonTapped(in: self)
    }
    
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        // Only notify delegate, remove direct deletion
        delegate?.rejectButtonTapped(in: self)
        
    }
    
    @objc func leaveButtonTapped(_ sender: UIButton) {
        // Notify delegate when leave button is tapped
        delegate?.leaveButtonTapped(in: self)
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
