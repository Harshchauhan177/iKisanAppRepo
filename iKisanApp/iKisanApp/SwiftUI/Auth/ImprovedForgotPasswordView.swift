//
//  ImprovedForgotPasswordView.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  SwiftUI View - Stateless UI following MVVM architecture
//

import SwiftUI

/// Forgot Password screen with full HIG compliance - Dynamic Type, Dark Mode, Accessibility
struct ImprovedForgotPasswordView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isEmailFocused: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Title Section
                    titleSection
                    
                    // Email Input Section
                    emailInputSection
                    
                    // Send OTP Button
                    sendOTPButton
                    
                    // Instructions
                    instructionsSection
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
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.navigateToResetPassword) {
            ImprovedResetPasswordView(email: viewModel.email)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - View Components
    
    /// Title section with instructions
    private var titleSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                .accessibilityHidden(true)
            
            Text("Forgot Password?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text("Don't worry! Enter your email and we'll send you a code to reset your password")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// Email input section
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email Address")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            TextField("Enter your email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($isEmailFocused)
                .submitLabel(.send)
                .onSubmit {
                    if viewModel.isSendOTPButtonEnabled {
                        Task { await viewModel.sendOTP() }
                    }
                }
                .accessibilityLabel("Email Address")
                .accessibilityHint("Enter the email associated with your account")
        }
    }
    
    /// Send OTP button
    private var sendOTPButton: some View {
        Button {
            isEmailFocused = false
            Task { await viewModel.sendOTP() }
        } label: {
            Text("Send OTP")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.isSendOTPButtonEnabled ?
                    Color(red: 0.298, green: 0.498, blue: 0.345) :
                    Color.gray.opacity(0.5)
                )
                .cornerRadius(10)
        }
        .disabled(!viewModel.isSendOTPButtonEnabled)
        .accessibilityLabel("Send verification code")
        .accessibilityHint(viewModel.isSendOTPButtonEnabled ? "Double tap to send code" : "Enter email to enable")
    }
    
    /// Instructions section
    private var instructionsSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "1.circle.fill")
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check your email")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("We'll send a verification code to your email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "2.circle.fill")
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enter the code")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Enter the 6-digit code from the email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "3.circle.fill")
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reset password")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Create a new secure password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
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
        ImprovedForgotPasswordView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        ImprovedForgotPasswordView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type - Large") {
    NavigationStack {
        ImprovedForgotPasswordView()
    }
    .environment(\.sizeCategory, .accessibilityLarge)
}
