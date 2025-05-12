// ResetPasswordView.swift

import SwiftUI

struct ResetPasswordView: View {
    let email: String

    @State private var otp = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("Enter the 6‑digit code sent to \(email)")
                .font(.subheadline)
                .foregroundColor(.gray)

            TextField("OTP", text: $otp)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .onChange(of: otp) { v in if v.count > 6 { otp = String(v.prefix(6)) } }

            SecureField("New Password", text: $newPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if isLoading {
                ProgressView()
            }

            Button("Reset Password") {
                Task { await reset() }
            }
            .disabled(
                isLoading
                || otp.count != 6
                || newPassword.isEmpty
                || newPassword != confirmPassword
            )
            .frame(maxWidth: .infinity, minHeight: 50)
            //.background(Color.green)
            .background(Color(red: 0.298, green: 0.498, blue: 0.345, opacity: 1))
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Resend OTP") {
                Task { await resend() }
            }
            .disabled(isLoading)

            Spacer()
        }
        .padding()
        .navigationTitle("Reset Password")
        .alert("Message", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage == "Password reset successfully" {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    func reset() async {
        isLoading = true
        do {
//            try await AuthManager.shared.confirmPasswordReset(
//                otp: otp,
//                newPassword: newPassword
//            )
            try await AuthManager.shared.confirmPasswordReset(
                email:       email,
                otp:         otp,
                newPassword: newPassword
            )

            isLoading = false
            alertMessage = "Password reset successfully"
            showAlert = true
        } catch {
            isLoading = false
            alertMessage = "Unable to reset password. Try again."
            showAlert = true
        }
    }

    func resend() async {
        isLoading = true
        do {
            try await AuthManager.shared.resetPassword(email: email)
            isLoading = false
            alertMessage = "OTP resent—check your email."
            showAlert = true
        } catch {
            isLoading = false
            alertMessage = "Failed to resend OTP."
            showAlert = true
        }
    }
}
