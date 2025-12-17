//
//  LoginView.swift
//  iKisanApp
//
//  Created by GitHub Copilot
//  SwiftUI View - Stateless UI following MVVM architecture
//

import SwiftUI
import AuthenticationServices

/// Login screen with full HIG compliance - Dynamic Type, Dark Mode, Accessibility
struct LoginView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case email, password
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo Section
                        logoSection
                        
                        // Welcome Text Section
                        welcomeSection
                        
                        // Form Section
                        formSection
                        
                        // Privacy Policy Section
                        privacyPolicySection
                        
                        // Buttons Section
                        buttonsSection
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
            .navigationDestination(isPresented: $viewModel.navigateToHome) {
                // Navigate to home - placeholder
                Text("Home Screen")
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $viewModel.navigateToSignup) {
                SignupView()
            }
            .navigationDestination(isPresented: $viewModel.navigateToForgotPassword) {
                ImprovedForgotPasswordView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    /// Logo section with app branding
    private var logoSection: some View {
        Image("iKisan")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .accessibilityLabel("iKisan Logo")
            .accessibilityAddTraits(.isImage)
    }
    
    /// Welcome text section
    private var welcomeSection: some View {
        VStack(spacing: 8) {
            Text("Welcome to iKisan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text("Sign in to continue")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// Form section with text fields and login button
    private var formSection: some View {
        VStack(spacing: 16) {
            // Email TextField
            VStack(alignment: .leading, spacing: 6) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                    .accessibilityLabel("Email Address")
                    .accessibilityHint("Enter your email address")
            }
            
            // Password TextField
            VStack(alignment: .leading, spacing: 6) {
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit {
                        if viewModel.isLoginButtonEnabled {
                            Task { await viewModel.login() }
                        }
                    }
                    .accessibilityLabel("Password")
                    .accessibilityHint("Enter your password")
            }
            
            // Login Button
            Button {
                focusedField = nil
                Task { await viewModel.login() }
            } label: {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        viewModel.isLoginButtonEnabled ?
                        Color(red: 0.298, green: 0.498, blue: 0.345) :
                        Color.gray.opacity(0.5)
                    )
                    .cornerRadius(10)
            }
            .disabled(!viewModel.isLoginButtonEnabled)
            .accessibilityLabel("Log in to your account")
            .accessibilityHint(viewModel.isLoginButtonEnabled ? "Double tap to log in" : "Complete all fields and accept privacy policy to enable")
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
                // Open privacy policy in browser or modal
                openPrivacyPolicy()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("I agree to the Terms of Service and Privacy Policy")
            .accessibilityHint("Double tap to view policy")
        }
        .padding(.vertical, 8)
    }
    
    /// Buttons section with Apple Sign In and navigation buttons
    private var buttonsSection: some View {
        VStack(spacing: 16) {
            // Apple Sign In Button
            SignInWithAppleButtonView(viewModel: viewModel.getAppleSignInViewModel())
                .frame(height: 50)
                .cornerRadius(10)
                .disabled(!viewModel.isAppleSignInEnabled)
                .opacity(viewModel.isAppleSignInEnabled ? 1.0 : 0.5)
                .accessibilityLabel("Sign in with Apple")
                .accessibilityHint(viewModel.isAppleSignInEnabled ? "Double tap to sign in with Apple" : "Accept privacy policy to enable")
            
            // Forgot Password Button
            Button {
                viewModel.navigateToForgotPasswordScreen()
            } label: {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel("Forgot Password? Tap to reset")
            
            // Create Account Button
            Button {
                viewModel.navigateToSignupScreen()
            } label: {
                Text("New user? Create Account")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel("New user? Create Account")
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
    
    // MARK: - Helper Methods
    
    private func openPrivacyPolicy() {
        // Open privacy policy URL
        if let url = URL(string: "https://www.yourapp.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Apple Sign In Button Wrapper
struct SignInWithAppleButtonView: UIViewRepresentable {
    let viewModel: SignInWithAppleViewModel
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black
        )
        button.cornerRadius = 10
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleAppleSignIn),
            for: .touchUpInside
        )
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject {
        let viewModel: SignInWithAppleViewModel
        
        init(viewModel: SignInWithAppleViewModel) {
            self.viewModel = viewModel
        }
        
        @objc func handleAppleSignIn() {
            viewModel.signIn()
        }
    }
}

// MARK: - Preview Provider
#Preview("Light Mode") {
    LoginView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    LoginView()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type - Large") {
    LoginView()
        .environment(\.sizeCategory, .accessibilityLarge)
}
