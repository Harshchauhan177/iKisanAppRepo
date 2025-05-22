import Foundation
import Supabase

struct AuthUser: Codable {
    // Basic user info
    let id: UUID
    let email: String
    let name: String
    let phone: String
    
    // Location properties stored directly at root level
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var address: String?
    
    // Other user data
    var fieldArea: Double?
    var selectedCrops: [UUID]?
    var groupID: UUID?
    
    // Computed property to get location as an object
    var location: Location? {
        if latitude != 0.0 || longitude != 0.0 {
            return Location(latitude: latitude, longitude: longitude, address: address)
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "userID"
        case email
        case name
        case phone
        case latitude
        case longitude
        case address
        case fieldArea
        case selectedCrops
        case groupID
    }
}

// Struct for creating a new user
struct NewUserRequest: Encodable {
    let userID: String
    let name: String
    let email: String
    let phone: String
    let latitude: Double
    let longitude: Double
    let fieldArea: Double
}

// Struct for updating user profile
struct UpdateUserRequest: Encodable {
    let name: String?
    let phone: String?
    
    init(name: String? = nil, phone: String? = nil) {
        self.name = name
        self.phone = phone
    }
}

class AuthManager {
    static let shared = AuthManager()
    
    private init() {
        // Load user from UserDefaults if available
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
            self.currentUser = user
        }
    }
    
    private(set) var currentUser: AuthUser?
    private let supabase = SupabaseManager.shared
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    func login(email: String, password: String) async throws -> AuthUser {
        do {
            // Authenticate using Supabase Auth
            let authResponse = try await supabase.client.auth.signIn(
                email: email,
                password: password
            )
            
            // Get user ID as string (direct access since it's non-optional)
            let userId = authResponse.user.id
            
            // Fetch user details from users table
            let result = try await supabase.client
                .from("users")
                .select()
                .eq("userID", value: userId)
                .single()
                .execute()
            
            // Decode user from response - data is non-optional
            let userData = result.data
            let appUser = try JSONDecoder().decode(AuthUser.self, from: userData)
            
            // Save user locally
            self.currentUser = appUser
            saveUserToUserDefaults(appUser)
            
            return appUser
        } catch {
            print("Login error: \(error)")
            throw AuthError.invalidCredentials
        }
    }
    
//    func register(name: String, email: String, password: String, phone: String) async throws -> Bool {
//        do {
//            // Sign up the user
//            let authResponse = try await supabase.client.auth.signUp(
//                email: email,
//                password: password
//            )
//            
//            // Get user ID from response
//            let userId = authResponse.user.id
//            
//            // Add a short delay to allow Supabase's trigger to potentially create the user record
//            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
//            
//            // Check if the user already exists in the database (created by the trigger)
//            let checkResult = try await supabase.client
//                .from("users")
//                .select()
//                .eq("userID", value: userId)
//                .execute()
//            
//            // If user doesn't exist yet, create it manually
//            if (try? checkResult.data.isEmpty) != false {
//                // Create a proper Encodable object
//                let newUser = NewUserRequest(
//                    userID: userId.uuidString,  // Convert UUID to string
//                    name: name,
//                    email: email,
//                    phone: phone,
//                    latitude: 0.0,
//                    longitude: 0.0,
//                    fieldArea: 0.0
//                )
//                
//                // Insert user record with Encodable object
//                try await supabase.client
//                    .from("users")
//                    .insert(newUser)
//                    .execute()
//            }
//            
//            return true
//        } catch let error as AuthError where error.localizedDescription.contains("over_email_send_rate_limit") {
//            // Handle rate limit error specifically
//            print("Email rate limit exceeded: \(error)")
//            throw AuthError.rateLimited
//        } catch {
//            print("Registration error: \(error)")
//            throw AuthError.registrationFailed
//        }
//    }
    func register(name: String, email: String, password: String, phone: String) async throws -> Bool {
        do {
            // 1️⃣ Sign up the user, sending name & phone as auth metadata
            let authResponse = try await supabase.client.auth.signUp(
                email:    email,
                password: password,
                data: [
                    "name":  .string(name),
                    "phone": .string(phone)
                ]
            )
            let userId = authResponse.user.id

            // short pause so the DB trigger can fire and create the row
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))

            // 2️⃣ Update that users row with the proper name & phone
            let updateReq = UpdateUserRequest(name: name, phone: phone)
            _ = try await supabase.client
                .from("users")
                .update(updateReq)
                .eq("userID", value: userId.uuidString)
                .execute()

            return true

        } catch let error as AuthError where error.localizedDescription.contains("over_email_send_rate_limit") {
            // Email rate‑limit hit
            throw AuthError.rateLimited

        } catch {
            print("Registration error: \(error)")
            throw AuthError.registrationFailed
        }
    }

    
    func verifyOTP(email: String, otp: String) async throws -> AuthUser {
        do {
            // Verify OTP with Supabase Auth
            let authResponse = try await supabase.client.auth.verifyOTP(
                email: email,
                token: otp,
                type: .signup
            )
            
            // Get user ID (direct access since it's non-optional)
            let userId = authResponse.user.id
            
            // Wait a moment to ensure database has been updated
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            
            // Fetch user details from users table
            let result = try await supabase.client
                .from("users")
                .select()
                .eq("userID", value: userId)
                .single()
                .execute()
            
            // Decode user from response
            let userData = result.data
            let appUser = try JSONDecoder().decode(AuthUser.self, from: userData)
            
            // Save user locally
            self.currentUser = appUser
            saveUserToUserDefaults(appUser)
            
            return appUser
        } catch {
            print("OTP verification error: \(error)")
            throw AuthError.invalidOTP
        }
    }
    
    func logout() async throws {
        do {
            try await supabase.client.auth.signOut()
            self.currentUser = nil
            UserDefaults.standard.removeObject(forKey: "currentUser")
        } catch {
            print("Logout error: \(error)")
            throw AuthError.logoutFailed
        }
    }
    
//    func resetPassword(email: String) async throws {
//        do {
//            try await supabase.client.auth.resetPasswordForEmail(email)
//        } catch {
//            print("Reset password error: \(error)")
//            throw AuthError.resetPasswordFailed
//        }
//    }
    /// Send a recovery OTP to the user’s email
    func resetPassword(email: String) async throws {
        do {
            // call without the `email:` label
            try await supabase.client.auth.resetPasswordForEmail(email)
        } catch {
            print("Reset password error: \(error)")
            throw AuthError.resetPasswordFailed
        }
    }

    /// Confirm the recovery OTP and set the new password
//    func confirmPasswordReset(otp: String, newPassword: String) async throws {
//        do {
//            _ = try await supabase.client.auth.update(
//                user: UserAttributes(
//                    password: newPassword,
//                    nonce:    otp
//                )
//            )
//        } catch {
//            print("Confirm reset error: \(error)")
//            throw AuthError.resetPasswordFailed
//        }
//    }
    /// Confirm recovery OTP & set new password
    func confirmPasswordReset(email: String, otp: String, newPassword: String) async throws {
        do {
            // 1️⃣ Verify the recovery OTP (type: .recovery) — this creates a session
            _ = try await supabase.client.auth.verifyOTP(
                email: email,
                token: otp,
                type: .recovery
            )

            // 2️⃣ Now that we have a session, update the password
            _ = try await supabase.client.auth.update(
                user: UserAttributes(password: newPassword)
            )
        } catch {
            print("Confirm reset error: \(error)")
            throw AuthError.resetPasswordFailed
        }
    }


    
    func resendOTP(email: String) async throws {
        do {
            // Use the signup method with the same email to trigger a new OTP
            let authResponse = try await supabase.client.auth.signUp(
                email: email,
                password: "temporary-placeholder-password" // This won't be used as the account already exists
            )
            
            // Simply check if we got a valid response
            // The signup will throw an error if it fails, so if we got here, it's likely successful
            return
        } catch let error as AuthError where error.localizedDescription.contains("over_email_send_rate_limit") {
            print("Email rate limit exceeded: \(error)")
            throw AuthError.rateLimited
        } catch {
            print("Resend OTP error: \(error)")
            throw AuthError.resetPasswordFailed
        }
    }
    
    // Structure for location update request - directly mapping to database columns
    struct LocationUpdateRequest: Encodable {
        let latitude: Double
        let longitude: Double
        let address: String?
    }
    
    // Update user location
    func updateUserLocation(address: String?, latitude: Double, longitude: Double) async throws {
        guard var user = currentUser else {
            throw AuthError.notLoggedIn
        }
        
        do {
            // Create a direct update object that matches the database schema
            let updateRequest = LocationUpdateRequest(
                latitude: latitude,
                longitude: longitude,
                address: address
            )
            
            // Update user location in the database with direct properties
            try await supabase.client
                .from("users")
                .update(updateRequest)
                .eq("userID", value: user.id.uuidString.lowercased()) // Use lowercase for consistency
                .execute()
            
            print("Location update request sent to database")
            
            // Update local user object directly with location properties
            var updatedUser = user
            updatedUser.latitude = latitude
            updatedUser.longitude = longitude
            updatedUser.address = address
            
            self.currentUser = updatedUser
            saveUserToUserDefaults(updatedUser)
            
            print("Updated user location successfully: \(address ?? "No address"), \(latitude), \(longitude)")
        } catch {
            print("Failed to update user location: \(error)")
            throw error
        }
    }
    
    func updateUserProfile(name: String? = nil, phone: String? = nil) async throws {
        guard var user = currentUser else {
            throw AuthError.notLoggedIn
        }
        
        // Create an encodable update request
        let updateRequest = UpdateUserRequest(name: name, phone: phone)
        
        // Only proceed if we have something to update
        if name != nil || phone != nil {
            // Update user profile using Encodable object
            try await supabase.client
                .from("users")
                .update(updateRequest)
                .eq("userID", value: user.id.uuidString)
                .execute()
            
            // Update local user
            if let name = name {
                user = AuthUser(
                    id: user.id,
                    email: user.email,
                    name: name,
                    phone: phone ?? user.phone,
                    latitude: user.latitude,
                    longitude: user.longitude,
                    address: user.address,
                    fieldArea: user.fieldArea,
                    selectedCrops: user.selectedCrops,
                    groupID: user.groupID
                )
            } else if let phone = phone {
                user = AuthUser(
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    phone: phone,
                    latitude: user.latitude,
                    longitude: user.longitude,
                    address: user.address,
                    fieldArea: user.fieldArea,
                    selectedCrops: user.selectedCrops,
                    groupID: user.groupID
                )
            }
            
            self.currentUser = user
            saveUserToUserDefaults(user)
        }
    }
    
    private func saveUserToUserDefaults(_ user: AuthUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    // Method to refresh the current user with updated data from database
    func refreshCurrentUser(with updatedUser: AuthUser) {
        self.currentUser = updatedUser
        saveUserToUserDefaults(updatedUser)
        print("Current user refreshed and saved to UserDefaults")
    }
    
    // Method to update user's selected crops in Supabase
    func updateUserSelectedCrops(selectedCropIds: [UUID], totalFieldArea: Double? = nil) async throws {
        guard var user = currentUser else {
            throw AuthError.notLoggedIn
        }
        
        print("Updating crops for user: \(user.id.uuidString) with \(selectedCropIds.count) crops")
        if let area = totalFieldArea {
            print("Total field area: \(area) acres")
        }
        
        do {
            // Step 1: Delete all existing crops for this user
            // This ensures we don't have any old selections lingering
            let deleteResult = try await supabase.client
                .from("userSelectedCrops")
                .delete()
                .eq("userID", value: user.id.uuidString)
                .execute()
            
            print("Deleted existing crop selections")
            
            // Step 2: Insert new crop selections (one row per crop)
            // Only proceed if we have crops to add
            if !selectedCropIds.isEmpty {
                // Create an array of rows to insert, one for each crop ID
                var rowsToInsert: [[String: String]] = []
                
                for cropId in selectedCropIds {
                    let row = [
                        "userID": user.id.uuidString,
                        "cropID": cropId.uuidString
                    ]
                    rowsToInsert.append(row)
                }
                
                // Insert all rows in a single operation
                let insertResult = try await supabase.client
                    .from("userSelectedCrops")
                    .insert(rowsToInsert)
                    .execute()
                
                print("Inserted \(rowsToInsert.count) new crop selections")
            }
            
            // Step 3: Update the field area in the users table if provided
            if let fieldArea = totalFieldArea {
                try await updateFieldArea(fieldArea)
            }
            
            print("Successfully updated crop selections in userSelectedCrops table")
            
            // Update local user
            user.selectedCrops = selectedCropIds
            self.currentUser = user
            saveUserToUserDefaults(user)
            
            print("Updated user's selected crops locally")
            return
        } catch {
            print("Error updating user crops in Supabase: \(error)")
            throw error
        }
    }
    
    // Method to update the field area in the users table
    func updateFieldArea(_ area: Double) async throws {
        guard let user = currentUser else {
            throw AuthError.notLoggedIn
        }
        
        do {
            // Update field area in the users table
            try await supabase.client
                .from("users")
                .update(["fieldArea": area])
                .eq("userID", value: user.id.uuidString)
                .execute()
            
            print("Updated user's field area to \(area) acres in users table")
        } catch {
            print("Error updating field area: \(error)")
            throw error
        }
    }

} // End of AuthManager class

enum AuthError: Error {
    case invalidCredentials
    case registrationFailed
    case invalidOTP
    case invalidUserId
    case notLoggedIn
    case logoutFailed
    case resetPasswordFailed
    case rateLimited
}
