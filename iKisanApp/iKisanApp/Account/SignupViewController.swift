import UIKit
import SwiftUI
import SafariServices

class SignupViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.accessibilityTraits = .header
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Join iKisan to access all features"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .next
        textField.accessibilityLabel = "Full Name"
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .next
        textField.accessibilityLabel = "Email Address"
        return textField
    }()
    
    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone Number"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .phonePad
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .next
        textField.accessibilityLabel = "Phone Number"
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .next
        textField.accessibilityLabel = "Password"
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        textField.accessibilityLabel = "Confirm Password"
        return textField
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = .init(Color(red: 0.298, green: 0.498, blue: 0.345, opacity: 1))//.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Create a new account"
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Login", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Return to login screen"
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
    
    // Privacy Policy Components
    private let privacyPolicyContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let privacyCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Privacy Policy Agreement"
        button.accessibilityHint = "Tap to agree to Terms and Privacy Policy"
        return button
    }()
    
    private let privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureActions()
        setupKeyboardDismissal()
        setupPrivacyPolicyText()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(phoneTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
        contentView.addSubview(privacyPolicyContainer)
        contentView.addSubview(signupButton)
        contentView.addSubview(loginButton)
        contentView.addSubview(activityIndicator)
        
        // Setup privacy policy container
        privacyPolicyContainer.addSubview(privacyCheckbox)
        privacyPolicyContainer.addSubview(privacyPolicyLabel)
        
        // Configure constraints
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentViewHeightConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentViewHeightConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            phoneTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            phoneTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Privacy policy container constraints
            privacyPolicyContainer.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            privacyPolicyContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            privacyPolicyContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Privacy checkbox constraints
            privacyCheckbox.leadingAnchor.constraint(equalTo: privacyPolicyContainer.leadingAnchor),
            privacyCheckbox.topAnchor.constraint(equalTo: privacyPolicyContainer.topAnchor),
            privacyCheckbox.bottomAnchor.constraint(lessThanOrEqualTo: privacyPolicyContainer.bottomAnchor),
            privacyCheckbox.widthAnchor.constraint(equalToConstant: 24),
            privacyCheckbox.heightAnchor.constraint(equalToConstant: 24),
            
            // Privacy label constraints
            privacyPolicyLabel.leadingAnchor.constraint(equalTo: privacyCheckbox.trailingAnchor, constant: 8),
            privacyPolicyLabel.trailingAnchor.constraint(equalTo: privacyPolicyContainer.trailingAnchor),
            privacyPolicyLabel.topAnchor.constraint(equalTo: privacyPolicyContainer.topAnchor),
            privacyPolicyLabel.bottomAnchor.constraint(equalTo: privacyPolicyContainer.bottomAnchor),
            
            signupButton.topAnchor.constraint(equalTo: privacyPolicyContainer.bottomAnchor, constant: 20),
            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signupButton.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Set delegates
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        // Initially disable signup button
        updateSignupButtonState()
    }
    
    // MARK: - Privacy Policy Setup
    private func setupPrivacyPolicyText() {
        let fullText = "I agree to the Terms of Service and Privacy Policy"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Set base attributes
        attributedString.addAttributes([
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.secondaryLabel
        ], range: NSRange(location: 0, length: fullText.count))
        
        // Make "Terms of Service and Privacy Policy" clickable
        if let linkRange = fullText.range(of: "Terms of Service and Privacy Policy") {
            let nsRange = NSRange(linkRange, in: fullText)
            attributedString.addAttributes([
                .foregroundColor: UIColor.systemBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: nsRange)
        }
        
        privacyPolicyLabel.attributedText = attributedString
        
        // Add tap gesture to the label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelTapped(_:)))
        privacyPolicyLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func privacyPolicyLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let text = privacyPolicyLabel.text else { return }
        
        let linkRange = (text as NSString).range(of: "Terms of Service and Privacy Policy")
        
        // Check if tap was on the link text
        if gesture.didTapAttributedTextInLabel(label: privacyPolicyLabel, inRange: linkRange) {
            openPrivacyPolicy()
        }
    }
    
    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://harshchauhan177.github.io/ikisan-PrivacyPolicy/") else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        present(safariViewController, animated: true)
    }
    
    private func updateSignupButtonState() {
        let isPrivacyAccepted = privacyCheckbox.isSelected
        signupButton.isEnabled = isPrivacyAccepted
        
        // Update button appearance
        signupButton.alpha = isPrivacyAccepted ? 1.0 : 0.6
    }
    
    // MARK: - Actions Configuration
    private func configureActions() {
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        privacyCheckbox.addTarget(self, action: #selector(privacyCheckboxTapped), for: .touchUpInside)
    }
    
    @objc private func privacyCheckboxTapped() {
        privacyCheckbox.isSelected.toggle()
        updateSignupButtonState()
        
        // Provide haptic feedback following HIG
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Action Methods
    @objc private func signupButtonTapped() {
        // Check privacy policy agreement first
        guard privacyCheckbox.isSelected else {
            showAlert(title: "Terms Required", message: "Please accept the Terms of Service and Privacy Policy to continue")
            return
        }
        
        // Validate fields
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(title: "Error", message: "Please enter a valid email address")
            return
        }
        
        // Validate phone number
        if !isValidPhone(phone) {
            showAlert(title: "Error", message: "Please enter a valid phone number")
            return
        }
        
        // Validate password match
        if password != confirmPassword {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        // Validate password strength
        if !isValidPassword(password) {
            showAlert(title: "Error", message: "Password must be at least 8 characters long and include uppercase, lowercase, and a number")
            return
        }
        
        // Start loading indicator
        activityIndicator.startAnimating()
        signupButton.isEnabled = false
        
        // Perform registration
        Task {
            do {
                let success = try await AuthManager.shared.register(
                    name: name,
                    email: email,
                    password: password,
                    phone: phone
                )
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    signupButton.isEnabled = true
                    
                    if success {
                        // Set flag that this is a newly registered user who needs to select crops
                        UserDefaults.standard.set(true, forKey: "isNewlyRegisteredUser")
                        
                        // Show OTP verification screen
                        showOTPVerification(email: email)
                    }
                }
            } catch AuthError.rateLimited {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    signupButton.isEnabled = true
                    showAlert(title: "Rate Limit Exceeded", message: "For security purposes, please wait at least 60 seconds before trying again.")
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    signupButton.isEnabled = true
                    showAlert(title: "Registration Failed", message: "Unable to create account. Please try again.")
                }
            }
        }
    }
    
    private func showOTPVerification(email: String) {
        let alertController = UIAlertController(
            title: "Verify Email",
            message: "We've sent a verification code to \(email). Please enter the code to verify your account.",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Verification Code"
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let verifyAction = UIAlertAction(title: "Verify", style: .default) { [weak self] _ in
            guard let otp = alertController.textFields?.first?.text, !otp.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter the verification code")
                return
            }
            
            self?.verifyOTP(email: email, otp: otp)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(verifyAction)
        
        present(alertController, animated: true)
    }
    
    private func verifyOTP(email: String, otp: String) {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let user = try await AuthManager.shared.verifyOTP(email: email, otp: otp)
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    
                    // Navigate to select crops screen using SwiftUI
                    let dataController = IKisanDataController()
                    let selectCropsVC = SelectCropsHostingController(dataController: dataController, isFromProfile: false)
                    let navigationController = UINavigationController(rootViewController: selectCropsVC)
                    UIApplication.shared.windows.first?.rootViewController = navigationController
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    showAlert(title: "Verification Failed", message: "Invalid verification code. Please try again.")
                }
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$" // Basic validation for 10 digit phone
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, one uppercase, one lowercase, one number
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
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
extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            phoneTextField.becomeFirstResponder()
        } else if textField == phoneTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            textField.resignFirstResponder()
            signupButtonTapped()
        }
        return true
    }
}
