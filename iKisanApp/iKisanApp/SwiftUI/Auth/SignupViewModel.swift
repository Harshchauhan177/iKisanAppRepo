//
//  SignupViewModel.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  MVVM Architecture - All business logic for Signup functionality
//

import Foundation
import SwiftUI
import Combine

/// ViewModel handling all signup business logic following MVVM architecture
@MainActor
final class SignupViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isPrivacyPolicyAccepted: Bool = false
    @Published var navigateToOTPVerification: Bool = false
    @Published var navigateToLogin: Bool = false
    @Published var registeredEmail: String = ""
    
    // MARK: - Private Properties
    private let authManager = AuthManager.shared
    
    // MARK: - Computed Properties
    var isSignupButtonEnabled: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        isPrivacyPolicyAccepted &&
        !isLoading
    }
    
    // MARK: - Public Methods
    
    /// Perform signup with provided credentials
    func signup() async {
        guard validateInput() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let success = try await authManager.register(
                name: trimmedName,
                email: trimmedEmail,
                password: password,
                phone: trimmedPhone
            )
            
            if success {
                print("✅ Signup successful, navigating to OTP verification")
                registeredEmail = trimmedEmail
                await MainActor.run {
                    navigateToOTPVerification = true
                }
            }
            
        } catch AuthError.rateLimited {
            showErrorAlert(message: "Too many attempts. Please try again later.")
        } catch AuthError.registrationFailed {
            showErrorAlert(message: "Registration failed. This email may already be registered.")
        } catch {
            showErrorAlert(message: "Signup failed. Please check your connection and try again.")
            print("❌ Signup error: \(error)")
        }
    }
    
    /// Navigate to login screen
    func navigateToLoginScreen() {
        navigateToLogin = true
    }
    
    /// Toggle privacy policy acceptance
    func togglePrivacyPolicy() {
        isPrivacyPolicyAccepted.toggle()
    }
    
    // MARK: - Private Methods
    
    /// Validate all input fields
    private func validateInput() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate name
        guard !trimmedName.isEmpty else {
            showErrorAlert(message: "Please enter your full name.")
            return false
        }
        
        guard trimmedName.count >= 2 else {
            showErrorAlert(message: "Name must be at least 2 characters long.")
            return false
        }
        
        // Validate email
        guard !trimmedEmail.isEmpty else {
            showErrorAlert(message: "Please enter your email address.")
            return false
        }
        
        guard isValidEmail(trimmedEmail) else {
            showErrorAlert(message: "Please enter a valid email address.")
            return false
        }
        
        // Validate phone
        guard !trimmedPhone.isEmpty else {
            showErrorAlert(message: "Please enter your phone number.")
            return false
        }
        
        guard isValidPhone(trimmedPhone) else {
            showErrorAlert(message: "Please enter a valid phone number (10 digits).")
            return false
        }
        
        // Validate password
        guard !password.isEmpty else {
            showErrorAlert(message: "Please enter a password.")
            return false
        }
        
        guard password.count >= 6 else {
            showErrorAlert(message: "Password must be at least 6 characters long.")
            return false
        }
        
        guard isStrongPassword(password) else {
            showErrorAlert(message: "Password must contain at least one uppercase letter, one lowercase letter, and one number.")
            return false
        }
        
        // Validate password confirmation
        guard !confirmPassword.isEmpty else {
            showErrorAlert(message: "Please confirm your password.")
            return false
        }
        
        guard password == confirmPassword else {
            showErrorAlert(message: "Passwords do not match.")
            return false
        }
        
        // Validate privacy policy acceptance
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
    
    /// Validate phone format (10 digits)
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    /// Check if password is strong enough
    private func isStrongPassword(_ password: String) -> Bool {
        // At least one uppercase letter
        let uppercaseRegex = ".*[A-Z]+.*"
        let uppercaseTest = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        
        // At least one lowercase letter
        let lowercaseRegex = ".*[a-z]+.*"
        let lowercaseTest = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        
        // At least one number
        let numberRegex = ".*[0-9]+.*"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        
        return uppercaseTest.evaluate(with: password) &&
               lowercaseTest.evaluate(with: password) &&
               numberTest.evaluate(with: password)
    }
    
    /// Show error alert with message
    private func showErrorAlert(message: String) {
        errorMessage = message
        showError = true
    }
}
