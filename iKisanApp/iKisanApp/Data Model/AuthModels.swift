import Foundation
import Supabase

struct AuthUser: Codable {
    let id: UUID
    let email: String
    let name: String
    let phone: String
    var location: Location?
    var fieldArea: Double?
    var selectedCrops: [UUID]?
    
    enum CodingKeys: String, CodingKey {
        case id = "userID"
        case email
        case name
        case phone
        case location
        case fieldArea
        case selectedCrops
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
    
    func register(name: String, email: String, password: String, phone: String) async throws -> Bool {
        do {
            // Sign up the user
            let authResponse = try await supabase.client.auth.signUp(
                email: email,
                password: password
            )
            
            // Get user ID from response
            let userId = authResponse.user.id
            
            // Add a short delay to allow Supabase's trigger to potentially create the user record
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            
            // Check if the user already exists in the database (created by the trigger)
            let checkResult = try await supabase.client
                .from("users")
                .select()
                .eq("userID", value: userId)
                .execute()
            
            // If user doesn't exist yet, create it manually
            if (try? checkResult.data.isEmpty) != false {
                // Create a proper Encodable object
                let newUser = NewUserRequest(
                    userID: userId.uuidString,  // Convert UUID to string
                    name: name,
                    email: email,
                    phone: phone,
                    latitude: 0.0,
                    longitude: 0.0,
                    fieldArea: 0.0
                )
                
                // Insert user record with Encodable object
                try await supabase.client
                    .from("users")
                    .insert(newUser)
                    .execute()
            }
            
            return true
        } catch let error as AuthError where error.localizedDescription.contains("over_email_send_rate_limit") {
            // Handle rate limit error specifically
            print("Email rate limit exceeded: \(error)")
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
    
    func resetPassword(email: String) async throws {
        do {
            try await supabase.client.auth.resetPasswordForEmail(email)
        } catch {
            print("Reset password error: \(error)")
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
                    location: user.location,
                    fieldArea: user.fieldArea,
                    selectedCrops: user.selectedCrops
                )
            } else if let phone = phone {
                user = AuthUser(
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    phone: phone,
                    location: user.location,
                    fieldArea: user.fieldArea,
                    selectedCrops: user.selectedCrops
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
}

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
