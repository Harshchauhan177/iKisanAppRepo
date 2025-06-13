import UIKit

class MyRequestInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    
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
        
        print("Cell UI setup completed")
    }

    func configure(with user: User) {
        print("Configuring cell for user: \(user.name)")
        
        // Set only the user's name
        nameLabel.text = user.name
        
        // Set default image
        imageLabel.image = UIImage(systemName: "person.circle.fill")
        imageLabel.tintColor = UIColor.systemGray4
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        imageLabel.image = UIImage(systemName: "person.circle.fill")
    }
}
