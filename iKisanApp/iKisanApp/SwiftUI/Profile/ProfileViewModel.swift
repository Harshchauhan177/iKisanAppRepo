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
    @Published var showDeleteConfirmation = false
    @Published var isSaving = false
    @Published var isDeleting = false
    @Published var isUploadingAvatar = false
    @Published var errorMessage: String?
    
    @Published var editName: String = ""
    @Published var editPhone: String = ""
    @Published var editAddress: String = ""
    
    let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
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
        
        print("📋 fetchProfile: Loading profile for user: \(currentUser.id.uuidString)")
        
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
            print("📋 fetchProfile: Raw data received: \(String(data: userData, encoding: .utf8) ?? "nil")")
            
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
            
            print("✅ fetchProfile: Profile loaded successfully")
            
        } catch {
            print("❌ fetchProfile error: \(error)")
            
            // Fallback: use data from AuthManager if available
            self.name = currentUser.name
            self.email = currentUser.email
            self.phone = currentUser.phone
            if let addr = currentUser.address {
                self.address = addr
            }
            
            // Only show error if we also don't have AuthManager data
            if currentUser.name.isEmpty {
                errorMessage = "Failed to load profile data"
            }
        }
    }
    
    private func fetchAvatar(userId: String) async {
        do {
            // Attempt to download avatar from storage
            // Use lowercased UUID to match Supabase auth.uid() format
            let data = try await supabase.client.storage
                .from("avatars")
                .download(path: "\(userId.lowercased())/avatar.jpg")
            
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
        guard let userId = AuthManager.shared.currentUser?.id.uuidString.lowercased() else {
            await MainActor.run { errorMessage = "User not logged in" }
            return
        }
        
        await MainActor.run { isUploadingAvatar = true }
        
        // Resize image to max 400x400 to keep file size small
        let resizedImage = resizeImage(image, maxSize: 400)
        
        // Use JPEG compression
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.5) else {
            await MainActor.run {
                isUploadingAvatar = false
                errorMessage = "Failed to process image"
            }
            return
        }
        
        print("📸 Uploading avatar: \(imageData.count / 1024) KB")
        
        do {
            // Get the current session access token
            let session = try await supabase.client.auth.session
            let accessToken = session.accessToken
            
            // Build the Storage REST API URL
            let supabaseUrl = "https://pxuuupiqeipyemluyers.supabase.co"
            let path = "\(userId)/avatar.jpg"
            let urlString = "\(supabaseUrl)/storage/v1/object/avatars/\(path)"
            
            guard let url = URL(string: urlString) else {
                await MainActor.run {
                    isUploadingAvatar = false
                    errorMessage = "Invalid upload URL"
                }
                return
            }
            
            // Create the request (POST for new, PUT for upsert)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.setValue("true", forHTTPHeaderField: "x-upsert")
            request.httpBody = imageData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📸 Upload response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("✅ Avatar uploaded successfully")
                    await MainActor.run {
                        self.avatar = image
                        self.isUploadingAvatar = false
                    }
                } else {
                    print("❌ Upload failed with status: \(httpResponse.statusCode)")
                    await MainActor.run {
                        isUploadingAvatar = false
                        errorMessage = "Failed to upload avatar (status \(httpResponse.statusCode))"
                    }
                }
            } else {
                await MainActor.run { isUploadingAvatar = false }
            }
        } catch {
            print("❌ Error uploading avatar: \(error)")
            await MainActor.run {
                isUploadingAvatar = false
                errorMessage = "Failed to upload avatar"
            }
        }
    }
    
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        if ratio >= 1.0 { return image }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
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
    
    // MARK: - Account Deletion
    
    @MainActor
    func deleteAccount() async {
        isDeleting = true
        
        do {
            try await AuthManager.shared.deleteAccount()
            
            // Account deleted successfully — the hosting controller will handle navigation
            // via the notification posted below
            isDeleting = false
        } catch {
            print("Error deleting account: \(error)")
            errorMessage = "Failed to delete account. Please try again or contact support."
            isDeleting = false
        }
    }
}
