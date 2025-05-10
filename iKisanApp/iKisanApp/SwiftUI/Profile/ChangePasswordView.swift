import SwiftUI
import Supabase

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    // Green color used throughout the app
    private let ikisanGreen = Color(red: 76/255, green: 175/255, blue: 80/255)
    private let supabase = SupabaseManager.shared
    
    var body: some View {
        List {
            Section(header: Text("Current Password")) {
                SecureField("Enter current password", text: $currentPassword)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section(header: Text("New Password")) {
                SecureField("Enter new password", text: $newPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Confirm new password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    changePassword()
                }
                .disabled(isLoading || !isFormValid)
            }
        }
        .overlay(
            ZStack {
                if isLoading {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .tint(ikisanGreen)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        )
                }
            }
        )
        .alert("Password Changed", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your password has been successfully updated.")
        }
    }
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty && 
        !newPassword.isEmpty && 
        !confirmPassword.isEmpty && 
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    private func changePassword() {
        guard isFormValid else {
            if newPassword != confirmPassword {
                errorMessage = "New passwords don't match"
            } else if newPassword.count < 6 {
                errorMessage = "Password must be at least 6 characters"
            } else {
                errorMessage = "Please fill in all fields"
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Update password via Supabase - using the correct API method
                try await supabase.client.auth.update(
                    user: .init(
                        password: newPassword
                    )
                )
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to change password: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ChangePasswordView()
    }
} 