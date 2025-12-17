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
            let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
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
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                configureTabBarWithDataController(tabBarController)
                return tabBarController
            }
        }
        
        // Fallback to login screen if any issues
        let loginVC = LoginHostingController()
        return UINavigationController(rootViewController: loginVC)
    }
    
    private func configureTabBarWithDataController(_ tabBarController: UITabBarController) {
        let dataController = IKisanDataController()
        
        guard let viewControllers = tabBarController.viewControllers else { return }
        
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController {
                if let homeVC = navController.viewControllers.first as? HomeViewController {
                    homeVC.dataController = dataController
                } else if let agriAssistVC = navController.viewControllers.first as? AgriAssistViewController {
                    agriAssistVC.dataController = dataController
                } else if let coequipVC = navController.viewControllers.first as? CoequipViewController {
                    coequipVC.dataController = dataController
                }
            } else if let homeVC = viewController as? HomeViewController {
                homeVC.dataController = dataController
            } else if let agriAssistVC = viewController as? AgriAssistViewController {
                agriAssistVC.dataController = dataController
            } else if let coequipVC = viewController as? CoequipViewController {
                coequipVC.dataController = dataController
            }
        }
    }
} 