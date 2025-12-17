//
//  LoginViewModel.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  MVVM Architecture - All business logic for Login functionality
//

import Foundation
import SwiftUI
import Combine
import AuthenticationServices

/// ViewModel handling all login business logic following MVVM architecture
@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isPrivacyPolicyAccepted: Bool = false
    @Published var navigateToHome: Bool = false
    @Published var navigateToSignup: Bool = false
    @Published var navigateToForgotPassword: Bool = false
    
    // MARK: - Private Properties
    private let authManager = AuthManager.shared
    private let appleSignInViewModel = SignInWithAppleViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isLoginButtonEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        isPrivacyPolicyAccepted &&
        !isLoading
    }
    
    var isAppleSignInEnabled: Bool {
        isPrivacyPolicyAccepted && !isLoading
    }
    
    // MARK: - Initialization
    init() {
        setupAppleSignInObservers()
    }
    
    // MARK: - Public Methods
    
    /// Perform login with email and password
    func login() async {
        guard validateInput() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let user = try await authManager.login(
                email: trimmedEmail,
                password: password
            )
            
            print("✅ Login successful for user: \(user.name)")
            
            // Navigate to main app after successful login
            await MainActor.run {
                navigateToMainApp()
            }
            
        } catch AuthError.invalidCredentials {
            showErrorAlert(message: "Invalid email or password. Please try again.")
        } catch {
            showErrorAlert(message: "Login failed. Please check your connection and try again.")
            print("❌ Login error: \(error)")
        }
    }
    
    /// Initiate Apple Sign In flow
    func initiateAppleSignIn() {
        guard isPrivacyPolicyAccepted else {
            showErrorAlert(message: "Please accept the Terms of Service and Privacy Policy to continue.")
            return
        }
        
        appleSignInViewModel.signIn()
    }
    
    /// Navigate to signup screen
    func navigateToSignupScreen() {
        navigateToSignup = true
    }
    
    /// Navigate to forgot password screen
    func navigateToForgotPasswordScreen() {
        navigateToForgotPassword = true
    }
    
    /// Toggle privacy policy acceptance
    func togglePrivacyPolicy() {
        isPrivacyPolicyAccepted.toggle()
    }
    
    // MARK: - Private Methods
    
    /// Validate input fields
    private func validateInput() -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            showErrorAlert(message: "Please enter your email address.")
            return false
        }
        
        guard isValidEmail(trimmedEmail) else {
            showErrorAlert(message: "Please enter a valid email address.")
            return false
        }
        
        guard !password.isEmpty else {
            showErrorAlert(message: "Please enter your password.")
            return false
        }
        
        guard isPrivacyPolicyAccepted else {
            showErrorAlert(message: "Please accept the Terms of Service and Privacy Policy to continue.")
            return false
        }
        
        return true
    }
    
    /// Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Show error alert with message
    private func showErrorAlert(message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Setup observers for Apple Sign In flow
    private func setupAppleSignInObservers() {
        // Observe authentication success
        appleSignInViewModel.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.navigateToMainApp()
                }
            }
            .store(in: &cancellables)
        
        // Observe error messages
        appleSignInViewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)
        
        // Observe navigation to home
        appleSignInViewModel.$navigateToHome
            .sink { [weak self] shouldNavigate in
                if shouldNavigate {
                    self?.navigateToMainApp()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Get Apple Sign In View Model (for view binding)
    func getAppleSignInViewModel() -> SignInWithAppleViewModel {
        return appleSignInViewModel
    }
    
    /// Navigate to main app (TabBar) after successful login
    /// CRITICAL: Must initialize dataController and pass it to MainTabBarController BEFORE viewDidLoad
    private func navigateToMainApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                
                // CRITICAL: Initialize data controller - required for app to function
                let dataController = IKisanDataController()
                
                // CRITICAL: Set the data controller BEFORE setting as root view controller
                // This ensures MainTabBarController.viewDidLoad() has access to dataController
                if let mainTabBarController = tabBarController as? MainTabBarController {
                    mainTabBarController.dataController = dataController
                    print("✅ LoginViewModel: dataController set on MainTabBarController")
                }
                
                // Transition to main app with animation
                // The MainTabBarController.viewDidLoad() will now distribute dataController to all child VCs
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                    window.rootViewController = tabBarController
                }
            }
        }
    }
}
