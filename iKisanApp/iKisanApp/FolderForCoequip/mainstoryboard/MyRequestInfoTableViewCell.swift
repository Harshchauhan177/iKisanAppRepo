import UIKit

class MyRequestInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var timeSlotLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("Cell awakeFromNib called")
        
        // Verify outlets are connected
        guard nameLabel != nil else {
            print("Error: nameLabel outlet is not connected!")
            return
        }
        
        guard imageLabel != nil else {
            print("Error: imageLabel outlet is not connected!")
            return
        }
        
        setupUI()
    }
    
    private func setupUI() {
        print("Setting up cell UI")
        
        // Make image circular
        imageLabel.layer.cornerRadius = imageLabel.frame.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.contentMode = .scaleAspectFill
        
        // Set default image
        imageLabel.image = UIImage(systemName: "person.circle.fill")
        imageLabel.tintColor = UIColor.systemGray4
        
        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        
        // Configure area label
        areaLabel.font = UIFont.systemFont(ofSize: 14)
        areaLabel.textColor = .secondaryLabel
        areaLabel.numberOfLines = 1
        
        // Configure time slot label
        timeSlotLabel.font = UIFont.systemFont(ofSize: 14)
        timeSlotLabel.textColor = .secondaryLabel
        timeSlotLabel.numberOfLines = 1
        
        print("Cell UI setup completed")
    }

    func configure(with user: User, area: Double? = nil, timeSlot: String? = nil) {
        print("Configuring cell for user: \(user.name)")
        
        // Set user's name
        nameLabel.text = user.name
        
        // Set area if available
        if let area = area {
            areaLabel.text = String(format: "%.2f acres", area)
        } else {
            areaLabel.text = "Area not specified"
        }
        
        // Set time slot if available
        if let timeSlot = timeSlot {
            timeSlotLabel.text = timeSlot
        } else {
            timeSlotLabel.text = "Time slot not specified"
        }
        
        // Set default image
        imageLabel.image = UIImage(systemName: "person.circle.fill")
        imageLabel.tintColor = UIColor.systemGray4
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        areaLabel.text = nil
        timeSlotLabel.text = nil
        imageLabel.image = UIImage(systemName: "person.circle.fill")
    }
}
