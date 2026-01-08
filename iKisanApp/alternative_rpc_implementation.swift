// Alternative implementation of loadFarmersWithDistances() using Supabase RPC
// Replace the existing function with this for better performance if you've added the SQL function

/// Fetch real nearby farmers from Supabase using RPC function (optimal performance)
private func loadFarmersWithDistances_RPC() async {
    // Set loading state
    await MainActor.run {
        self.isLoading = true
    }
    
    guard let userLocation = currentUserLocation else {
        print("❌ Cannot load farmers - no user location")
        await MainActor.run {
            self.isLoading = false
            self.errorMessage = "Unable to get your location"
        }
        return
    }
    
    guard let currentUser = AuthManager.shared.currentUser else {
        print("❌ Cannot load farmers - no current user")
        await MainActor.run {
            self.isLoading = false
            self.errorMessage = "Please log in to continue"
        }
        return
    }
    
    print("🔍 Fetching real data for user at: \(userLocation.latitude), \(userLocation.longitude)")
    
    do {
        // Call Supabase RPC function to get nearby farmers (server-side filtering)
        let response = try await SupabaseManager.shared.client
            .rpc("get_nearby_farmers", params: [
                "user_lat": userLocation.latitude,
                "user_lng": userLocation.longitude,
                "radius_km": 50
            ])
            .execute()
        
        // Decode response
        let usersData = response.data
        let fetchedUsers = try JSONDecoder().decode([FarmerDTOWithDistance].self, from: usersData)
        
        print("✅ Fetched \(fetchedUsers.count) farmers from database using RPC")
        
        // Convert to Farmer objects
        var farmers: [Farmer] = []
        
        for userDTO in fetchedUsers {
            // Skip current user if somehow included
            guard userDTO.userID != currentUser.id.uuidString else {
                continue
            }
            
            let farmer = Farmer(
                id: userDTO.userID,
                name: userDTO.name,
                phoneNumber: userDTO.phone,
                location: Location(
                    latitude: userDTO.latitude,
                    longitude: userDTO.longitude,
                    address: userDTO.address
                ),
                distance: userDTO.distance_km // Distance already calculated by server
            )
            
            farmers.append(farmer)
            
            print("📍 Farmer: \(farmer.name), Distance: \(String(format: "%.2f", userDTO.distance_km)) km")
        }
        
        // Already sorted by distance from RPC function
        
        // Update published property
        await MainActor.run {
            self.allFarmers = farmers
            self.isLoading = false
            self.errorMessage = nil
        }
        
        print("✅ Loaded \(farmers.count) farmers within 50km (RPC)")
        
        if farmers.isEmpty {
            await MainActor.run {
                self.errorMessage = "No farmers found within 50km of your location"
            }
        }
        
    } catch {
        print("❌ Error fetching farmers from Supabase RPC: \(error)")
        await MainActor.run {
            self.isLoading = false
            self.errorMessage = "Failed to load nearby farmers: \(error.localizedDescription)"
        }
    }
}

// DTO for RPC response (includes pre-calculated distance)
struct FarmerDTOWithDistance: Codable {
    let userID: String
    let name: String
    let phone: String?
    let latitude: Double
    let longitude: Double
    let address: String?
    let distance_km: Double
    
    enum CodingKeys: String, CodingKey {
        case userID
        case name
        case phone
        case latitude
        case longitude
        case address
        case distance_km
    }
}
