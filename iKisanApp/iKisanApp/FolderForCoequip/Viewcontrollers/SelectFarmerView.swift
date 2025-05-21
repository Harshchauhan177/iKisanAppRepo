import SwiftUI

struct SelectFarmerView: View {
    let dataController: DataController
    let onFarmerSelection: ([User]) -> Void
    @State private var selectedFarmers: Set<User> = []
    @State private var searchText = ""
    @State private var users: [User] = []
    @Environment(\.dismiss) private var dismiss

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            List(filteredUsers, id: \.userID) { farmer in
                Button(action: {
                    if selectedFarmers.contains(farmer) {
                        selectedFarmers.remove(farmer)
                    } else {
                        selectedFarmers.insert(farmer)
                    }
                }) {
                    FarmerRow(farmer: farmer, isSelected: selectedFarmers.contains(farmer))
                }
            }
            .searchable(text: $searchText, prompt: "Search farmers")
            .navigationTitle("Select Farmers (\(selectedFarmers.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onFarmerSelection(Array(selectedFarmers))
                        dismiss()
                    }
                }
            }
        }
        .task {
            users = await dataController.getAllUsers()
        }
    }
}

struct FarmerRow: View {
    let farmer: User
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(farmer.name)
                    .font(.headline)
                Text(farmer.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle()) // This ensures the entire row is tappable
    }
}
