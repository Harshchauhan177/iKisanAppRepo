//
//  OTPVerificationViewModel.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  MVVM Architecture - All business logic for OTP Verification functionality
//

import Foundation
import SwiftUI
import Combine

/// ViewModel handling all OTP verification business logic following MVVM architecture
@MainActor
final class OTPVerificationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var otpDigits: [String] = ["", "", "", "", "", ""]
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var canResend: Bool = true
    @Published var resendCountdown: Int = 0
    
    // MARK: - Private Properties
    private let authManager = AuthManager.shared
    private let email: String
    private var resendTimer: Timer?
    
    // MARK: - Computed Properties
    var isVerifyButtonEnabled: Bool {
        otpDigits.allSatisfy { !$0.isEmpty } && !isLoading
    }
    
    var otpCode: String {
        otpDigits.joined()
    }
    
    // MARK: - Initialization
    init(email: String) {
        self.email = email
    }
    
    deinit {
        resendTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Verify OTP code
    func verifyOTP() async {
        guard validateInput() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authManager.verifyOTP(
                email: email,
                otp: otpCode
            )
            
            print("✅ OTP verification successful for user: \(user.name)")
            
            // Set flag that this is a newly registered user who needs to select crops
            UserDefaults.standard.set(true, forKey: "isNewlyRegisteredUser")
            
            await MainActor.run {
                navigateToCropSelection()
            }
            
        } catch AuthError.invalidOTP {
            showErrorAlert(message: "Invalid verification code. Please try again.")
            clearOTP()
        } catch {
            showErrorAlert(message: "Verification failed. Please check your connection and try again.")
            print("❌ OTP verification error: \(error)")
        }
    }
    
    /// Resend OTP code
    func resendOTP() async {
        guard canResend else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authManager.resendOTP(email: email)
            
            print("✅ OTP resent successfully")
            
            // Start countdown for resend
            startResendCountdown()
            
            // Show success message
            showSuccessMessage(message: "Verification code sent successfully")
            
        } catch AuthError.rateLimited {
            showErrorAlert(message: "Too many attempts. Please try again later.")
        } catch {
            showErrorAlert(message: "Failed to resend code. Please try again.")
            print("❌ Resend OTP error: \(error)")
        }
    }
    
    /// Update OTP digit at specific index
    func updateOTPDigit(at index: Int, with value: String) {
        guard index >= 0 && index < otpDigits.count else { return }
        
        // Only allow single digit
        let filtered = value.filter { $0.isNumber }
        otpDigits[index] = String(filtered.prefix(1))
    }
    
    /// Clear all OTP digits
    func clearOTP() {
        otpDigits = ["", "", "", "", "", ""]
    }
    
    /// Handle backspace for OTP field
    func handleBackspace(at index: Int) -> Bool {
        guard index >= 0 && index < otpDigits.count else { return false }
        
        if otpDigits[index].isEmpty && index > 0 {
            // Move to previous field if current is empty
            return true
        } else {
            // Clear current field
            otpDigits[index] = ""
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// Validate OTP input
    private func validateInput() -> Bool {
        guard otpDigits.allSatisfy({ !$0.isEmpty }) else {
            showErrorAlert(message: "Please enter the complete verification code.")
            return false
        }
        
        guard otpCode.count == 6 else {
            showErrorAlert(message: "Invalid verification code length.")
            return false
        }
        
        return true
    }
    
    /// Show error alert with message
    private func showErrorAlert(message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Show success message
    private func showSuccessMessage(message: String) {
        // Could be implemented with a success alert or toast
        print("✅ \(message)")
    }
    
    /// Start countdown for resend button
    private func startResendCountdown() {
        canResend = false
        resendCountdown = 60
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            Task { @MainActor in
                self.resendCountdown -= 1
                
                if self.resendCountdown <= 0 {
                    self.canResend = true
                    self.resendCountdown = 0
                    timer.invalidate()
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    /// Navigate to crop selection screen after successful registration
    func navigateToCropSelection() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            // Get or create the data controller
            let dataController = IKisanDataController()
            
            // Create the crop selection hosting controller with isFromProfile = false for new users
            let selectCropsVC = SelectCropsHostingController(dataController: dataController, isFromProfile: false)
            let navigationController = UINavigationController(rootViewController: selectCropsVC)
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = navigationController
            }
        }
    }
    
    // MARK: - Helper Methods
}
