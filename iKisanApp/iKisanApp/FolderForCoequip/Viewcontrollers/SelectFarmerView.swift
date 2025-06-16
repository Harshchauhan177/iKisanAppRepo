import SwiftUI
import CoreLocation

struct SelectFarmerView: View {
    let dataController: DataController
    let onFarmerSelection: ([User]) -> Void
    let initialSelectedFarmers: Set<User>
    
    @State private var selectedFarmers: Set<User>
    @State private var searchText = ""
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var selectedFilter = FilterOption.all
    @State private var currentUserLocation: CLLocation?
    @Environment(\.dismiss) private var dismiss
    
    init(dataController: DataController, 
         initialSelectedFarmers: Set<User> = Set(),
         onFarmerSelection: @escaping ([User]) -> Void) {
        self.dataController = dataController
        self.onFarmerSelection = onFarmerSelection
        self.initialSelectedFarmers = initialSelectedFarmers
        _selectedFarmers = State(initialValue: initialSelectedFarmers)
    }

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case oneKm = "1 Km"
        case contact = "Contact"
        //case previous = "Previous"
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
            return filtered.filter { user in
                return true
            }
            
       
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedFilter = option
                            }) {
                                Text(option.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedFilter == option ? .white : .black)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(selectedFilter == option ? Color(hex: "#4c7f58") : Color.white)
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedFilter == option ? Color.clear : Color(.white), lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray6))

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
                    .foregroundColor(Color(hex: "#4c7f58"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onFarmerSelection(Array(selectedFarmers))
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#4c7f58"))
                    .opacity(selectedFarmers.isEmpty ? 0.5 : 1.0)
                    .disabled(selectedFarmers.isEmpty)
                }
            }
        }
        .task {
            if users.isEmpty {
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
            } else {
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
            // Avatar with first letter of name
            ZStack {
                Circle()
                    .fill(Color(hex: "#4c7f58"))
                    .frame(width: 36, height: 36)
                Text(String(farmer.name.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            // Name only (no phone)
            Text(farmer.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
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

// Add this extension at the end of the file for hex color support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
