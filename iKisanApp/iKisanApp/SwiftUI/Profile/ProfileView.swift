import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    
    init() {
        let user = AuthUser(
            id: UUID(),
            email: "farmer@example.com",
            name: "John Farmer",
            phone: "+91 9876543210"
        )
        
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                            .clipShape(Circle())
                        
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
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                Section("Actions") {
                    NavigationLink(destination: SelectCropsView()) {
                        Label {
                            Text("Select Crops")
                        } icon: {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                        }
                    }
                    
                    NavigationLink(destination: HelpCenterView()) {
                        Label {
                            Text("Help Center")
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                        }
                    }
                    
                    NavigationLink(destination: PaymentView()) {
                        Label {
                            Text("Payment")
                        } icon: {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                        }
                    }
                }
                
                Section("Legal") {
                    NavigationLink(destination: TermsPrivacyView()) {
                        Label {
                            Text("Terms & Privacy Policy")
                        } icon: {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                        }
                    }
                    
                    NavigationLink(destination: AppInfoView()) {
                        Label {
                            Text("App Info")
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                        }
                    }
                }
                
                Section("Settings") {
                    NavigationLink(destination: SettingsView()) {
                        Label {
                            Text("Settings")
                        } icon: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.showSignOutConfirmation = true
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        viewModel.enterEditMode()
                    }
                }
            }
            .accentColor(Color(red: 76/255, green: 175/255, blue: 80/255))
            .confirmationDialog(
                "Are you sure you want to sign out?",
                isPresented: $viewModel.showSignOutConfirmation
            ) {
                Button("Sign Out", role: .destructive) {
                    viewModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

// MARK: - Destination Views

struct SelectCropsView: View {
    var body: some View {
        Text("Select Crops View")
            .navigationTitle("Select Crops")
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
                            .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                    }
                }
                
                Link(destination: URL(string: "tel:+919876543210")!) {
                    Label {
                        Text("Call Support")
                    } icon: {
                        Image(systemName: "phone.fill")
                            .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaymentView: View {
    var body: some View {
        Text("Payment View")
            .navigationTitle("Payment")
    }
}

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
    private let ikisanGreen = Color(red: 76/255, green: 175/255, blue: 80/255)
    
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

struct SettingsView: View {
    private let ikisanGreen = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        List {
            NavigationLink(destination: Text("Change Password View").navigationTitle("Change Password")) {
                Label {
                    Text("Change Password")
                } icon: {
                    Image(systemName: "lock.fill")
                        .foregroundColor(ikisanGreen)
                }
            }
            
            NavigationLink(destination: Text("Address View").navigationTitle("Address")) {
                Label {
                    Text("Address")
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(ikisanGreen)
                }
            }
            
            NavigationLink(destination: Text("Email View").navigationTitle("Email")) {
                Label {
                    Text("Email")
                } icon: {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(ikisanGreen)
                }
            }
            
            NavigationLink(destination: Text("Notifications View").navigationTitle("Notifications")) {
                Label {
                    Text("Notifications")
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(ikisanGreen)
                }
            }
            
            Button(action: {
                // Delete account action
            }) {
                Label {
                    Text("Delete Account")
                        .foregroundColor(.red)
                } icon: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
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
