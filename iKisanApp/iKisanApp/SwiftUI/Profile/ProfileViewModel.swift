import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var email: String
    @Published var phone: String
    @Published var avatar: UIImage?
    
    @Published var isEditMode = false
    @Published var showSignOutConfirmation = false
    @Published var isSaving = false
    
    @Published var editName: String = ""
    @Published var editPhone: String = ""
    
    let ikisanGreen = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    init(user: AuthUser) {
        self.name = user.name
        self.email = user.email
        self.phone = user.phone
    }
    
    func enterEditMode() {
        editName = name
        editPhone = phone
        isEditMode = true
    }
    
    func cancelEdit() {
        isEditMode = false
    }
    
    func saveChanges() {
        isSaving = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Update the user data
            self.name = self.editName
            self.phone = self.editPhone
            
            // In a real app, you would update the user in the database
            // AuthManager.shared.updateUser(name: self.name, phone: self.phone)
            
            self.isSaving = false
            self.isEditMode = false
        }
    }
    
    func signOut() {
        // In a real app, you would sign out the user
        // AuthManager.shared.signOut()
        print("User signed out")
    }
    
    func updateAvatar(with image: UIImage) {
        avatar = image
        // In a real app, you would upload the avatar to storage
    }
}
