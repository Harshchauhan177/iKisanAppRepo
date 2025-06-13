import UIKit
import Supabase

// Create a proper Encodable struct for Supabase
struct ReviewDTO: Encodable {
    let equipmentID: String
    let userID: String
    let reviewHeading: String
    let reviewDescription: String
    let rating: Double
    let createdAt: String
}

class WriteReviewViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    var equipment: Equipment?
    var onReviewSubmitted: ((ReviewData) -> Void)?
    var dataController: DataController?
    
    // iKisan green color
    private let ikisanGreen = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
    
    // MARK: - UI Elements
    private lazy var equipmentIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var equipmentNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var equipmentDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var tapToRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap to Rate:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var reviewContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Optional"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .secondaryLabel
        textField.delegate = self
        return textField
    }()
    
    private lazy var titleSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Review"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var reviewTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Optional"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .secondaryLabel
        textField.delegate = self
        return textField
    }()
    
    // Rating value
    private var currentRating: Int = 1
    private var starButtons = [UIButton]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        configureWithEquipment()
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        title = "Write a Review"
        view.backgroundColor = .systemBackground
        
        // Set up navigation bar
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        cancelButton.tintColor = ikisanGreen
        navigationItem.leftBarButtonItem = cancelButton
        
        let submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
        submitButton.tintColor = ikisanGreen
        navigationItem.rightBarButtonItem = submitButton
    }
    
    private func setupUI() {
        // Add subviews
        view.addSubview(equipmentIconView)
        view.addSubview(equipmentNameLabel)
        view.addSubview(equipmentDescriptionLabel)
        view.addSubview(separatorLine)
        view.addSubview(tapToRateLabel)
        view.addSubview(starStackView)
        view.addSubview(reviewContainerView)
        
        reviewContainerView.addSubview(titleLabel)
        reviewContainerView.addSubview(titleTextField)
        reviewContainerView.addSubview(titleSeparator)
        reviewContainerView.addSubview(reviewLabel)
        reviewContainerView.addSubview(reviewTextField)
        
        // Setup star buttons
        setupStarButtons()
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Equipment icon
            equipmentIconView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            equipmentIconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            equipmentIconView.widthAnchor.constraint(equalToConstant: 60),
            equipmentIconView.heightAnchor.constraint(equalToConstant: 60),
            
            // Equipment name
            equipmentNameLabel.topAnchor.constraint(equalTo: equipmentIconView.topAnchor, constant: 8),
            equipmentNameLabel.leadingAnchor.constraint(equalTo: equipmentIconView.trailingAnchor, constant: 12),
            equipmentNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Equipment description
            equipmentDescriptionLabel.topAnchor.constraint(equalTo: equipmentNameLabel.bottomAnchor, constant: 4),
            equipmentDescriptionLabel.leadingAnchor.constraint(equalTo: equipmentIconView.trailingAnchor, constant: 12),
            equipmentDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Separator line
            separatorLine.topAnchor.constraint(equalTo: equipmentIconView.bottomAnchor, constant: 16),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Tap to rate label
            tapToRateLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 24),
            tapToRateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Star stack view
            starStackView.centerYAnchor.constraint(equalTo: tapToRateLabel.centerYAnchor),
            starStackView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            starStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            starStackView.heightAnchor.constraint(equalToConstant: 30),
            
            // Review container view
            reviewContainerView.topAnchor.constraint(equalTo: tapToRateLabel.bottomAnchor, constant: 24),
            reviewContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reviewContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reviewContainerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: reviewContainerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: reviewContainerView.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 60),
            
            // Title text field
            titleTextField.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            titleTextField.trailingAnchor.constraint(equalTo: reviewContainerView.trailingAnchor, constant: -16),
            
            // Title separator
            titleSeparator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            titleSeparator.leadingAnchor.constraint(equalTo: reviewContainerView.leadingAnchor),
            titleSeparator.trailingAnchor.constraint(equalTo: reviewContainerView.trailingAnchor),
            titleSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Review label
            reviewLabel.topAnchor.constraint(equalTo: titleSeparator.bottomAnchor, constant: 16),
            reviewLabel.leadingAnchor.constraint(equalTo: reviewContainerView.leadingAnchor, constant: 16),
            reviewLabel.widthAnchor.constraint(equalToConstant: 60),
            reviewLabel.bottomAnchor.constraint(equalTo: reviewContainerView.bottomAnchor, constant: -16),
            
            // Review text field
            reviewTextField.centerYAnchor.constraint(equalTo: reviewLabel.centerYAnchor),
            reviewTextField.leadingAnchor.constraint(equalTo: reviewLabel.trailingAnchor, constant: 8),
            reviewTextField.trailingAnchor.constraint(equalTo: reviewContainerView.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupStarButtons() {
        // Clear any existing buttons
        starStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        starButtons.removeAll()
        
        // Create star buttons
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.setImage(UIImage(systemName: i == 1 ? "star.fill" : "star"), for: .normal)
            starButton.tintColor = i == 1 ? ikisanGreen : .systemGray2
            starButton.tag = i
            starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(starButton)
            starButtons.append(starButton)
        }
    }
    
    private func configureWithEquipment() {
        guard let equipment = equipment else { return }
        
        equipmentNameLabel.text = equipment.name
        equipmentDescriptionLabel.text = "Farm Equipment"
        
        // Load equipment image
        let imagePath = equipment.equipmentImage
        if !imagePath.isEmpty {
            if imagePath.hasPrefix("http") {
                equipmentIconView.loadImage(from: imagePath)
            } else {
                equipmentIconView.image = UIImage(named: imagePath) ?? UIImage(systemName: "tractor")
            }
        } else {
            equipmentIconView.image = UIImage(systemName: "tractor")
        }
        
        equipmentIconView.tintColor = .systemGray
    }
    
    // MARK: - Actions
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        let rating = sender.tag
        
        // Update the stars appearance
        for (index, button) in starButtons.enumerated() {
            let starFilled = index < rating
            button.setImage(UIImage(systemName: starFilled ? "star.fill" : "star"), for: .normal)
            button.tintColor = starFilled ? ikisanGreen : .systemGray2
        }
        
        currentRating = rating
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func submitTapped() {
        submitReview()
    }
    
    private func submitReview() {
        // Get the review title and text
        let title = titleTextField.text ?? ""
        let reviewText = reviewTextField.text ?? ""
        
        guard let equipment = equipment else {
            showAlert(title: "Error", message: "Equipment information is missing.")
            return
        }
        
        // Create the review data
        let newReview = ReviewData(
            reviewHeading: title.isEmpty ? "Review for \(equipment.name)" : title,
            reviewDescription: reviewText.isEmpty ? "Great equipment!" : reviewText,
            rating: Double(currentRating),
            equipmentID: equipment.equipmentID.uuidString,
            equipmentName: equipment.name
        )
        
        // Save to local storage
        ReviewDataClass.reviews.append(newReview)
        
        // Save to backend using Supabase
        saveToSupabase(review: newReview)
        
        // Notify delegate
        onReviewSubmitted?(newReview)
        
        // Show success message and dismiss
        let alert = UIAlertController(title: "Success", message: "Your review has been submitted!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func saveToSupabase(review: ReviewData) {
        // Get the current user ID
        var userID: UUID? = nil
        if let dataController = dataController ?? (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.dataController {
            if let currentUser = dataController.getCurrentUser() {
                userID = currentUser.userID
            }
        }
        
        // Convert string to UUID if needed
        var equipmentUUID: UUID? = nil
        if let uuidString = review.equipmentID {
            equipmentUUID = UUID(uuidString: uuidString)
        }
        
        // Create the proper review DTO object
        let reviewDTO = ReviewDTO(
            equipmentID: equipmentUUID?.uuidString ?? "",
            userID: userID?.uuidString ?? "",
            reviewHeading: review.reviewHeading,
            reviewDescription: review.reviewDescription,
            rating: review.rating,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        // Send to Supabase using the shared client
        Task {
            do {
                print("Saving review to Supabase...")
                
                // Use the shared Supabase client to insert the review
                _ = try await SupabaseManager.shared.client
                    .from("reviews")
                    .insert(reviewDTO)
                    .execute()
                
                print("✅ Review saved to Supabase successfully")
                
                // Also add to the local data controller if available
                if let dataController = dataController {
                    dataController.addReview(review)
                }
                
            } catch {
                print("❌ Error saving review to Supabase: \(error)")
                if let postgrestError = error as? PostgrestError {
                    print("  - Code: \(postgrestError.code ?? "nil")")
                    print("  - Message: \(postgrestError.message ?? "nil")")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            reviewTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
} 