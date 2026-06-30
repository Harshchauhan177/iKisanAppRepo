import SwiftUI

struct DeleteAccountView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var confirmationText = ""
    @State private var showFinalConfirmation = false
    @State private var deletionComplete = false
    @Environment(\.dismiss) private var dismiss
    
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    private let requiredText = "DELETE"
    
    var body: some View {
        List {
            // Warning section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        Text("Delete Your Account")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Text("This action is permanent and cannot be undone. All your data will be permanently deleted, including:")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
            
            // Data that will be deleted
            Section(header: Text("Data that will be deleted").font(.headline).foregroundColor(.primary)) {
                Label {
                    Text("Your profile information (name, email, phone)")
                        .font(.body)
                } icon: {
                    Image(systemName: "person.fill")
                        .foregroundColor(.red)
                }
                
                Label {
                    Text("Your saved address and location data")
                        .font(.body)
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                }
                
                Label {
                    Text("Your selected crops and field area")
                        .font(.body)
                } icon: {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.red)
                }
                
                Label {
                    Text("Your profile photo")
                        .font(.body)
                } icon: {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.red)
                }
                
                Label {
                    Text("Your login credentials")
                        .font(.body)
                } icon: {
                    Image(systemName: "key.fill")
                        .foregroundColor(.red)
                }
            }
            
            // Confirmation section
            Section(header: Text("Confirm deletion").font(.headline).foregroundColor(.primary)) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("To confirm, type **\(requiredText)** below:")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    TextField("Type \(requiredText) to confirm", text: $confirmationText)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
            }
            
            // Delete button section
            Section {
                Button(action: {
                    showFinalConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isDeleting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                            Text("Deleting Account...")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                                .padding(.trailing, 4)
                            Text("Delete My Account")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .listRowBackground(
                    (confirmationText == requiredText && !viewModel.isDeleting) ? Color.red : Color.gray.opacity(0.5)
                )
                .disabled(confirmationText != requiredText || viewModel.isDeleting)
            } footer: {
                Text("After deleting your account, you will be signed out and returned to the login screen. You will need to create a new account to use iKisan again.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Are you absolutely sure?",
            isPresented: $showFinalConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete My Account Permanently", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                    
                    // If deletion was successful (no error), navigate to login
                    if viewModel.errorMessage == nil {
                        // Post notification for the hosting controller to handle navigation
                        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .disabled(viewModel.isDeleting)
        .overlay(
            viewModel.isDeleting ?
                Color.black.opacity(0.2)
                .ignoresSafeArea()
                .overlay(
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Text("Deleting your account...")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Please wait")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(radius: 10)
                    )
                )
                : nil
        )
    }
}
