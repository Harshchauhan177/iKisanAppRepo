

import UIKit

class SelectPeopleListTableViewCell: UITableViewCell {
    @IBOutlet weak var ImageLabel: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton! // Add this outlet if not already present
    
    var isSelectedState: Bool = false {
        didSet {
            updateCheckboxState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configure image view
        ImageLabel.layer.cornerRadius = ImageLabel.frame.height / 2
        ImageLabel.clipsToBounds = true
        ImageLabel.contentMode = .scaleAspectFill
        ImageLabel.image = UIImage(systemName: "person.circle.fill")
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    func configure(with user: User, isSelected: Bool = false) {
        nameLabel.text = user.name
        isSelectedState = isSelected
        updateCheckboxState()
    }
    
    private func updateCheckboxState() {
        checkBoxButton.isSelected = isSelectedState
        let imageName = isSelectedState ? "checkmark.circle.fill" : "circle"
        checkBoxButton.setImage(UIImage(systemName: imageName), for: .normal)
        checkBoxButton.tintColor = isSelectedState ? .systemGreen : .systemGray3
    }
    
    @IBAction func CheckBoxButtonTapped(_ sender: UIButton) {
        isSelectedState.toggle()
        sender.isSelected = isSelectedState
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.ImageLabel.image = image
            }
        }.resume()
    }
}
