import SwiftUI
import CoreLocation

struct SelectFarmerView: View {
    let dataController: DataController
    let onFarmerSelection: ([User]) -> Void
    @State private var selectedFarmers: Set<User> = []
    @State private var searchText = ""
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var selectedFilter = FilterOption.all
    @State private var currentUserLocation: CLLocation?
    @Environment(\.dismiss) private var dismiss

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case oneKm = "1 Km"
        case contact = "Contact"
        case previous = "Previous"
    }

    var filteredUsers: [User] {
        var filtered = users
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            return filtered
            
        case .oneKm:
            guard let currentLocation = currentUserLocation else { return [] }
            return filtered.filter { user in
                let userLocation = CLLocation(latitude: user.location.latitude, longitude: user.location.longitude)
                let distance = currentLocation.distance(from: userLocation) / 1000 // Convert to kilometers
                return distance <= 1.0
            }
            
        case .contact:
            // Filter users who are in contacts
            return filtered.filter { user in
                // Add your contact filtering logic here
                return true // Placeholder
            }
            
        case .previous:
            // Filter users from previous requests
            return filtered.filter { user in
                let requests = dataController.getAllCoEquipRequests()
                return requests.contains { request in
                    request.selectedUsers.contains(user.userID)
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedFilter = option
                            }) {
                                Text(option.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == option ? Color.green : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedFilter == option ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(UIColor.systemBackground))

                // Main Content
                ZStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        List(filteredUsers, id: \.userID) { farmer in
                            Button(action: {
                                if selectedFarmers.contains(farmer) {
                                    selectedFarmers.remove(farmer)
                                } else {
                                    selectedFarmers.insert(farmer)
                                }
                            }) {
                                FarmerRow(farmer: farmer, isSelected: selectedFarmers.contains(farmer))
                                    .listRowBackground(Color(UIColor.systemBackground))
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search farmers")
            .navigationTitle("Add Farmers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onFarmerSelection(Array(selectedFarmers))
                        dismiss()
                    }
                    .foregroundColor(.green)
                    .opacity(selectedFarmers.isEmpty ? 0.5 : 1.0)
                    .disabled(selectedFarmers.isEmpty)
                }
            }
        }
        .task {
            do {
                // Get current user's location
                if let currentUser = AuthManager.shared.currentUser,
                   let location = currentUser.location {
                    currentUserLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                }
                
                // Get all users
                users = await dataController.getAllUsers()
                isLoading = false
            } catch {
                print("Error loading users: \(error)")
                isLoading = false
            }
        }
    }
}

struct FarmerRow: View {
    let farmer: User
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(farmer.name)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                Text(farmer.phone)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 22))
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
                    .font(.system(size: 22))
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
