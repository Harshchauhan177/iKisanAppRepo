import UIKit

class LaunchHandler {
    static let shared = LaunchHandler()
    
    private init() {}
    
    func determineInitialScreen(window: UIWindow) -> UIViewController {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let didCompleteCropSelection = UserDefaults.standard.bool(forKey: "didCompleteCropSelection")
        
        if !hasCompletedOnboarding {
            // User hasn't completed onboarding, show onboarding screens
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController {
                return onboardingVC
            }
        } else if !AuthManager.shared.isLoggedIn {
            // User has completed onboarding but isn't logged in, show login screen
            let loginVC = LoginViewController()
            return UINavigationController(rootViewController: loginVC)
        } else if let currentUser = AuthManager.shared.currentUser, 
                  let selectedCrops = currentUser.selectedCrops, 
                  !selectedCrops.isEmpty {
            // User is logged in and has selected crops, show main interface
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                configureTabBarWithDataController(tabBarController)
                return tabBarController
            }
        } else if !didCompleteCropSelection {
            // User is logged in but hasn't completed crop selection, show crop selection
            let selectCropsVC = SelectCropsViewController()
            return UINavigationController(rootViewController: selectCropsVC)
        } else {
            // User is logged in, has completed crop selection (even if empty), show main interface
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                configureTabBarWithDataController(tabBarController)
                return tabBarController
            }
        }
        
        // Fallback to login screen if any issues
        let loginVC = LoginViewController()
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