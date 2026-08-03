import UIKit

class LaunchHandler {
    static let shared = LaunchHandler()
    
    private init() {}
    
    func determineInitialScreen(window: UIWindow) -> UIViewController {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let isNewlyRegisteredUser = UserDefaults.standard.bool(forKey: "isNewlyRegisteredUser")
        
        // Flow logic:
        // 1. First time users (no onboarding) → Show onboarding
        // 2. Onboarding completed but not logged in → Show login
        // 3. Newly registered users (signup or first Apple Sign In) → Show crop selection
        // 4. Existing users logging in → Show main app (can select crops from profile)
        
        if !hasCompletedOnboarding {
            // User hasn't completed onboarding, show UIKit onboarding screens
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController else {
                let loginVC = LoginHostingController()
                return UINavigationController(rootViewController: loginVC)
            }
            return onboardingVC
        } else if !AuthManager.shared.isLoggedIn {
            // User has completed onboarding but isn't logged in, show login screen
            // Using new SwiftUI LoginView with MVVM architecture
            let loginVC = LoginHostingController()
            return UINavigationController(rootViewController: loginVC)
        } else if isNewlyRegisteredUser {
            // This is a newly registered user (signup or new Apple Sign In)
            // Show crop selection as part of onboarding flow
            // This flag is set during registration and cleared after crop selection
            let dataController = IKisanDataController()
            let selectCropsVC = SelectCropsHostingController(dataController: dataController, isFromProfile: false)
            return UINavigationController(rootViewController: selectCropsVC)
        } else {
            // Existing user logging in - go directly to main app
            // They can select/update crops later from their profile
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController {
                // Set dataController BEFORE viewDidLoad
                let dataController = IKisanDataController()
                mainTabBarController.dataController = dataController
                print("✅ LaunchHandler: dataController set on MainTabBarController")
                return mainTabBarController
            }
        }
        
        // Fallback to login screen if any issues
        let loginVC = LoginHostingController()
        return UINavigationController(rootViewController: loginVC)
    }
}
 