import UIKit
import SwiftUI
import AuthenticationServices
import Combine
import SafariServices

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private let appleSignInViewModel = SignInWithAppleViewModel()
    
    // MARK: - UI Components
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to iKisan"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to continue"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        textField.accessibilityLabel = "Password"
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Login"
        configuration.baseBackgroundColor = .init(Color(red: 0.298, green: 0.498, blue: 0.345, opacity: 1))//.systemGreen
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large
        
        // For iOS 13/14 support when UIButton.Configuration isn't available
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        
        if #available(iOS 15.0, *) {
            button.configuration = configuration
        }
        
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "LoginButton"
        button.accessibilityLabel = "Log in to your account"
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 8
        button.accessibilityIdentifier = "AppleSignInButton"
        button.accessibilityLabel = "Sign in with Apple"
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Forgot Password? Tap to reset"
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New user? Create Account", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "New user? Create Account"
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .secondaryLabel
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
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
        setupAppleSignInObservers()
        setupPrivacyPolicyText()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Set up stack views hierarchy
        view.addSubview(containerStackView)
        view.addSubview(activityIndicator)
        
        containerStackView.addArrangedSubview(logoImageView)
        containerStackView.addArrangedSubview(welcomeLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        containerStackView.addArrangedSubview(formStackView)
        containerStackView.addArrangedSubview(privacyPolicyContainer)
        containerStackView.addArrangedSubview(buttonsStackView)
        
        formStackView.addArrangedSubview(emailTextField)
        formStackView.addArrangedSubview(passwordTextField)
        formStackView.addArrangedSubview(loginButton)
        
        // Setup privacy policy container
        privacyPolicyContainer.addSubview(privacyCheckbox)
        privacyPolicyContainer.addSubview(privacyPolicyLabel)
        
        buttonsStackView.addArrangedSubview(appleSignInButton)
        buttonsStackView.addArrangedSubview(forgotPasswordButton)
        buttonsStackView.addArrangedSubview(createAccountButton)
        
        // Configure constraints
        NSLayoutConstraint.activate([
            // Main stack view constraints
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            
            // Logo image constraints
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Form stack view constraints
            formStackView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            formStackView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            
            // Privacy policy container constraints
            privacyPolicyContainer.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            privacyPolicyContainer.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            
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
            
            // Login button constraints
            loginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            loginButton.leadingAnchor.constraint(equalTo: formStackView.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: formStackView.trailingAnchor),
            
            // Apple Sign In button constraints (match login button)
            appleSignInButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor),
            appleSignInButton.leadingAnchor.constraint(equalTo: formStackView.leadingAnchor),
            appleSignInButton.trailingAnchor.constraint(equalTo: formStackView.trailingAnchor),
            
            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Set delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Initially disable login buttons
        updateLoginButtonsState()
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
    
    private func updateLoginButtonsState() {
        let isPrivacyAccepted = privacyCheckbox.isSelected
        loginButton.isEnabled = isPrivacyAccepted
        appleSignInButton.isEnabled = isPrivacyAccepted
        
        // Update button appearance
        loginButton.alpha = isPrivacyAccepted ? 1.0 : 0.6
        appleSignInButton.alpha = isPrivacyAccepted ? 1.0 : 0.6
    }
    
    // MARK: - Actions Configuration
    private func configureActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
        privacyCheckbox.addTarget(self, action: #selector(privacyCheckboxTapped), for: .touchUpInside)
    }
    
    @objc private func privacyCheckboxTapped() {
        privacyCheckbox.isSelected.toggle()
        updateLoginButtonsState()
        
        // Provide haptic feedback following HIG
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Apple Sign In Observers
    private func setupAppleSignInObservers() {
        // Observe authentication state changes
        appleSignInViewModel.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.navigateAfterAppleSignIn()
                }
            }
            .store(in: &cancellables)
        
        // Observe name entry screen
        appleSignInViewModel.$showNameEntry
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showNameEntry in
                if showNameEntry {
                    self?.showNameEntryScreen()
                }
            }
            .store(in: &cancellables)
        
        // Observe error messages
        appleSignInViewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showAlert(title: "Apple Sign In Error", message: errorMessage)
                }
            }
            .store(in: &cancellables)
        
        // Observe loading state
        appleSignInViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Action Methods
    @objc private func loginButtonTapped() {
        // Check privacy policy agreement first
        guard privacyCheckbox.isSelected else {
            showAlert(title: "Terms Required", message: "Please accept the Terms of Service and Privacy Policy to continue")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password")
            return
        }
        
        // Start loading indicator
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        // Perform login
        Task {
            do {
                let user = try await AuthManager.shared.login(email: email, password: password)
                
                // UI updates must be on main thread
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    loginButton.isEnabled = true
                    
                    // Navigate to main app or select crops screen based on user state
                    navigateAfterLogin(user: user)
                }
            } catch AuthError.invalidCredentials {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    loginButton.isEnabled = true
                    showAlert(title: "Login Failed", message: "Invalid email or password. Please try again.")
                }
            } catch AuthError.rateLimited {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    loginButton.isEnabled = true
                    showAlert(title: "Rate Limit Exceeded", message: "For security purposes, please wait at least 60 seconds before trying again.")
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    loginButton.isEnabled = true
                    showAlert(title: "Login Failed", message: "An error occurred. Please try again later.")
                }
            }
        }
    }
    
    @objc private func appleSignInButtonTapped() {
        // Check privacy policy agreement first
        guard privacyCheckbox.isSelected else {
            showAlert(title: "Terms Required", message: "Please accept the Terms of Service and Privacy Policy to continue")
            return
        }
        
        appleSignInViewModel.signIn()
    }

    @objc private func forgotPasswordButtonTapped() {
        // Push the SwiftUI OTP‐reset flow
        let forgotVC = UIHostingController(rootView: ForgotPasswordView())
        navigationController?.pushViewController(forgotVC, animated: true)
    }

    private func resetPassword(email: String) {
        activityIndicator.startAnimating()
        
        Task {
            do {
                try await AuthManager.shared.resetPassword(email: email)
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    showAlert(title: "Success", message: "Password reset instructions have been sent to your email")
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    showAlert(title: "Error", message: "Failed to send reset instructions. Please try again.")
                }
            }
        }
    }
    
    @objc private func createAccountButtonTapped() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    // MARK: - Navigation
    private func navigateAfterLogin(user: AuthUser) {
        // Check if user has selected crops
        if let selectedCrops = user.selectedCrops, !selectedCrops.isEmpty {
            // User has crops, navigate to main app
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                // Configure the tab bar with data controller
                let dataController = IKisanDataController()
                
                // Set the data controller for each view controller in the tab bar
                if let mainTabBarController = tabBarController as? MainTabBarController {
                    mainTabBarController.dataController = dataController
                }
                
                // Configure individual view controllers
                if let viewControllers = tabBarController.viewControllers {
                    for viewController in viewControllers {
                        if let navController = viewController as? UINavigationController {
                            if let homeVC = navController.viewControllers.first as? HomeViewController {
                                homeVC.dataController = dataController
                            } else if let agriAssistVC = navController.viewControllers.first as? AgriAssistViewController {
                                agriAssistVC.dataController = dataController
                            } else if let coequipVC = navController.viewControllers.first as? CoequipViewController {
                                coequipVC.dataController = dataController
                            }
                        }
                    }
                }
                
                // Set as root view controller
                UIApplication.shared.windows.first?.rootViewController = tabBarController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        } else {
            // User doesn't have crops, navigate to crop selection
            let selectCropsVC = SelectCropsViewController()
            navigationController?.pushViewController(selectCropsVC, animated: true)
        }
    }
    
    private func showNameEntryScreen() {
        let nameEntryVC = NameEntryViewController()
        nameEntryVC.userEmail = appleSignInViewModel.pendingEmail
        nameEntryVC.onNameEntered = { [weak self] name, phone in
            Task {
                await self?.appleSignInViewModel.completeSignInWithName(name, phone: phone)
            }
        }
        nameEntryVC.onCancel = { [weak self] in
            self?.appleSignInViewModel.cancelNameEntry()
        }
        
        // Wrap in navigation controller and present modally
        let navController = UINavigationController(rootViewController: nameEntryVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func navigateAfterAppleSignIn() {
        // Navigate to main app after successful Apple Sign In
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            // Configure the tab bar with data controller
            let dataController = IKisanDataController()
            
            // Set the data controller for each view controller in the tab bar
            if let mainTabBarController = tabBarController as? MainTabBarController {
                mainTabBarController.dataController = dataController
            }
            
            // Configure individual view controllers
            if let viewControllers = tabBarController.viewControllers {
                for viewController in viewControllers {
                    if let navController = viewController as? UINavigationController {
                        if let homeVC = navController.viewControllers.first as? HomeViewController {
                            homeVC.dataController = dataController
                        } else if let agriAssistVC = navController.viewControllers.first as? AgriAssistViewController {
                            agriAssistVC.dataController = dataController
                        } else if let coequipVC = navController.viewControllers.first as? CoequipViewController {
                            coequipVC.dataController = dataController
                        }
                    }
                }
            }
            
            // Set as root view controller
            UIApplication.shared.windows.first?.rootViewController = tabBarController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
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
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            loginButtonTapped()
        }
        return true
    }
}
