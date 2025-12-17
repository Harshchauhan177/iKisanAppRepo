//
//  ResetPasswordViewModel.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  MVVM Architecture - All business logic for Reset Password functionality
//

import Foundation
import SwiftUI
import Combine

/// ViewModel handling all reset password business logic following MVVM architecture
@MainActor
final class ResetPasswordViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var otpDigits: [String] = ["", "", "", "", "", ""]
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false
    @Published var navigateToLogin: Bool = false
    
    // MARK: - Private Properties
    private let authManager = AuthManager.shared
    private let email: String
    
    // MARK: - Computed Properties
    var isResetButtonEnabled: Bool {
        otpDigits.allSatisfy { !$0.isEmpty } &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        !isLoading
    }
    
    var otpCode: String {
        otpDigits.joined()
    }
    
    // MARK: - Initialization
    init(email: String) {
        self.email = email
    }
    
    // MARK: - Public Methods
    
    /// Reset password with OTP and new password
    func resetPassword() async {
        guard validateInput() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authManager.confirmPasswordReset(
                email: email,
                otp: otpCode,
                newPassword: newPassword
            )
            
            print("✅ Password reset successful")
            
            await MainActor.run {
                showSuccess = true
            }
            
            // Wait 2 seconds then navigate to login
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                navigateToLogin = true
            }
            
        } catch AuthError.invalidOTP {
            showErrorAlert(message: "Invalid verification code. Please try again.")
        } catch {
            showErrorAlert(message: "Password reset failed. Please try again.")
            print("❌ Reset password error: \(error)")
        }
    }
    
    /// Update OTP digit at specific index
    func updateOTPDigit(at index: Int, with value: String) {
        guard index >= 0 && index < otpDigits.count else { return }
        
        // Only allow single digit
        let filtered = value.filter { $0.isNumber }
        otpDigits[index] = String(filtered.prefix(1))
    }
    
    // MARK: - Private Methods
    
    /// Validate all inputs
    private func validateInput() -> Bool {
        // Validate OTP
        guard otpDigits.allSatisfy({ !$0.isEmpty }) else {
            showErrorAlert(message: "Please enter the complete verification code.")
            return false
        }
        
        guard otpCode.count == 6 else {
            showErrorAlert(message: "Invalid verification code length.")
            return false
        }
        
        // Validate new password
        guard !newPassword.isEmpty else {
            showErrorAlert(message: "Please enter a new password.")
            return false
        }
        
        guard newPassword.count >= 6 else {
            showErrorAlert(message: "Password must be at least 6 characters long.")
            return false
        }
        
        guard isStrongPassword(newPassword) else {
            showErrorAlert(message: "Password must contain at least one uppercase letter, one lowercase letter, and one number.")
            return false
        }
        
        // Validate confirm password
        guard !confirmPassword.isEmpty else {
            showErrorAlert(message: "Please confirm your new password.")
            return false
        }
        
        guard newPassword == confirmPassword else {
            showErrorAlert(message: "Passwords do not match.")
            return false
        }
        
        return true
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
