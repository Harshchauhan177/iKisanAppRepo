import UIKit
import SwiftUI

class NameEntryViewController: UIViewController {
    
    // MARK: - Properties
    var userEmail: String = ""
    var onNameEntered: ((String) -> Void)?
    var onCancel: (() -> Void)?
    
    // MARK: - UI Components
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "iKisan")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityLabel = "iKisan Logo"
        imageView.isAccessibilityElement = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Complete Your Profile"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your name to complete your profile"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your full name"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.accessibilityLabel = "Name input field"
        return textField
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Continue"
        configuration.baseBackgroundColor = .init(Color(red: 0.298, green: 0.498, blue: 0.345, opacity: 1))
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large
        
        // For iOS 13/14 support when UIButton.Configuration isn't available
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        
        if #available(iOS 15.0, *) {
            button.configuration = configuration
        }
        
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "ContinueButton"
        button.accessibilityLabel = "Continue with entered name"
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .secondaryLabel
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureActions()
        setupNavigationBar()
        
        // Update subtitle with email if available
        if !userEmail.isEmpty {
            subtitleLabel.text = "Please enter your name to complete your profile\nEmail: \(userEmail)"
        }
    }
    
    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    @objc private func cancelButtonTapped() {
        onCancel?()
        dismiss(animated: true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(containerStackView)
        view.addSubview(activityIndicator)
        
        containerStackView.addArrangedSubview(logoImageView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        containerStackView.addArrangedSubview(nameTextField)
        containerStackView.addArrangedSubview(continueButton)
        
        // Add spacing view to push content to center
        let spacingView = UIView()
        spacingView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(spacingView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container stack view constraints
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            // Logo image constraints
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Name text field constraints
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            nameTextField.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            
            // Continue button constraints
            continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            continueButton.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            
            // Spacing view to push content up
            spacingView.heightAnchor.constraint(equalToConstant: 40),
            
            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Set delegates
        nameTextField.delegate = self
        
        // Make text field first responder
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions Configuration
    private func configureActions() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Methods
    @objc private func continueButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter your name")
            return
        }
        
        // Validate name (at least 2 characters)
        if name.count < 2 {
            showAlert(title: "Error", message: "Name must be at least 2 characters long")
            return
        }
        
        // Start loading
        activityIndicator.startAnimating()
        continueButton.isEnabled = false
        
        // Call the completion handler
        onNameEntered?(name)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NameEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        continueButtonTapped()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit name to 50 characters
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 50
    }
} 