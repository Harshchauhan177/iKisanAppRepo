import SwiftUI

struct UserListView: View {
    @State private var users: [User] = []
    @State private var isLoading: Bool = true
    @State private var searchText: String = ""
    @State private var showDetails: Bool = false
    @State private var selectedUser: User?
    
    var dataController: DataController
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.lowercased().contains(searchText.lowercased()) ||
                user.email.lowercased().contains(searchText.lowercased()) ||
                user.phone.contains(searchText) ||
                (user.location.address ?? "").lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    
                    TextField("Search users", text: $searchText)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if users.isEmpty {
                    Text("No users found")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredUsers, id: \.userID) { user in
                            UserRow(user: user)
                                .onTapGesture {
                                    selectedUser = user
                                    showDetails = true
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Users")
            .onAppear {
                loadUsers()
            }
            .sheet(isPresented: $showDetails) {
                if let user = selectedUser {
                    UserDetailView(user: user)
                }
            }
        }
    }
    
    private func loadUsers() {
        isLoading = true
        print("🔄 Starting to load users...")
        
        Task {
            print("📱 Fetching users from RequestManager...")
            let fetchedUsers = await RequestManager.shared.fetchAllUsers()
            print("📊 Fetched \(fetchedUsers.count) users from database")
            
            // Print details of each user for debugging
            for user in fetchedUsers {
                print("👤 User: \(user.name), ID: \(user.userID), Email: \(user.email)")
            }
            
            // Update the UI on the main thread
            await MainActor.run {
                self.users = fetchedUsers
                self.isLoading = false
                print("✅ Updated UI with \(self.users.count) users")
                
                if self.users.isEmpty {
                    print("⚠️ Warning: No users loaded into the view")
                }
            }
        }
    }
}

struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack {
            // Avatar placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.name.prefix(1))
                        .font(.title2)
                        .foregroundColor(.gray)
                )
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let address = user.location.address, !address.isEmpty {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Phone number with icon
            VStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                Text(user.phone)
                    .font(.footnote)
            }
        }
        .padding(.vertical, 4)
    }
}

struct UserDetailView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with avatar
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(user.name.prefix(1))
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    // Contact Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Details")
                            .font(.headline)
                        
                        DetailRow(icon: "phone.fill", title: "Phone", value: user.phone)
                        
                        if let address = user.location.address {
                            DetailRow(icon: "location.fill", title: "Address", value: address)
                        }
                        
                        DetailRow(icon: "map", title: "Coordinates", value: "\(String(format: "%.6f", user.location.latitude)), \(String(format: "%.6f", user.location.longitude))")
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    // Farming Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Farming Details")
                            .font(.headline)
                        
                        DetailRow(icon: "ruler", title: "Field Area", value: "\(String(format: "%.2f", user.fieldArea)) hectares")
                        
                        if !user.selectedCrops.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                    Text("Selected Crops")
                                        .font(.subheadline)
                                }
                                
                                Text("\(user.selectedCrops.count) crops selected")
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    // Map view (placeholder)
                    VStack(alignment: .leading) {
                        Text("Location")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Text("Map View")
                                    .foregroundColor(.gray)
                            )
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("User Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
            }
            
            Text(value)
                .font(.body)
        }
    }
}

// UIKit wrapper to use SwiftUI view in UIKit
class UserListViewController: UIViewController {
    private var hostingController: UIHostingController<SelectableUserListView>?
    var dataController: DataController!
    
    // Callback for when a user is selected
    var onUserSelected: ((User) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userListView = SelectableUserListView(
            dataController: dataController,
            onUserSelected: { [weak self] user in
                self?.onUserSelected?(user)
                self?.dismiss(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: userListView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
        
        // Add a cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissModal)
        )
    }

    @objc private func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
}


// Variation of UserListView with selection capability
struct SelectableUserListView: View {
    @State private var users: [User] = []
    @State private var isLoading: Bool = true
    @State private var searchText: String = ""
    
    var dataController: DataController
    var onUserSelected: (User) -> Void
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.lowercased().contains(searchText.lowercased()) ||
                user.email.lowercased().contains(searchText.lowercased()) ||
                user.phone.contains(searchText) ||
                (user.location.address ?? "").lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                TextField("Search farmers", text: $searchText)
                    .padding(.vertical, 10)
            }
            .padding(.horizontal)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if users.isEmpty {
                Text("No farmers found")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredUsers, id: \.userID) { user in
                        SelectableUserRow(user: user)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onUserSelected(user)
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Select Farmer")
        .onAppear {
            loadUsers()
        }
    }
    
    private func loadUsers() {
        isLoading = true
        
        Task {
            // Use the DataController to fetch users in the background
            let fetchedUsers = await RequestManager.shared.fetchAllUsers()
            
            // Update the UI on the main thread
            await MainActor.run {
                self.users = fetchedUsers
                self.isLoading = false
            }
        }
    }
}

struct SelectableUserRow: View {
    let user: User
    
    var body: some View {
        HStack {
            // Avatar placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.name.prefix(1))
                        .font(.title2)
                        .foregroundColor(.gray)
                )
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                
                if let address = user.location.address, !address.isEmpty {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Phone number with icon
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
} 
