// ForgotPasswordView.swift

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var goToReset = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if isLoading {
                    ProgressView()
                }

                Button("Send OTP") {
                    Task { await sendOTP() }
                }
                .disabled(isLoading || email.isEmpty)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                NavigationLink(
                    destination: ResetPasswordView(email: email),
                    isActive: $goToReset
                ) { EmptyView() }

                Spacer()
            }
            .padding()
            .navigationTitle("Forgot Password")
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    func sendOTP() async {
        isLoading = true
        do {
            try await AuthManager.shared.resetPassword(email: email)
            isLoading = false
            goToReset = true
        } catch {
            isLoading = false
            alertMessage = "Failed to send OTP. Try again."
            showAlert = true
        }
    }
}
