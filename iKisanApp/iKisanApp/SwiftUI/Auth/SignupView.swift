//
//  SignupView.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  SwiftUI View - Stateless UI following MVVM architecture
//

import SwiftUI

/// Signup screen with full HIG compliance - Dynamic Type, Dark Mode, Accessibility
struct SignupView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = SignupViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name, email, phone, password, confirmPassword
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Title Section
                    titleSection
                    
                    // Form Section
                    formSection
                    
                    // Privacy Policy Section
                    privacyPolicySection
                    
                    // Signup Button
                    signupButton
                    
                    // Login Navigation
                    loginNavigationButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Loading Overlay
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.navigateToOTPVerification) {
            OTPVerificationView(email: viewModel.registeredEmail)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - View Components
    
    /// Title section with welcome message
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text("Join iKisan to access all features")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// Form section with all input fields
    private var formSection: some View {
        VStack(spacing: 16) {
            // Name TextField
            TextField("Full Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .autocapitalization(.words)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .email
                }
                .accessibilityLabel("Full Name")
                .accessibilityHint("Enter your full name")
            
            // Email TextField
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .phone
                }
                .accessibilityLabel("Email Address")
                .accessibilityHint("Enter your email address")
            
            // Phone TextField
            TextField("Phone Number", text: $viewModel.phone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .focused($focusedField, equals: .phone)
                .onChange(of: viewModel.phone) { oldValue, newValue in
                    // Limit to 10 digits
                    if newValue.count > 10 {
                        viewModel.phone = String(newValue.prefix(10))
                    }
                }
                .accessibilityLabel("Phone Number")
                .accessibilityHint("Enter your 10-digit phone number")
            
            // Password TextField
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .confirmPassword
                }
                .accessibilityLabel("Password")
                .accessibilityHint("Enter a password with at least 6 characters")
            
            // Password Requirements Text
            Text("Password must be at least 6 characters with uppercase, lowercase, and number")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Confirm Password TextField
            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit {
                    if viewModel.isSignupButtonEnabled {
                        Task { await viewModel.signup() }
                    }
                }
                .accessibilityLabel("Confirm Password")
                .accessibilityHint("Re-enter your password to confirm")
        }
    }
    
    /// Privacy policy acceptance section
    private var privacyPolicySection: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                viewModel.togglePrivacyPolicy()
            } label: {
                Image(systemName: viewModel.isPrivacyPolicyAccepted ? "checkmark.square.fill" : "square")
                    .foregroundColor(viewModel.isPrivacyPolicyAccepted ? .blue : .secondary)
                    .font(.system(size: 24))
            }
            .accessibilityLabel("Privacy Policy Agreement")
            .accessibilityHint("Double tap to toggle agreement")
            .accessibilityAddTraits(viewModel.isPrivacyPolicyAccepted ? .isSelected : [])
            
            VStack(alignment: .leading, spacing: 4) {
                Text("I agree to the ")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                + Text("Terms of Service")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
                + Text(" and ")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                + Text("Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
            }
            .onTapGesture {
                openPrivacyPolicy()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("I agree to the Terms of Service and Privacy Policy")
            .accessibilityHint("Double tap to view policy")
        }
        .padding(.vertical, 8)
    }
    
    /// Signup button
    private var signupButton: some View {
        Button {
            focusedField = nil
            Task { await viewModel.signup() }
        } label: {
            Text("Create Account")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.isSignupButtonEnabled ?
                    Color(red: 0.298, green: 0.498, blue: 0.345) :
                    Color.gray.opacity(0.5)
                )
                .cornerRadius(10)
        }
        .disabled(!viewModel.isSignupButtonEnabled)
        .accessibilityLabel("Create a new account")
        .accessibilityHint(viewModel.isSignupButtonEnabled ? "Double tap to create account" : "Complete all fields to enable")
    }
    
    /// Login navigation button
    private var loginNavigationButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Already have an account? Login")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .accessibilityLabel("Return to login screen")
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
    
    // MARK: - Helper Methods
    
    private func openPrivacyPolicy() {
        // Open privacy policy URL
        if let url = URL(string: "https://www.yourapp.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview Provider
#Preview("Light Mode") {
    NavigationStack {
        SignupView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        SignupView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type - Large") {
    NavigationStack {
        SignupView()
    }
    .environment(\.sizeCategory, .accessibilityLarge)
}
