//import SwiftUI
//
//struct SelectFarmerView: View {
//    let dataController: DataController
//    let onFarmerSelection: ([User]) -> Void
//    @State private var selectedFarmers: Set<User> = []
//    @State private var searchText = ""
//    @State private var users: [User] = []
//    @Environment(\.dismiss) private var dismiss
//    
//    var filteredUsers: [User] {
//        if searchText.isEmpty {
//            return users
//        } else {
//            return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            List(selection: $selectedFarmers) {
//                ForEach(filteredUsers, id: \.userID) { farmer in
//                    FarmerRow(farmer: farmer)
//                        .tag(farmer)
//                }
//            }
//            .searchable(text: $searchText, prompt: "Search farmers")
//            .navigationTitle("Select Farmers (\(selectedFarmers.count))")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        onFarmerSelection(Array(selectedFarmers))
//                        dismiss()
//                    }
//                }
//            }
//        }
//        .task {
//            // Load all users when view appears
//            users = dataController.getCoEquipUsers()
//        }
//    }
//}
//
//struct FarmerRow: View {
//    let farmer: User
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(farmer.name)
//                    .font(.headline)
//                Text(farmer.phone)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            Spacer()
//        }
//    }
//}
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
            List(filteredUsers, id: \.userID, selection: $selectedFarmers) { farmer in
                FarmerRow(farmer: farmer)
                    .tag(farmer)
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
        }
    }
}
