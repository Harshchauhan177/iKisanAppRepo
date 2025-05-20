import SwiftUI

struct SelectFarmerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var farmers: [User] = []
    @State private var filteredFarmers: [User] = []
    @State private var selectedFarmers: [User] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true
    @State private var showFilterOptions: Bool = false
    @State private var selectedFilter: FilterOption = .all
    
    // Reference to data controller for fetching users
    var dataController: DataController
    
    // Callback for when farmers are selected
    var onSelectionComplete: ([User]) -> Void
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case contacts = "Contacts"
        case proximity = "Within 1km"
        case previous = "Previous"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("Search", text: $searchText)
                            .padding(.vertical, 8)
                            .onChange(of: searchText) { _ in
                                filterFarmers()
                            }
                    }
                    .padding(.trailing, 8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter button
                    Button(action: {
                        showFilterOptions.toggle()
                    }) {
                        Text(selectedFilter.rawValue)
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.darkGray))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(Color(UIColor.darkGray))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        Group {
                            if showFilterOptions {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(FilterOption.allCases, id: \.self) { option in
                                        Button(action: {
                                            selectedFilter = option
                                            showFilterOptions = false
                                            filterFarmers()
                                        }) {
                                            Text(option.rawValue)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .frame(width: 120, alignment: .leading)
                                        }
                                        .background(Color.white)
                                        
                                        if option != FilterOption.allCases.last {
                                            Divider()
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                .offset(y: 50)
                                .zIndex(1)
                            }
                        }
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // User list
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if filteredFarmers.isEmpty {
                    VStack {
                        Spacer()
                        Text("No farmers found")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredFarmers, id: \.userID) { farmer in
                            HStack {
                                // User information
                                VStack(alignment: .leading) {
                                    Text(farmer.name)
                                        .font(.headline)
                                    Text(farmer.location.address ?? "No address")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Checkmark for selected users
                                if selectedFarmers.contains(where: { $0.userID == farmer.userID }) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleFarmerSelection(farmer)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Select Farmers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSelectionComplete(selectedFarmers)
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadFarmers()
                
                // Register for notifications when users are loaded
                NotificationCenter.default.addObserver(forName: .usersLoaded, object: nil, queue: .main) { _ in
                    updateFarmersFromCache()
                }
            }
            .onDisappear {
                // Remove observer when view disappears
                NotificationCenter.default.removeObserver(self, name: .usersLoaded, object: nil)
            }
            .onTapGesture {
                // Dismiss the filter options dropdown when tapping outside
                showFilterOptions = false
            }
        }
    }
    
    private func loadFarmers() {
        isLoading = true
        let initialUsers = dataController.getCoEquipUsers()
        if !initialUsers.isEmpty {
            self.farmers = initialUsers
            self.filterFarmers()
            self.isLoading = false
        } else {
            self.isLoading = false
        }
    }
    
    private func updateFarmersFromCache() {
        // This will be called when the usersLoaded notification is received
        let cachedUsers = dataController.getCoEquipUsers()
        self.farmers = cachedUsers
        self.filterFarmers()
        self.isLoading = false
    }
    
    private func filterFarmers() {
        // First apply search filter
        var filtered = farmers
        
        if !searchText.isEmpty {
            filtered = filtered.filter { farmer in
                farmer.name.lowercased().contains(searchText.lowercased()) ||
                (farmer.location.address ?? "").lowercased().contains(searchText.lowercased())
            }
        }
        
        // Then apply category filter
        switch selectedFilter {
        case .contacts:
            // In a real app, this would filter for user's contacts
            // For now, we'll just simulate it with a simplified filter
            filtered = filtered.filter { $0.name.count > 5 }
        case .proximity:
            // In a real app, this would filter based on location proximity
            // For now, we'll just simulate it by taking the first few farmers
            if let currentUser = AuthManager.shared.currentUser {
                filtered = filtered.filter { farmer in
                    // Simple distance calculation for demonstration
                    let distance = calculateDistance(
                        lat1: currentUser.latitude,
                        lon1: currentUser.longitude,
                        lat2: farmer.location.latitude,
                        lon2: farmer.location.longitude
                    )
                    return distance < 1.0 // Within 1km
                }
            }
        case .previous:
            // In a real app, this would show previously selected farmers
            // For now, we'll just simulate with another simple filter
            filtered = filtered.filter { $0.name.starts(with: "A") || $0.name.starts(with: "B") }
        case .all:
            // No additional filtering
            break
        }
        
        filteredFarmers = filtered
    }
    
    private func toggleFarmerSelection(_ farmer: User) {
        if let index = selectedFarmers.firstIndex(where: { $0.userID == farmer.userID }) {
            selectedFarmers.remove(at: index)
        } else {
            selectedFarmers.append(farmer)
        }
    }
    
    // Simple haversine distance calculation
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0 // in kilometers
        
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return earthRadius * c
    }
}

// UIKit wrapper to use SwiftUI view in UIKit
class SelectFarmerViewController: UIViewController {
    private var hostingController: UIHostingController<SelectFarmerView>?
    var dataController: DataController!
    var selectedUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let user = try await AuthManager.shared.login(email: "your@email.com", password: "yourPassword")
                print("✅ Logged in as \(user.name)")
                // Now present SelectFarmerView
                let selectFarmerView = SelectFarmerView(
                    dataController: self.dataController ?? IKisanDataController(),
                    onSelectionComplete: { [weak self] selectedFarmers in
                        self?.selectedUsers = selectedFarmers
                    }
                )
                let hostingController = UIHostingController(rootView: selectFarmerView)
                hostingController.modalPresentationStyle = .fullScreen
                self.present(hostingController, animated: true)
            } catch {
                print("❌ Login failed: \(error)")
                // Show an error to the user
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToInfoTable" {
            if let destinationVC = segue.destination as? InfoTableViewController {
                destinationVC.selectedUsers = selectedUsers
            }
        }
    }
} 
