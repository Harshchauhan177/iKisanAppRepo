//
//  ForgotPasswordViewModel.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  MVVM Architecture - All business logic for Forgot Password functionality
//

import Foundation
import SwiftUI
import Combine

/// ViewModel handling all forgot password business logic following MVVM architecture
@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var navigateToResetPassword: Bool = false
    
    // MARK: - Private Properties
    private let authManager = AuthManager.shared
    
    // MARK: - Computed Properties
    var isSendOTPButtonEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    // MARK: - Public Methods
    
    /// Send OTP for password reset
    func sendOTP() async {
        guard validateInput() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try await authManager.resetPassword(email: trimmedEmail)
            
            print("✅ Password reset OTP sent successfully")
            
            await MainActor.run {
                navigateToResetPassword = true
            }
            
        } catch AuthError.rateLimited {
            showErrorAlert(message: "Too many attempts. Please try again later.")
        } catch {
            showErrorAlert(message: "Failed to send OTP. Please check your email and try again.")
            print("❌ Send OTP error: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Validate email input
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
}
