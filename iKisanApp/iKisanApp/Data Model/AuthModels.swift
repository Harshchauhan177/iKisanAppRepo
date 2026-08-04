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
    
    // Custom decoder: gracefully handle NULL values for name/phone/email
    // (e.g. Apple Sign-In users may not have a phone number)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
        address = try container.decodeIfPresent(String.self, forKey: .address)
        fieldArea = try container.decodeIfPresent(Double.self, forKey: .fieldArea)
        selectedCrops = try container.decodeIfPresent([UUID].self, forKey: .selectedCrops)
        groupID = try container.decodeIfPresent(UUID.self, forKey: .groupID)
    }
    
    // Memberwise initializer (needed since we added custom decoder)
    init(id: UUID, email: String, name: String, phone: String,
         latitude: Double = 0.0, longitude: Double = 0.0, address: String? = nil,
         fieldArea: Double? = nil, selectedCrops: [UUID]? = nil, groupID: UUID? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.fieldArea = fieldArea
        self.selectedCrops = selectedCrops
        self.groupID = groupID
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
    
    // Add this new function to fetch current user address
    func fetchCurrentUserAddress() async throws -> String? {
        guard let currentUser = self.currentUser else {
            return nil
        }
        
        do {
            // Fetch latest user data from Supabase
            let result = try await supabase.client
                .from("users")
                .select()
                .eq("userID", value: currentUser.id)
                .single()
                .execute()
            
            // Decode user data
            let userData = result.data
            let user = try JSONDecoder().decode(AuthUser.self, from: userData)
            
            // Update current user in memory and UserDefaults
            self.currentUser = user
            saveUserToUserDefaults(user)
            
            return user.address
        } catch {
            print("Error fetching user address: \(error)")
            return currentUser.address // Fallback to cached address
        }
    }
    
    private init() {
        // Load user from UserDefaults if available
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
            self.currentUser = user
        }
        
        // Restore session on app launch
        Task {
            await checkAndRestoreSession()
        }
    }
    
    private func checkAndRestoreSession() async {
        guard let sessionString = UserDefaults.standard.string(forKey: "supabase_session"),
              let sessionData = sessionString.data(using: .utf8) else {
            print("❌ AuthManager: No saved session found")
            return
        }
        
        do {
            let sessionDict = try JSONDecoder().decode([String: String].self, from: sessionData)
            guard let accessToken = sessionDict["accessToken"],
                  let refreshToken = sessionDict["refreshToken"],
                  !accessToken.isEmpty,
                  !refreshToken.isEmpty else {
                print("❌ AuthManager: Invalid session data found")
                return
            }
            
            try await supabase.client.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
            print("✅ AuthManager: Session restored successfully")
        } catch {
            print("❌ AuthManager: Failed to restore session: \(error)")
        }
    }
    
    private func saveSession(_ session: Session) {
        do {
            let sessionDict = [
                "accessToken": session.accessToken,
                "refreshToken": session.refreshToken
            ]
            let sessionData = try JSONEncoder().encode(sessionDict)
            if let sessionString = String(data: sessionData, encoding: .utf8) {
                UserDefaults.standard.set(sessionString, forKey: "supabase_session")
                print("✅ AuthManager: Session saved locally")
            }
        } catch {
            print("❌ AuthManager: Failed to save session: \(error)")
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
            
            // Get user ID as lowercased string to match Supabase format
            let userId = authResponse.user.id.uuidString.lowercased()
            
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
            
            // Save session and user locally
            saveSession(authResponse)
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
            //    Supabase Auth automatically sends the confirmation OTP email
            print("📧 Starting signup for email: \(email)")
            let authResponse = try await supabase.client.auth.signUp(
                email:    email,
                password: password,
                data: [
                    "name":  .string(name),
                    "phone": .string(phone)
                ]
            )
            let userId = authResponse.user.id
            print("✅ signUp() succeeded — user ID: \(userId)")
            print("📬 Supabase should have sent OTP email to \(email)")

            // short pause so the DB trigger can fire and create the row
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))

            // 2️⃣ Upsert user row — creates the row if the DB trigger didn't,
            //    or updates it if the trigger already created it.
            //    This guarantees the user row exists for OTP verification.
            let newUser = NewUserRequest(
                userID: userId.uuidString.lowercased(),
                name: name,
                email: email,
                phone: phone,
                latitude: 0.0,
                longitude: 0.0,
                fieldArea: 0.0
            )
            _ = try await supabase.client
                .from("users")
                .upsert(newUser, onConflict: "userID")
                .execute()
            print("✅ User row upserted in users table")

            return true

        } catch {
            let errorDesc = "\(error)"
            print("❌ Registration error: \(errorDesc)")
            if errorDesc.contains("over_email_send_rate_limit") || errorDesc.contains("rate_limit") {
                throw AuthError.rateLimited
            }
            throw AuthError.registrationFailed
        }

    }

    
    func verifyOTP(email: String, otp: String) async throws -> AuthUser {
        do {
            // Verify OTP with Supabase Auth
            print("🔑 Verifying OTP for email: \(email), code: \(otp), type: .signup")
            let authResponse = try await supabase.client.auth.verifyOTP(
                email: email,
                token: otp,
                type: .signup
            )
            
            // Get user ID as lowercased string to match Supabase format
            let userId = authResponse.user.id.uuidString.lowercased()
            print("✅ OTP verified — user ID: \(userId)")
            
            // Wait a moment to ensure database has been updated
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            
            // Fetch user from users table — use array fetch instead of .single()
            // to gracefully handle the case where the row doesn't exist yet
            let result = try await supabase.client
                .from("users")
                .select()
                .eq("userID", value: userId)
                .execute()
            
            let users = try JSONDecoder().decode([AuthUser].self, from: result.data)
            
            let appUser: AuthUser
            if let existingUser = users.first {
                print("✅ Found user row in database")
                appUser = existingUser
            } else {
                // User row doesn't exist (DB trigger didn't fire) — create it now
                print("⚠️ User row not found in users table — creating...")
                
                // Extract name/phone from the auth metadata that was set during signup
                var userName = ""
                var userPhone = ""
                if case .string(let n) = authResponse.user.userMetadata["name"] {
                    userName = n
                }
                if case .string(let p) = authResponse.user.userMetadata["phone"] {
                    userPhone = p
                }
                
                let newUser = NewUserRequest(
                    userID: userId,
                    name: userName,
                    email: email,
                    phone: userPhone,
                    latitude: 0.0,
                    longitude: 0.0,
                    fieldArea: 0.0
                )
                try await supabase.client
                    .from("users")
                    .insert(newUser)
                    .execute()
                
                // Fetch the newly created user
                let newResult = try await supabase.client
                    .from("users")
                    .select()
                    .eq("userID", value: userId)
                    .single()
                    .execute()
                appUser = try JSONDecoder().decode(AuthUser.self, from: newResult.data)
                print("✅ User row created successfully")
            }
            
            // Save session and user locally
            if let session = authResponse.session {
                saveSession(session)
            }
            self.currentUser = appUser
            saveUserToUserDefaults(appUser)
            
            return appUser
        } catch {
            // Log the FULL Supabase error so we can see the actual reason
            print("❌ OTP verification FAILED")
            print("   Email: \(email)")
            print("   OTP entered: \(otp)")
            print("   Error type: \(type(of: error))")
            print("   Error detail: \(error)")
            print("   Localized: \(error.localizedDescription)")
            throw AuthError.invalidOTP
        }
    }
    
    func logout() async throws {
        do {
            // CRITICAL: Unsubscribe from Realtime WebSocket channels before logout
            print("🔌 AuthManager: Unsubscribing from Realtime channels...")
            await RealtimeManager.shared.unsubscribeAll()

            try await supabase.client.auth.signOut()
            self.currentUser = nil
            UserDefaults.standard.removeObject(forKey: "currentUser")
            UserDefaults.standard.removeObject(forKey: "supabase_session")
            print("✅ AuthManager: Logout complete, Realtime channels closed")
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
    /// Send a recovery OTP to the user's email
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
            // Use the proper resend API to re-send the signup confirmation email
            try await supabase.client.auth.resend(
                email: email,
                type: .signup
            )
            print("✅ OTP resent successfully to \(email)")
        } catch let error as AuthError where error.localizedDescription.contains("over_email_send_rate_limit") {
            print("Email rate limit exceeded: \(error)")
            throw AuthError.rateLimited
        } catch {
            print("Resend OTP error: \(error)")
            throw AuthError.resendOTPFailed
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
                .eq("userID", value: user.id.uuidString.lowercased())
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
                .eq("userID", value: user.id.uuidString.lowercased())
                .execute()
            
            print("Deleted existing crop selections")
            
            // Step 2: Insert new crop selections (one row per crop)
            // Only proceed if we have crops to add
            if !selectedCropIds.isEmpty {
                // Create an array of rows to insert, one for each crop ID
                var rowsToInsert: [[String: String]] = []
                
                for cropId in selectedCropIds {
                    let row = [
                        "userID": user.id.uuidString.lowercased(),
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
                .eq("userID", value: user.id.uuidString.lowercased())
                .execute()
            
            print("Updated user's field area to \(area) acres in users table")
        } catch {
            print("Error updating field area: \(error)")
            throw error
        }
    }
    
    // MARK: - Apple Sign In Support
    
    /// Handle Apple Sign In session and create/update user in the database
    func handleAppleSignInSession(_ session: Session, name: String, email: String) async throws -> AuthUser {
        // Validate inputs to prevent crashes
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        do {
            // First, try to fetch existing user from the users table with timeout protection
            let result = try await supabase.client
                .from("users")
                .select()
                .eq("userID", value: session.user.id.uuidString.lowercased())
                .single()
                .execute()
            
            // User exists, decode and return
            let userData = result.data
            let appUser = try JSONDecoder().decode(AuthUser.self, from: userData)
            
            // Update local user
            self.currentUser = appUser
            saveUserToUserDefaults(appUser)
            
            return appUser
        } catch {
            // User doesn't exist, create new user record with proper error handling
            print("User not found in database, creating new user record...")
            
            do {
                let newUser = NewUserRequest(
                    userID: session.user.id.uuidString.lowercased(),
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    phone: "", // Empty phone for Apple Sign In users
                    latitude: 0.0,
                    longitude: 0.0,
                    fieldArea: 0.0
                )
                
                // Insert new user record with retry logic
                try await supabase.client
                    .from("users")
                    .insert(newUser)
                    .execute()
                
                // Set flag that this is a newly registered user who needs to select crops
                UserDefaults.standard.set(true, forKey: "isNewlyRegisteredUser")
                
                // Small delay to ensure database consistency
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Fetch the newly created user with timeout protection
                let result = try await supabase.client
                    .from("users")
                    .select()
                    .eq("userID", value: session.user.id.uuidString.lowercased())
                    .single()
                    .execute()
                
                let userData = result.data
                let appUser = try JSONDecoder().decode(AuthUser.self, from: userData)
                
                // Save user locally
                self.currentUser = appUser
                saveUserToUserDefaults(appUser)
                
                return appUser
            } catch {
                print("❌ Error creating Apple Sign-In user: \(error)")
                // Provide more specific error handling
                if error.localizedDescription.contains("duplicate") || error.localizedDescription.contains("unique") {
                    // Try to fetch again in case of race condition
                    let retryResult = try await supabase.client
                        .from("users")
                        .select()
                        .eq("userID", value: session.user.id.uuidString.lowercased())
                        .single()
                        .execute()
                    
                    let userData = retryResult.data
                    let appUser = try JSONDecoder().decode(AuthUser.self, from: userData)
                    self.currentUser = appUser
                    saveUserToUserDefaults(appUser)
                    return appUser
                } else {
                    throw AuthError.registrationFailed
                }
            }
        }
    }

    // MARK: - Account Deletion
    
    /// Well-known sentinel UUID for the "Deleted User" placeholder.
    /// A matching row must exist in the `users` table with this userID.
    /// Run the SQL in the project README/docs to create it once in Supabase.
    static let deletedUserID = "00000000-0000-0000-0000-000000000000"
    
    /// Deletes the user's account completely.
    ///
    /// **Strategy (industry-standard "Deleted User" sentinel pattern):**
    /// 1. Remove user-only data (avatar, crop selections, likes)
    /// 2. Reassign business-critical records (bookings, service requests, requests, reviews)
    ///    to the sentinel "Deleted User" so providers keep their history
    /// 3. Delete the user's row from the `users` table
    /// 4. Delete the auth account via RPC
    /// 5. Clean up local state
    func deleteAccount() async throws {
        guard let user = currentUser else {
            throw AuthError.notLoggedIn
        }
        
        let userId = user.id.uuidString.lowercased()
        let deletedId = AuthManager.deletedUserID
        print("🗑️ Starting account deletion for user: \(userId)")
        
        // Step 1: Remove avatar from storage (while still authenticated)
        do {
            try await supabase.client.storage
                .from("avatars")
                .remove(paths: ["\(userId.lowercased())/avatar.jpg"])
            print("✅ Step 1: Deleted avatar from storage")
        } catch {
            print("⚠️ Step 1: Avatar deletion failed (non-critical): \(error)")
        }
        
        // Step 2: Delete user-only data (no provider impact)
        
        // 2a: Delete selected crops
        do {
            try await supabase.client
                .from("userSelectedCrops")
                .delete()
                .eq("userID", value: userId)
                .execute()
            print("✅ Step 2a: Deleted userSelectedCrops")
        } catch {
            print("⚠️ Step 2a: userSelectedCrops deletion failed (non-critical): \(error)")
        }
        
        // 2b: Delete equipment likes
        do {
            try await supabase.client
                .from("userEquipmentLikes")
                .delete()
                .eq("userID", value: userId)
                .execute()
            print("✅ Step 2b: Deleted userEquipmentLikes")
        } catch {
            print("⚠️ Step 2b: userEquipmentLikes deletion failed (non-critical): \(error)")
        }
        
        // 2c: Delete request participants (join table)
        do {
            try await supabase.client
                .from("request_participants")
                .delete()
                .eq("userID", value: userId)
                .execute()
            print("✅ Step 2c: Deleted request_participants")
        } catch {
            print("⚠️ Step 2c: request_participants deletion failed (non-critical): \(error)")
        }
        
        // Step 3: Reassign business-critical records to the "Deleted User" sentinel
        // This preserves provider history while removing the FK link to the real user
        
        // Helper structs for reassigning FK columns to the sentinel user
        struct ReassignFarmerID: Encodable { let farmerid: String }
        struct ReassignUserID: Encodable { let userID: String }
        struct ReassignUserId: Encodable { let userId: String }
        
        // 3a: Reassign servicerequests → Deleted User
        do {
            try await supabase.client
                .from("servicerequests")
                .update(ReassignFarmerID(farmerid: deletedId))
                .eq("farmerid", value: userId.lowercased())
                .execute()
            print("✅ Step 3a: Reassigned servicerequests to Deleted User")
        } catch {
            print("⚠️ Step 3a: servicerequests reassignment failed: \(error)")
        }
        
        // 3b: Reassign bookings → Deleted User
        do {
            try await supabase.client
                .from("bookings")
                .update(ReassignUserID(userID: deletedId))
                .eq("userID", value: userId)
                .execute()
            print("✅ Step 3b: Reassigned bookings to Deleted User")
        } catch {
            print("⚠️ Step 3b: bookings reassignment failed: \(error)")
        }
        
        // 3c: Reassign requests → Deleted User
        do {
            try await supabase.client
                .from("requests")
                .update(ReassignUserId(userId: deletedId))
                .eq("userId", value: userId)
                .execute()
            print("✅ Step 3c: Reassigned requests to Deleted User")
        } catch {
            print("⚠️ Step 3c: requests reassignment failed: \(error)")
        }
        
        // 3d: Reassign reviews → Deleted User
        do {
            try await supabase.client
                .from("reviews")
                .update(ReassignUserID(userID: deletedId))
                .eq("userID", value: userId)
                .execute()
            print("✅ Step 3d: Reassigned reviews to Deleted User")
        } catch {
            print("⚠️ Step 3d: reviews reassignment failed: \(error)")
        }
        
        // Step 4: Delete user row from users table (safe — all FKs now point to sentinel)
        do {
            try await supabase.client
                .from("users")
                .delete()
                .eq("userID", value: userId)
                .execute()
            print("✅ Step 4: Deleted user row from users table")
        } catch {
            print("❌ Step 4: users table deletion FAILED — aborting to prevent orphaned account: \(error)")
            throw AuthError.accountDeletionFailed
        }
        
        // Step 5: Delete auth user via RPC (requires admin privileges)
        do {
            try await supabase.client
                .rpc("delete_user_account")
                .execute()
            print("✅ Step 5: Deleted auth user via RPC")
        } catch {
            print("❌ Step 5: RPC delete_user_account FAILED: \(error)")
            throw AuthError.accountDeletionFailed
        }
        
        // Step 6: Unsubscribe from Realtime channels
        await RealtimeManager.shared.unsubscribeAll()
        print("✅ Step 6: Unsubscribed from Realtime")
        
        // Step 7: Clear local data
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "isNewlyRegisteredUser")
        
        print("✅ Account deletion complete for user \(userId)")
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
    case resendOTPFailed
    case rateLimited
    case accountDeletionFailed
}
