

import UIKit

class MyRequestInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Make image circular
        imageLabel.layer.cornerRadius = imageLabel.frame.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.contentMode = .scaleAspectFill
        
        // Set default image
        imageLabel.image = UIImage(systemName: "person.circle.fill")
    }

    func configure(with user: User) {
        nameLabel.text = user.name
        imageLabel.image = UIImage(systemName: "person.circle.fill")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
