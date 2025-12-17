import UIKit

class OTPVerificationViewController: UIViewController {
    
    // MARK: - Properties
    private let email: String
    
    // MARK: - UI Components
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "app_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Email Verification"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.accessibilityTraits = .header
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var otpTextFields: [UITextField] = []
    
    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "VerifyButton"
        button.accessibilityLabel = "Verify code"
        return button
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Resend Code", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Resend verification code"
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .secondaryLabel
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.accessibilityLabel = "Loading"
        return indicator
    }()
    
    // MARK: - Initializers
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureActions()
        setupOTPTextFields()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure subtitle with user's email
        subtitleLabel.text = "We've sent a verification code to \(email). Please enter the code to verify your account."
        
        // Add subviews
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(otpStackView)
        view.addSubview(verifyButton)
        view.addSubview(resendButton)
        view.addSubview(activityIndicator)
        
        // Configure constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            otpStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            otpStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            otpStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            otpStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            otpStackView.heightAnchor.constraint(equalToConstant: 50),
            
            verifyButton.topAnchor.constraint(equalTo: otpStackView.bottomAnchor, constant: 40),
            verifyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            
            resendButton.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 16),
            resendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupOTPTextFields() {
        // Create OTP text fields
        for i in 0..<6 {
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.textAlignment = .center
            textField.font = UIFont.preferredFont(forTextStyle: .title3)
            textField.adjustsFontForContentSizeCategory = true
            textField.keyboardType = .numberPad
            textField.layer.borderColor = UIColor.systemGray4.cgColor
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 8
            textField.delegate = self
            textField.tag = i
            textField.accessibilityLabel = "Digit \(i+1) of verification code"
            textField.accessibilityHint = "Enter a single digit"
            
            // Limit to single character
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            otpTextFields.append(textField)
            otpStackView.addArrangedSubview(textField)
        }
        
        // Make first text field first responder
        otpTextFields.first?.becomeFirstResponder()
    }
    
    // MARK: - Actions Configuration
    private func configureActions() {
        verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Action Methods
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count <= 1 else {
            textField.text = String(textField.text?.first ?? " ")
            return
        }
        
        if text.count == 1 {
            let nextTag = textField.tag + 1
            if nextTag < otpTextFields.count {
                otpTextFields[nextTag].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                verifyButtonTapped()
            }
        }
    }
    
    @objc private func verifyButtonTapped() {
        // Get OTP code from text fields
        let otpCode = otpTextFields.compactMap { $0.text }.joined()
        
        // Validate OTP code
        if otpCode.count != 6 {
            showAlert(title: "Error", message: "Please enter the complete verification code")
            return
        }
        
        // Start loading indicator
        activityIndicator.startAnimating()
        verifyButton.isEnabled = false
        
        // Verify OTP
        Task {
            do {
                let user = try await AuthManager.shared.verifyOTP(email: email, otp: otpCode)
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    verifyButton.isEnabled = true
                    
                    // Navigate to select crops screen using SwiftUI
                    let dataController = IKisanDataController()
                    let selectCropsVC = SelectCropsHostingController(dataController: dataController, isFromProfile: false)
                    let navigationController = UINavigationController(rootViewController: selectCropsVC)
                    UIApplication.shared.windows.first?.rootViewController = navigationController
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            } catch AuthError.rateLimited {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    verifyButton.isEnabled = true
                    showAlert(title: "Rate Limit Exceeded", message: "For security purposes, please wait at least 60 seconds before trying again.")
                }
            } catch AuthError.invalidOTP {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    verifyButton.isEnabled = true
                    showAlert(title: "Verification Failed", message: "Invalid verification code. Please try again.")
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    verifyButton.isEnabled = true
                    showAlert(title: "Verification Failed", message: "An error occurred. Please try again later.")
                }
            }
        }
    }
    
    @objc private func resendButtonTapped() {
        activityIndicator.startAnimating()
        resendButton.isEnabled = false
        
        // Implement resend code logic
        Task {
            do {
                // Call the real resend OTP method
                try await AuthManager.shared.resendOTP(email: email)
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    resendButton.isEnabled = true
                    showAlert(title: "Code Sent", message: "A new verification code has been sent to your email.")
                }
            } catch AuthError.rateLimited {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    resendButton.isEnabled = true
                    showAlert(title: "Rate Limit Exceeded", message: "For security purposes, please wait at least 60 seconds before trying again.")
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    resendButton.isEnabled = true
                    showAlert(title: "Error", message: "Failed to resend code. Please try again.")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension OTPVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow digits
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet) && string.count <= 1
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGreen.cgColor
        textField.layer.borderWidth = 2
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
    }
} 