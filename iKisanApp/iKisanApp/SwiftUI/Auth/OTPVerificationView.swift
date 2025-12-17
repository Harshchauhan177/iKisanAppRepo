//
//  OTPVerificationView.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  SwiftUI View - Stateless UI following MVVM architecture
//

import SwiftUI

/// OTP Verification screen with full HIG compliance - Dynamic Type, Dark Mode, Accessibility
struct OTPVerificationView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: OTPVerificationViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Int?
    
    private let email: String
    
    // MARK: - Initialization
    init(email: String) {
        self.email = email
        _viewModel = StateObject(wrappedValue: OTPVerificationViewModel(email: email))
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
                    
                    // Verify Button
                    verifyButton
                    
                    // Resend Section
                    resendSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Email Verification")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLoading)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            // Auto-focus first field
            focusedField = 0
        }
    }
    
    // MARK: - View Components
    
    /// Title section with instructions
    private var titleSection: some View {
        VStack(spacing: 16) {
            Text("Email Verification")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text("We've sent a verification code to")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(email)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Please enter the code to verify your account")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// OTP input section with 6 digit fields
    private var otpInputSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                OTPDigitField(
                    text: Binding(
                        get: { viewModel.otpDigits[index] },
                        set: { newValue in
                            viewModel.updateOTPDigit(at: index, with: newValue)
                            
                            // Auto-focus next field
                            if !newValue.isEmpty && index < 5 {
                                focusedField = index + 1
                            }
                        }
                    ),
                    isFocused: focusedField == index
                )
                .focused($focusedField, equals: index)
                .onChange(of: viewModel.otpDigits[index]) { oldValue, newValue in
                    // Handle backspace
                    if newValue.isEmpty && oldValue.isEmpty && index > 0 {
                        focusedField = index - 1
                    }
                }
                .accessibilityLabel("Digit \(index + 1) of 6")
                .accessibilityHint("Enter verification code digit")
            }
        }
        .padding(.vertical, 20)
    }
    
    /// Verify button
    private var verifyButton: some View {
        Button {
            focusedField = nil
            Task { await viewModel.verifyOTP() }
        } label: {
            Text("Verify")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.isVerifyButtonEnabled ?
                    Color(red: 0.298, green: 0.498, blue: 0.345) :
                    Color.gray.opacity(0.5)
                )
                .cornerRadius(10)
        }
        .disabled(!viewModel.isVerifyButtonEnabled)
        .accessibilityLabel("Verify code")
        .accessibilityHint(viewModel.isVerifyButtonEnabled ? "Double tap to verify" : "Enter all digits to enable")
    }
    
    /// Resend section with countdown
    private var resendSection: some View {
        VStack(spacing: 12) {
            if viewModel.canResend {
                Button {
                    Task { await viewModel.resendOTP() }
                } label: {
                    Text("Resend Code")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.isLoading)
                .accessibilityLabel("Resend verification code")
            } else {
                Text("Resend code in \(viewModel.resendCountdown)s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("You can resend code in \(viewModel.resendCountdown) seconds")
            }
            
            Text("Didn't receive the code?")
                .font(.caption)
                .foregroundColor(.secondary)
        }
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

// MARK: - OTP Digit Field Component
struct OTPDigitField: View {
    @Binding var text: String
    let isFocused: Bool
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.title)
            .fontWeight(.semibold)
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
            .onChange(of: text) { oldValue, newValue in
                // Limit to single digit
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
            }
    }
}

// MARK: - Preview Provider
#Preview("Light Mode") {
    NavigationStack {
        OTPVerificationView(email: "user@example.com")
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        OTPVerificationView(email: "user@example.com")
    }
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type - Large") {
    NavigationStack {
        OTPVerificationView(email: "user@example.com")
    }
    .environment(\.sizeCategory, .accessibilityLarge)
}
