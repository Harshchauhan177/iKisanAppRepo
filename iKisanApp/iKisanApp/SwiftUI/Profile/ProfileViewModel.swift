import SwiftUI
import Supabase

class ProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var email: String
    @Published var phone: String
    @Published var address: String = ""
    @Published var avatar: UIImage?
    
    @Published var isEditMode = false
    @Published var showSignOutConfirmation = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    
    @Published var editName: String = ""
    @Published var editPhone: String = ""
    @Published var editAddress: String = ""
    
    let ikisanGreen = Color(red: 76/255, green: 175/255, blue: 80/255)
    private let supabase = SupabaseManager.shared
    
    init() {
        // Initialize with empty values, will be populated on fetchProfile
        self.name = ""
        self.email = ""
        self.phone = ""
        
        // Fetch user data from Supabase
        Task {
            await fetchProfile()
        }
    }
    
    init(user: AuthUser) {
        self.name = user.name
        self.email = user.email
        self.phone = user.phone
        // Check if location contains an address
        if let location = user.location {
            self.address = location.address ?? ""
        }
    }
    
    @MainActor
    func fetchProfile() async {
        guard let currentUser = AuthManager.shared.currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        do {
            // Fetch latest user data from Supabase
            let response = try await supabase.client
                .from("users")
                .select()
                .eq("userID", value: currentUser.id.uuidString)
                .single()
                .execute()
            
            // Decode user data
            let userData = response.data
            let user = try JSONDecoder().decode(AuthUser.self, from: userData)
            
            // Update published properties
            self.name = user.name
            self.email = user.email
            self.phone = user.phone
            
            // Set address if available
            if let location = user.location {
                self.address = location.address ?? ""
            }
            
            // Try to fetch avatar if we have storage access
            await fetchAvatar(userId: user.id.uuidString)
            
        } catch {
            print("Error fetching profile: \(error)")
            errorMessage = "Failed to load profile data"
        }
    }
    
    private func fetchAvatar(userId: String) async {
        do {
            // Attempt to download avatar from storage
            let data = try await supabase.client.storage
                .from("avatars")
                .download(path: "\(userId)/avatar.png")
            
            // Convert data to UIImage
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.avatar = image
                }
            }
        } catch {
            print("No avatar found or error: \(error)")
            // Not setting error message as avatar is optional
        }
    }
    
    func enterEditMode() {
        editName = name
        editPhone = phone
        editAddress = address
        isEditMode = true
    }
    
    func cancelEdit() {
        isEditMode = false
    }
    
    @MainActor
    func saveChanges() async {
        guard let userId = AuthManager.shared.currentUser?.id.uuidString else {
            errorMessage = "User not logged in"
            return
        }
        
        isSaving = true
        
        do {
            // Create update request
            let updateData: [String: String] = [
                "name": editName,
                "phone": editPhone,
                "address": editAddress
            ]
            
            // Update user in Supabase
            _ = try await supabase.client
                .from("users")
                .update(updateData)
                .eq("userID", value: userId)
                .execute()
            
            // Update local user data
            name = editName
            phone = editPhone
            address = editAddress
            
            // Update current user in AuthManager if needed
            if let currentUser = AuthManager.shared.currentUser {
                let updatedUser = AuthUser(
                    id: currentUser.id,
                    email: currentUser.email,
                    name: editName,
                    phone: editPhone,
                    latitude: currentUser.latitude,
                    longitude: currentUser.longitude,
                    address: editAddress,
                    fieldArea: currentUser.fieldArea,
                    selectedCrops: currentUser.selectedCrops,
                    groupID: currentUser.groupID
                )
                
                try await AuthManager.shared.updateUserProfile(name: editName, phone: editPhone)
            }
            
            isEditMode = false
        } catch {
            print("Error saving profile changes: \(error)")
            errorMessage = "Failed to save profile changes"
        }
        
        isSaving = false
    }
    
    func uploadAvatar(image: UIImage) async {
        guard let userId = AuthManager.shared.currentUser?.id.uuidString else {
            errorMessage = "User not logged in"
            return
        }
        
        guard let imageData = image.pngData() else {
            errorMessage = "Failed to process image"
            return
        }
        
        do {
            // Upload avatar to Supabase Storage
            _ = try await supabase.client.storage
                .from("avatars")
                .upload(
                    path: "\(userId)/avatar.png",
                    file: imageData,
                    options: FileOptions(contentType: "image/png")
                )
            
            // Update local avatar
            await MainActor.run {
                self.avatar = image
            }
        } catch {
            print("Error uploading avatar: \(error)")
            errorMessage = "Failed to upload avatar"
        }
    }
    
    func updateAvatar(with image: UIImage) {
        avatar = image
        
        // Upload avatar to Supabase
        Task {
            await uploadAvatar(image: image)
        }
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await AuthManager.shared.logout()
                
                await MainActor.run {
                    // Call completion handler with success
                    completion(true)
                    print("User signed out successfully")
                }
            } catch {
                await MainActor.run {
                    print("Error signing out: \(error)")
                    errorMessage = "Failed to sign out"
                    completion(false)
                }
            }
        }
    }
}
