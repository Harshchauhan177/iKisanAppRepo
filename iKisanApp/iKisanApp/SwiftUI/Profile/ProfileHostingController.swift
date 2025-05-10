import UIKit
import SwiftUI

/// A UIKit wrapper for the SwiftUI ProfileView
class ProfileHostingController: UIHostingController<ProfileView> {
    
    init() {
        // Initialize with our SwiftUI ProfileView
        super.init(rootView: ProfileView())
        
        // Remove title setting to prevent duplicate "Profile" title
        // The SwiftUI view handles its own title
        
        // Register for notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidSignOut),
            name: .userDidSignOut,
            object: nil
        )
        
        // Register for edit mode notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterEditMode),
            name: .didEnterEditMode,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didExitEditMode),
            name: .didExitEditMode,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure proper navigation appearance
        navigationItem.largeTitleDisplayMode = .never
    }
    
    /// Handler for sign out notification
    @objc func userDidSignOut() {
        navigateToLogin()
    }
    
    /// Handler for entering edit mode
    @objc func didEnterEditMode() {
        // Hide the back button when entering edit mode
        DispatchQueue.main.async {
            self.navigationItem.hidesBackButton = true
        }
    }
    
    /// Handler for exiting edit mode
    @objc func didExitEditMode() {
        // Show the back button again when exiting edit mode
        DispatchQueue.main.async {
            self.navigationItem.hidesBackButton = false
        }
    }
    
    /// Navigates to the login screen after sign out
    func navigateToLogin() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            DispatchQueue.main.async {
                sceneDelegate.switchToLogin()
            }
        }
    }
}
