import UIKit
import SwiftUI

/// A UIKit wrapper for the SwiftUI ProfileView
class ProfileHostingController: UIHostingController<ProfileView> {
    
    init() {
        // Initialize with our SwiftUI ProfileView
        super.init(rootView: ProfileView())
        
        // Configure the hosting controller
        self.title = "Profile"
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional UIKit-specific setup if needed
        navigationItem.largeTitleDisplayMode = .never
    }
}
