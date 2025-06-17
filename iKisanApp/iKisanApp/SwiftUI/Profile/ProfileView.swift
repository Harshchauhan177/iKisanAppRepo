import SwiftUI
import Supabase

// Define notification names
extension Notification.Name {
    static let userDidSignOut = Notification.Name("userDidSignOut")
    static let didEnterEditMode = Notification.Name("didEnterEditMode")
    static let didExitEditMode = Notification.Name("didExitEditMode")
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigateToLogin = false
    
    var body: some View {
        // No NavigationStack here since we're using UIKit navigation controller
            List {
                Section {
                if viewModel.isEditMode {
                    // Editable profile header
                    ProfileHeaderView(viewModel: viewModel)
                } else {
                    // Regular profile display
                    VStack(alignment: .center, spacing: 12) {
                        if let avatar = viewModel.avatar {
                            Image(uiImage: avatar)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                                .foregroundColor(viewModel.ikisanGreen)
                            .clipShape(Circle())
                        }
                        
                        Text(viewModel.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.phone)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if !viewModel.address.isEmpty {
                            Text(viewModel.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                }
                
            // Hide these sections in edit mode
            if !viewModel.isEditMode {
                Section("Actions") {
                    NavigationLink(destination: SelectCropsView()) {
                        Label {
                            Text("Select Crops")
                        } icon: {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(viewModel.ikisanGreen)
                        }
                    }
                    
                    NavigationLink(destination: HelpCenterView()) {
                        Label {
                            Text("Help Center")
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(viewModel.ikisanGreen)
                        }
                    }
                    
//                    NavigationLink(destination: PaymentView()) {
//                        Label {
//                            Text("Payment")
//                        } icon: {
//                            Image(systemName: "creditcard.fill")
//                                .foregroundColor(viewModel.ikisanGreen)
//                        }
//                    }
                }
                
                Section("Settings") {
                    NavigationLink(destination: ChangePasswordView()) {
                        Label {
                            Text("Change Password")
                        } icon: {
                            Image(systemName: "lock.fill")
                                .foregroundColor(viewModel.ikisanGreen)
                        }
                    }
                    
                    NavigationLink(destination: UpdateAddressView()) {
                        Label {
                            Text("Update Address")
                        } icon: {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(viewModel.ikisanGreen)
                        }
                    }
                }
                
                Section("Legal") {
                    NavigationLink(destination: TermsPrivacyView()) {
                        Label {
                            Text("Terms & Privacy Policy")
                        } icon: {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(viewModel.ikisanGreen)
                        }
                    }
                    
                    NavigationLink(destination: AppInfoView()) {
                        Label {
                            Text("App Info")
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(viewModel.ikisanGreen)
                        }
                    }
                }
                
                // Move Sign Out to its own section at the bottom
                Section {
                    Button(action: {
                        viewModel.showSignOutConfirmation = true
                    }) {
                        Label {
                        Text("Sign Out")
                            .foregroundColor(.red)
                        } icon: {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                        }
                    }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
            if viewModel.isEditMode {
                // Edit mode toolbar - Cancel button on leading edge
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.cancelEdit()
                        // Notify that we've exited edit mode
                        NotificationCenter.default.post(name: .didExitEditMode, object: nil)
                    }
                }
                
                // Save button on trailing edge
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveChanges()
                            // Notify that we've exited edit mode
                            NotificationCenter.default.post(name: .didExitEditMode, object: nil)
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            } else {
                // Normal mode toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        viewModel.enterEditMode()
                        // Notify that we've entered edit mode
                        NotificationCenter.default.post(name: .didEnterEditMode, object: nil)
                    }
                    }
                }
            }
        .disabled(viewModel.isSaving)
        .overlay(
            viewModel.isSaving ?
                ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
                .background(Color.secondary.opacity(0.2).cornerRadius(8))
                : nil
        )
        .accentColor(viewModel.ikisanGreen)
            .confirmationDialog(
                "Are you sure you want to sign out?",
                isPresented: $viewModel.showSignOutConfirmation
            ) {
                Button("Sign Out", role: .destructive) {
                // Call the updated signOut method with completion handler
                viewModel.signOut { success in
                    if success {
                        // Post notification for signout that the hosting controller can observe
                        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
                    }
                }
                }
                Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will need to sign in again to access your account.")
        }
        .alert(item: Binding<AlertItem?>(
            get: { 
                viewModel.errorMessage != nil ? AlertItem(message: viewModel.errorMessage!) : nil
            },
            set: { newValue in
                viewModel.errorMessage = newValue?.message
            }
        )) { alertItem in
            Alert(
                title: Text("Error"),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            Task {
                await viewModel.fetchProfile()
            }
        }
    }
}

// Helper for binding error messages to alerts
struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Destination Views

// UIViewControllerRepresentable to wrap the UIKit SelectCropsViewController
struct SelectCropsView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SelectCropsViewController {
        // Create the SelectCropsViewController
        let viewController = SelectCropsViewController()
        
        // Configure for profile mode - this ensures it's recognized as coming from profile
        // and will display currently selected crops
        viewController.isFromProfile = true
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SelectCropsViewController, context: Context) {
        // Nothing to update here
    }
}

struct HelpCenterView: View {
    let faqs = [
        (question: "How do I book equipment?", answer: "Navigate to the equipment page and select the 'Book Now' button. Follow the prompts to complete your booking."),
        (question: "Can I cancel my booking?", answer: "Yes, you can cancel your booking up to 24 hours before the scheduled time without any penalty."),
        (question: "How do I contact customer support?", answer: "You can reach our customer support team via email or phone during business hours."),
        (question: "What payment methods are accepted?", answer: "We accept all major credit cards, UPI, and bank transfers.")
    ]
    
    var body: some View {
        List {
            Section(header: Text("Frequently Asked Questions").font(.headline).foregroundColor(.primary)) {
                ForEach(faqs, id: \.question) { faq in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(faq.question)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(faq.answer)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Contact Support").font(.headline).foregroundColor(.primary)) {
                Link(destination: URL(string: "mailto:support@ikisan.com")!) {
                    Label {
                        Text("Email Support")
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    }
                }
                
                Link(destination: URL(string: "tel:+919876543210")!) {
                    Label {
                        Text("Call Support")
                    } icon: {
                        Image(systemName: "phone.fill")
                            .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct PaymentView: View {
//    var body: some View {
//        Text("Payment View")
//            .navigationTitle("Payment")
//            .navigationBarTitleDisplayMode(.inline)
//    }
//}

struct TermsPrivacyView: View {
    var body: some View {
        List {
            Section(header: Text("Terms of Service").font(.headline).foregroundColor(.primary)) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last Updated: May 6, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 8)
                    
                    Text("1. Acceptance of Terms")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 4)
                    
                    Text("By accessing or using the iKisan app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 8)
                    
                    Text("2. User Accounts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 4)
                    
                    Text("You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Privacy Policy").font(.headline).foregroundColor(.primary)) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last Updated: May 6, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 8)
                    
                    Text("1. Information We Collect")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 4)
                    
                    Text("We collect information you provide directly to us, such as your name, email address, phone number, and location when you register for an account.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 8)
                    
                    Text("2. How We Use Your Information")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 4)
                    
                    Text("We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to personalize your experience.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Terms & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppInfoView: View {
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(ikisanGreen)
                        
                        Text("iKisan")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0 (Build 42)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
            }
            
            Section(header: Text("Developer").font(.headline).foregroundColor(.primary)) {
                HStack {
                    Label {
                        Text("iKisan Technologies")
                    } icon: {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(ikisanGreen)
                    }
                }
                
                Link(destination: URL(string: "https://www.ikisan.com")!) {
                    Label {
                        Text("www.ikisan.com")
                    } icon: {
                        Image(systemName: "globe")
                            .foregroundColor(ikisanGreen)
                    }
                }
                
                Link(destination: URL(string: "mailto:contact@ikisan.com")!) {
                    Label {
                        Text("contact@ikisan.com")
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(ikisanGreen)
                    }
                }
            }
            
            Section(header: Text("Legal").font(.headline).foregroundColor(.primary)) {
                NavigationLink(destination: TermsPrivacyView()) {
                    Label {
                        Text("Terms & Privacy Policy")
                    } icon: {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(ikisanGreen)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("App Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ProfileView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
