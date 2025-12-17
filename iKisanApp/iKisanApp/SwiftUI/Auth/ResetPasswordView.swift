//
//  ImprovedResetPasswordView.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  SwiftUI View - Stateless UI following MVVM architecture
//

import SwiftUI

/// Reset Password screen with full HIG compliance - Dynamic Type, Dark Mode, Accessibility
struct ImprovedResetPasswordView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: ResetPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedOTPField: Int?
    @FocusState private var focusedPasswordField: PasswordField?
    
    private let email: String
    
    private enum PasswordField {
        case newPassword, confirmPassword
    }
    
    // MARK: - Initialization
    init(email: String) {
        self.email = email
        _viewModel = StateObject(wrappedValue: ResetPasswordViewModel(email: email))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Title Section
                    titleSection
                    
                    // OTP Input Section
                    otpInputSection
                    
                    // Password Input Section
                    passwordInputSection
                    
                    // Reset Button
                    resetButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Loading Overlay
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLoading)
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your password has been reset successfully. Please login with your new password.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onChange(of: viewModel.navigateToLogin) { _, shouldNavigate in
            if shouldNavigate {
                dismiss()
            }
        }
    }
    
    // MARK: - View Components
    
    /// Title section with instructions
    private var titleSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                .accessibilityHidden(true)
            
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text("Enter the verification code sent to")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(email)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// OTP input section
    private var otpInputSection: some View {
        VStack(spacing: 16) {
            Text("Verification Code")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitField(
                        text: Binding(
                            get: { viewModel.otpDigits[index] },
                            set: { newValue in
                                viewModel.updateOTPDigit(at: index, with: newValue)
                                
                                // Auto-focus next field
                                if !newValue.isEmpty && index < 5 {
                                    focusedOTPField = index + 1
                                } else if !newValue.isEmpty && index == 5 {
                                    // Move to password field after last OTP digit
                                    focusedOTPField = nil
                                    focusedPasswordField = .newPassword
                                }
                            }
                        ),
                        isFocused: focusedOTPField == index
                    )
                    .focused($focusedOTPField, equals: index)
                    .onChange(of: viewModel.otpDigits[index]) { oldValue, newValue in
                        // Handle backspace
                        if newValue.isEmpty && oldValue.isEmpty && index > 0 {
                            focusedOTPField = index - 1
                        }
                    }
                    .accessibilityLabel("Digit \(index + 1) of 6")
                }
            }
        }
    }
    
    /// Password input section
    private var passwordInputSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("New Password")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                SecureField("Enter new password", text: $viewModel.newPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .focused($focusedPasswordField, equals: .newPassword)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedPasswordField = .confirmPassword
                    }
                    .accessibilityLabel("New Password")
                    .accessibilityHint("Enter a password with at least 6 characters")
                
                Text("Password must be at least 6 characters with uppercase, lowercase, and number")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                SecureField("Confirm new password", text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
                    .focused($focusedPasswordField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onSubmit {
                        if viewModel.isResetButtonEnabled {
                            Task { await viewModel.resetPassword() }
                        }
                    }
                    .accessibilityLabel("Confirm Password")
                    .accessibilityHint("Re-enter your password to confirm")
            }
        }
    }
    
    /// Reset button
    private var resetButton: some View {
        Button {
            focusedOTPField = nil
            focusedPasswordField = nil
            Task { await viewModel.resetPassword() }
        } label: {
            Text("Reset Password")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.isResetButtonEnabled ?
                    Color(red: 0.298, green: 0.498, blue: 0.345) :
                    Color.gray.opacity(0.5)
                )
                .cornerRadius(10)
        }
        .disabled(!viewModel.isResetButtonEnabled)
        .accessibilityLabel("Reset password")
        .accessibilityHint(viewModel.isResetButtonEnabled ? "Double tap to reset" : "Complete all fields to enable")
    }
    
    /// Loading overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(.white)
                .accessibilityLabel("Loading")
        }
    }
}

// MARK: - Preview Provider
#Preview("Light Mode") {
    NavigationStack {
        ImprovedResetPasswordView(email: "user@example.com")
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        ImprovedResetPasswordView(email: "user@example.com")
    }
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type - Large") {
    NavigationStack {
        ImprovedResetPasswordView(email: "user@example.com")
    }
    .environment(\.sizeCategory, .accessibilityLarge)
}
